import express from "express";
import cors from "cors";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { v4 as uuidv4 } from "uuid";
import rateLimit from "express-rate-limit";
import helmet from "helmet";
import morgan from "morgan";
import Joi from "joi";
import { WebSocketServer } from "ws";
import http from "http";
import { PrismaClient } from "@prisma/client";
import { Prisma } from "@prisma/client";
import multer from "multer";
import path from "path";
import { fileURLToPath } from "url";
import fs from "fs";
import deleteAccountRouter from "./routes/deleteAccount.js";

// --- SETUP ---
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 👇 Add these two lines
const profilesUploadPath = path.join(__dirname, "uploads/profiles");
fs.mkdirSync(profilesUploadPath, { recursive: true });

const app = express();
const server = http.createServer(app);
const prisma = new PrismaClient();
const wss = new WebSocketServer({ server });

const PORT = process.env.PORT;
const JWT_SECRET = process.env.JWT_SECRET;
const GOOGLE_MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY;

// --- MIDDLEWARE & CONFIGURATION ---

// Security headers
app.use(helmet());
// Enable CORS
app.use(cors());
// Request logging
app.use(morgan("dev"));
// JSON body parser with increased limit for potential base64 images
app.use(express.json({ limit: "10mb" }));
// Serve static files from the 'uploads' directory
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static page
app.use("/delete-account", express.static(path.join(__dirname, "public")));

// API route

// General API rate limiting
// const apiLimiter = rateLimit({
//   windowMs: 15 * 60 * 1000, // 15 minutes
//   max: 100,
//   message: {
//     error: "Too many requests from this IP, please try again after 15 minutes.",
//   },
//   standardHeaders: true,
//   legacyHeaders: false,
// });
// app.use(
//   "/api/"
//   apiLimiter
// );

// Stricter rate limiting for authentication endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: {
    error: "Too many authentication attempts, please try again later.",
  },
  standardHeaders: true,
  legacyHeaders: false,
});

const uploadsDir = path.join(__dirname, "uploads");
const profilesDir = path.join(uploadsDir, "profiles");

if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

if (!fs.existsSync(profilesDir)) {
  fs.mkdirSync(profilesDir, { recursive: true });
}

// Multer configuration for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, profilesDir); // Use the variable instead of path.join
  },
  filename: (req, file, cb) => {
    cb(null, "PROFILE-" + Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 1024 * 1024 * 2 }, // Limit file size to 2MB
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png/;
    const extname = filetypes.test(
      path.extname(file.originalname).toLowerCase()
    );
    const mimetype = filetypes.test(file.mimetype);
    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(
        new AppError(
          "Upload failed: only .png, .jpg, and .jpeg formats are allowed.",
          400
        )
      );
    }
  },
});

// --- CUSTOM ERROR HANDLING ---

class AppError extends Error {
  constructor(message, statusCode, code = null) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// --- VALIDATION SCHEMAS (JOI) ---

const schemas = {
  // Shared parameter schemas
  rideIdParam: Joi.object({
    rideId: Joi.string().uuid().required().messages({
      "string.guid": "Invalid Ride ID format.",
      "any.required": "Ride ID is required.",
    }),
  }),
  latLngQuery: Joi.object({
    latitude: Joi.number().min(-90).max(90).required(),
    longitude: Joi.number().min(-180).max(180).required(),
  }),

  // Route-specific schemas
  register: {
    body: Joi.object({
      email: Joi.string().email().required().messages({
        "string.email": "Please provide a valid email address.",
        "any.required": "Email is a required field.",
      }),
      password: Joi.string()
        .min(8)
        .pattern(
          new RegExp("^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])")
        )
        .required()
        .messages({
          "string.min": "Password must be at least 8 characters long.",
          "string.pattern.base":
            "Password must contain an uppercase letter, a lowercase letter, a number, and a special character.",
          "any.required": "Password is a required field.",
        }),
      name: Joi.string().min(2).max(50).required().messages({
        "string.min": "Name must be at least 2 characters.",
        "string.max": "Name cannot exceed 50 characters.",
        "any.required": "Name is a required field.",
      }),
      userType: Joi.string().valid("client", "driver").required().messages({
        "any.only": "User type must be either 'client' or 'driver'.",
        "any.required": "User type is required.",
      }),
      phone: Joi.string()
        .pattern(/^\+?[\d\s\-\(\)]+$/)
        .required()
        .messages({
          "string.pattern.base": "Please enter a valid phone number.",
          "any.required": "Phone number is required.",
        }),
      vehicle: Joi.object({
        type: Joi.string()
          .valid("sedan", "suv", "hatchback", "minivan", "tuk-tuk", "motorbike")
          .required(),
        model: Joi.string().min(2).max(50).required(),
        licensePlate: Joi.string().min(3).max(15).required(),
        color: Joi.string().min(2).max(30).required(),
        year: Joi.number().integer().min(1990).max(new Date().getFullYear()),
      }).when("userType", {
        is: "driver",
        then: Joi.required(),
        otherwise: Joi.forbidden(),
      }),
    }),
  },

  login: {
    body: Joi.object({
      email: Joi.string().email().required().messages({
        "string.email": "Please provide a valid email address.",
        "any.required": "Email is required.",
      }),
      password: Joi.string().required().messages({
        "any.required": "Password is required.",
      }),
    }),
  },

  serviceRequest: {
    body: Joi.object({
      serviceType: Joi.string().valid("ride", "delivery").default("ride"),
      pickupLatitude: Joi.number().min(-90).max(90).required(),
      pickupLongitude: Joi.number().min(-180).max(180).required(),
      destinationLatitude: Joi.number().min(-90).max(90).required(),
      destinationLongitude: Joi.number().min(-180).max(180).required(),
      pickupAddress: Joi.string().required(),
      destinationAddress: Joi.string().required(),
      rideType: Joi.string()
        .valid("Tuk-tuk", "Go", "Comfort", "Comfort X", "Premium", "Motorbike")
        .required(),
      estimatedPrice: Joi.number().min(0).required(),
      // Delivery-specific fields with conditional validation
      recipientName: Joi.when("serviceType", {
        is: "delivery",
        then: Joi.string().required(),
        otherwise: Joi.optional(),
      }),
      recipientPhone: Joi.when("serviceType", {
        is: "delivery",
        then: Joi.string()
          .pattern(/^\+?[\d\s\-\(\)]+$/)
          .required(),
        otherwise: Joi.optional(),
      }),
      packageDetails: Joi.when("serviceType", {
        is: "delivery",
        then: Joi.string().max(200).required(),
        otherwise: Joi.optional(),
      }),
      isFragile: Joi.when("serviceType", {
        is: "delivery",
        then: Joi.boolean().default(false),
        otherwise: Joi.optional(),
      }),
    }),
  },

  updateLocation: {
    body: Joi.object({
      latitude: Joi.number().min(-90).max(90).required(),
      longitude: Joi.number().min(-180).max(180).required(),
    }),
  },

  updateAvailability: {
    body: Joi.object({
      isAvailable: Joi.boolean().required(),
    }),
  },

  cancelRide: {
    params: Joi.object({ rideId: Joi.string().uuid().required() }),
    body: Joi.object({
      reason: Joi.string().max(255).optional(),
    }),
  },

  rateRide: {
    params: Joi.object({ rideId: Joi.string().uuid().required() }),
    body: Joi.object({
      rating: Joi.number().integer().min(1).max(5).required().messages({
        "number.base": "Rating must be a number.",
        "number.integer": "Rating must be a whole number.",
        "number.min": "Rating cannot be less than 1.",
        "number.max": "Rating cannot be greater than 5.",
        "any.required": "A rating is required to submit feedback.",
      }),
      comment: Joi.string().max(500).allow("").optional().messages({
        "string.max": "Comment cannot exceed 500 characters.",
      }),
    }),
  },

  completeRide: {
    params: Joi.object({ rideId: Joi.string().uuid().required() }),
    body: Joi.object({
      finalPrice: Joi.number().positive().optional(),
    }),
  },

  getHistory: {
    query: Joi.object({
      page: Joi.number().integer().min(1).default(1),
      limit: Joi.number().integer().min(1).max(50).default(10),
      status: Joi.string().valid("completed", "cancelled").optional(),
    }),
  },

  declineRide: {
    params: Joi.object({
      rideId: Joi.string().uuid().required(),
    }),
  },
};

// Middleware to parse a JSON string field from multipart/form-data
const parseJsonField = (fieldName) => (req, res, next) => {
  if (req.body && req.body[fieldName]) {
    try {
      req.body[fieldName] = JSON.parse(req.body[fieldName]);
    } catch (e) {
      return next(
        new AppError(`Invalid JSON format for field: ${fieldName}`, 400)
      );
    }
  }
  next();
};

// Universal validation middleware
const validate = (schema) => (req, res, next) => {
  const toValidate = {};
  if (schema.params) toValidate.params = req.params;
  if (schema.body) toValidate.body = req.body;
  if (schema.query) toValidate.query = req.query;

  const { error } = Joi.object(schema).validate(toValidate, {
    abortEarly: false,
  });

  if (error) {
    const errorMessage = error.details
      .map((detail) => detail.message)
      .join(", ");
    return next(new AppError(errorMessage, 400, "VALIDATION_ERROR"));
  }

  return next();
};

// --- AUTHENTICATION & AUTHORIZATION ---

const authenticateToken = asyncHandler(async (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];
  if (!token)
    throw new AppError(
      "Authentication failed: No token provided.",
      401,
      "NO_TOKEN"
    );

  const decoded = jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return null;
    return user;
  });
  if (!decoded)
    throw new AppError(
      "Authentication failed: Invalid or expired token. Please log in again.",
      403,
      "INVALID_TOKEN"
    );

  const user = await prisma.user.findUnique({ where: { id: decoded.id } });
  if (!user || !user.isActive)
    throw new AppError(
      "User not found or account is deactivated.",
      404,
      "USER_NOT_FOUND"
    );

  req.user = user;
  next();
});

const authorize =
  (...roles) =>
  (req, res, next) => {
    if (!roles.includes(req.user.userType)) {
      throw new AppError(
        "Forbidden: You do not have permission to perform this action.",
        403,
        "INSUFFICIENT_PERMISSIONS"
      );
    }
    next();
  };

// --- WEBSOCKET HANDLING ---

const connections = new Map(); // Stores WebSocket connections: { userId -> ws }

wss.on("connection", (ws) => {
  ws.isAlive = true;
  ws.on("pong", () => {
    ws.isAlive = true;
  });

  ws.on(
    "message",
    asyncHandler(async (message) => {
      const data = JSON.parse(message);
      if (data.type === "auth" && data.token) {
        const decoded = jwt.verify(data.token, JWT_SECRET);
        if (!decoded) {
          ws.send(
            JSON.stringify({ type: "error", message: "Invalid auth token." })
          );
          ws.terminate();
          return;
        }

        ws.userId = decoded.id;
        ws.userType = decoded.userType;
        connections.set(decoded.id, ws);
        ws.send(
          JSON.stringify({
            type: "auth_success",
            message: "WebSocket authenticated.",
          })
        );

        if (ws.userType === "driver") {
          await prisma.driver.update({
            where: { id: ws.userId },
            data: { isAvailable: true, updatedAt: new Date() },
          });
        }
      } // In your WebSocket message handler, update the location_update section:
      else if (data.type === "location_update" && ws.userType === "driver") {
        const { latitude, longitude, bearing } = data; // Add bearing from client

        if (ws.userId && latitude && longitude) {
          await prisma.driver.update({
            where: { id: ws.userId },
            data: {
              latitude,
              longitude,
              bearing: bearing || 0, // Store bearing if provided
              updatedAt: new Date(),
            },
          });

          const activeRide = await prisma.ride.findFirst({
            where: {
              driverId: ws.userId,
              status: { in: ["accepted", "in_progress"] },
            },
          });

          if (activeRide) {
            broadcastToUser(activeRide.clientId, {
              type: "driver_location_update",
              rideId: activeRide.id,
              driverId: ws.userId,
              latitude,
              longitude,
              bearing: bearing || 0, // Include bearing in broadcast
            });
          }
        }
      } else if (data.type === "client_on_my_way") {
        const { rideId } = data;
        if (ws.userType !== "client" || !rideId) return;

        const ride = await prisma.ride.findFirst({
          where: { id: rideId, clientId: ws.userId, driverId: { not: null } },
        });

        if (ride) {
          broadcastToUser(ride.driverId, {
            type: "client_is_coming",
            rideId: ride.id,
            message: "The client is on their way to the pickup location!",
          });
        }
      }
    })
  );

  ws.on("close", async () => {
    if (ws.userId) {
      connections.delete(ws.userId);
      if (ws.userType === "driver") {
        await prisma.driver
          .update({
            where: { id: ws.userId },
            data: { isAvailable: false },
          })
          .catch((err) =>
            console.error(
              `Failed to set driver ${ws.userId} offline on disconnect:`,
              err
            )
          );
      }
    }
  });

  ws.on("error", (error) =>
    console.error(`WebSocket error for user ${ws.userId}:`, error)
  );
});

// Heartbeat to prune dead connections
setInterval(() => {
  wss.clients.forEach((ws) => {
    if (!ws.isAlive) return ws.terminate();
    ws.isAlive = false;
    ws.ping();
  });
}, 30000);

// --- UTILITY FUNCTIONS ---

const broadcastToUser = (userId, message) => {
  const connection = connections.get(userId);
  if (connection && connection.readyState === 1) {
    // WebSocket.OPEN
    connection.send(JSON.stringify(message));
  }
};

const calculateDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371; // Earth's radius in km
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
};

const getRideTypesForVehicle = (vehicleType) => {
  // Vehicle types are stored in lowercase in the DB
  const compatibility = {
    sedan: ["Go", "Comfort"],
    suv: ["Comfort", "Comfort X", "Premium"],
    hatchback: ["Go"],
    minivan: ["Comfort X"],
    "tuk-tuk": ["Tuk-tuk"],
    motorbike: ["Motorbike"],
  };
  return compatibility[vehicleType] || [];
};

const formatDriverPayload = (driver) => {
  if (!driver) return null;
  return {
    id: driver.id,
    name: driver.name,
    phone: driver.phone,
    rating: driver.rating,
    profileImageUrl: driver.profileImageUrl,
    vehicle: {
      type: driver.vehicleType,
      licensePlate: driver.licensePlate,
      color: driver.color,
      model: driver.model,
      year: driver.year,
    },
    latitude: driver.latitude,
    longitude: driver.longitude,
    bearing: driver.bearing,
  };
};

// --- API ROUTES ---

app.get("/health", (req, res) =>
  res.json({ status: "healthy", timestamp: new Date().toISOString() })
);

// POST /api/register
app.post(
  "/api/register",
  // authLimiter,
  upload.single("profileImage"),
  parseJsonField("vehicle"),
  validate(schemas.register),
  asyncHandler(async (req, res) => {
    const { email, password, name, userType, phone, vehicle } = req.body;

    if (userType === "driver" && !req.file) {
      throw new AppError(
        "A profile image is required for driver registration.",
        400,
        "MISSING_PROFILE_IMAGE"
      );
    }

    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [{ email: email.toLowerCase() }, { phone: phone }],
      },
    });

    if (existingUser) {
      if (existingUser.email === email.toLowerCase()) {
        throw new AppError(
          "An account with this email already exists.",
          409,
          "EMAIL_EXISTS"
        );
      }
      if (existingUser.phone === phone) {
        throw new AppError(
          "An account with this phone number already exists.",
          409,
          "PHONE_EXISTS"
        );
      }
    }

    const hashedPassword = await bcrypt.hash(password, 12);
    const user = await prisma.user.create({
      data: {
        id: uuidv4(),
        email: email.toLowerCase(),
        password: hashedPassword,
        name,
        userType,
        phone,
      },
    });

    if (userType === "driver") {
      const baseUrl = `${req.protocol}://${req.get("host")}`;
      const profileImageUrl = `${baseUrl}/uploads/profiles/${req.file.filename}`;
      await prisma.driver.create({
        data: {
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          profileImageUrl,
          vehicleType: vehicle.type.toLowerCase(),
          licensePlate: vehicle.licensePlate,
          color: vehicle.color,
          model: vehicle.model,
          year: parseInt(vehicle.year, 10),
        },
      });
    }

    const token = jwt.sign(
      { id: user.id, userType: user.userType },
      JWT_SECRET,
      { expiresIn: "365d" }
    );
    res.status(201).json({
      message: "User registered successfully.",
      token,
      user: { id: user.id, name: user.name, userType: user.userType },
    });
  })
);

// POST /api/login
app.post(
  "/api/login",
  // authLimiter,
  validate(schemas.login),
  asyncHandler(async (req, res) => {
    const { email, password } = req.body;
    const user = await prisma.user.findUnique({
      where: { email: email.toLowerCase() },
    });
    if (!user)
      throw new AppError(
        "Invalid credentials. Please check your email and password.",
        401,
        "INVALID_CREDENTIALS"
      );

    if (!user.isActive)
      throw new AppError(
        "Your account has been deactivated. Please contact support.",
        403,
        "ACCOUNT_DEACTIVATED"
      );

    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword)
      throw new AppError(
        "Invalid credentials. Please check your email and password.",
        401,
        "INVALID_CREDENTIALS"
      );

    const token = jwt.sign(
      { id: user.id, userType: user.userType },
      JWT_SECRET,
      { expiresIn: "365d" }
    );
    res.json({
      message: "Login successful.",
      token,
      user: { id: user.id, name: user.name, userType: user.userType },
    });
  })
);

// GET /api/profile
app.get(
  "/api/profile",
  authenticateToken,
  asyncHandler(async (req, res) => {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      include: { driver: true },
    });
    // The authenticateToken middleware already confirms the user exists.
    res.json({ profile: { ...user, password: "redacted" } });
  })
);

// GET /api/reverse-geocode
app.get(
  "/api/reverse-geocode",
  authenticateToken,
  asyncHandler(async (req, res) => {
    const { lat, lng } = req.query;
    if (!lat || !lng)
      throw new AppError(
        "Latitude and longitude are required query parameters.",
        400,
        "MISSING_COORDINATES"
      );

    const response = await fetch(
      `https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat},${lng}&key=${GOOGLE_MAPS_API_KEY}`
    );
    const data = await response.json();

    if (data.status !== "OK" || !data.results.length) {
      throw new AppError(
        "Could not find an address for the provided coordinates.",
        404,
        "ADDRESS_NOT_FOUND"
      );
    }
    res.json({ address: data.results[0].formatted_address });
  })
);

// GET /api/geocode (Autocomplete)
app.get(
  "/api/geocode",
  authenticateToken,
  asyncHandler(async (req, res) => {
    const { query } = req.query;
    if (!query)
      throw new AppError(
        "A 'query' parameter is required.",
        400,
        "MISSING_QUERY"
      );

    const autocompleteUrl = `https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${encodeURIComponent(
      query
    )}&key=${GOOGLE_MAPS_API_KEY}&radius=50000&location=41.2995,69.2401`; // Bias towards Tashkent
    const response = await fetch(autocompleteUrl);
    const data = await response.json();

    if (data.status !== "OK") {
      console.error("Google Places API Error:", data.error_message);
      throw new AppError(
        "Failed to fetch location suggestions.",
        500,
        "GEOCODING_API_ERROR"
      );
    }

    const suggestionPromises = data.predictions.map(async (item) => {
      const detailsUrl = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${item.place_id}&fields=name,formatted_address,geometry&key=${GOOGLE_MAPS_API_KEY}`;
      const detailsResponse = await fetch(detailsUrl);
      const detailsData = await detailsResponse.json();

      if (detailsData.status === "OK" && detailsData.result.geometry) {
        return {
          name: item.structured_formatting.main_text,
          address: detailsData.result.formatted_address,
          latitude: detailsData.result.geometry.location.lat,
          longitude: detailsData.result.geometry.location.lng,
        };
      }
      return null;
    });

    const suggestions = (await Promise.all(suggestionPromises)).filter(Boolean);
    res.json({ suggestions });
  })
);

// GET /api/drivers/nearby
app.get(
  "/api/drivers/nearby",
  authenticateToken,
  authorize("client"),
  validate({ query: schemas.latLngQuery }),
  asyncHandler(async (req, res) => {
    const { latitude, longitude } = req.query;
    const twoMinutesAgo = new Date(Date.now() - 2 * 60 * 1000);
    const drivers = await prisma.driver.findMany({
      where: { isAvailable: true, updatedAt: { gte: twoMinutesAgo } },
    });

    const nearbyDrivers = drivers
      .map((driver) => ({
        ...driver,
        distance: calculateDistance(
          latitude,
          longitude,
          driver.latitude,
          driver.longitude
        ),
      }))
      .filter((driver) => driver.distance <= 10) // 10km radius
      .sort((a, b) => a.distance - b.distance);

    res.json({ drivers: nearbyDrivers.slice(0, 10).map(formatDriverPayload) });
  })
);

// PUT /api/driver/availability
app.put(
  "/api/driver/availability",
  authenticateToken,
  authorize("driver"),
  validate(schemas.updateAvailability),
  asyncHandler(async (req, res) => {
    const { isAvailable } = req.body;
    await prisma.driver.update({
      where: { id: req.user.id },
      data: { isAvailable: Boolean(isAvailable), updatedAt: new Date() },
    });
    res.json({
      message: `Availability updated. You are now ${
        isAvailable ? "online" : "offline"
      }.`,
    });
  })
);

// POST /api/service/request
app.post(
  "/api/service/request",
  authenticateToken,
  authorize("client"),
  validate(schemas.serviceRequest),
  asyncHandler(async (req, res) => {
    const activeRide = await prisma.ride.findFirst({
      where: {
        clientId: req.user.id,
        status: {
          in: ["pending", "accepted", "driver_arrived", "in_progress"],
        },
      },
    });
    if (activeRide)
      throw new AppError(
        "You cannot request a new service while another is active.",
        409,
        "ACTIVE_RIDE_EXISTS"
      );

    const ride = await prisma.ride.create({
      data: { id: uuidv4(), clientId: req.user.id, ...req.body },
    });

    // Find drivers whose vehicle type is compatible with the requested ride type
    const compatibleVehicleTypes = Object.entries({
      sedan: ["Go", "Comfort"],
      suv: ["Comfort", "Comfort X", "Premium"],
      hatchback: ["Go"],
      minivan: ["Comfort X"],
      "tuk-tuk": ["Tuk-tuk"],
      motorbike: ["Motorbike", "Delivery"],
    })
      .filter(([_, rideTypes]) => rideTypes.includes(req.body.rideType))
      .map(([vehicleType, _]) => vehicleType);

    const drivers = await prisma.driver.findMany({
      where: {
        isAvailable: true,
        vehicleType: { in: compatibleVehicleTypes },
      },
    });

    if (drivers.length === 0) {
      // Revert ride creation if no drivers are available, and inform the user.
      await prisma.ride.update({
        where: { id: ride.id },
        data: {
          status: "cancelled",
          cancellationReason: "No drivers available",
        },
      });
      throw new AppError(
        "We couldn't find any available drivers for this ride type right now. Please try again in a moment.",
        404,
        "NO_DRIVERS_FOUND"
      );
    }

    const rideRequestPayload = {
      type: "new_ride_request",
      ride: {
        ...ride,
        client: { id: req.user.id, name: req.user.name, phone: req.user.phone },
      },
    };
    drivers.forEach((driver) => broadcastToUser(driver.id, rideRequestPayload));

    res.status(201).json({ message: "Service requested successfully.", ride });
  })
);

// GET /api/rides/estimate
app.get(
  "/api/rides/estimate",
  authenticateToken,
  asyncHandler(async (req, res) => {
    const { from, to } = req.query;
    if (!from || !to)
      throw new AppError(
        "'from' and 'to' (lat,lng) query parameters are required.",
        400
      );

    const response = await fetch(
      `https://maps.googleapis.com/maps/api/directions/json?origin=${from}&destination=${to}&key=${GOOGLE_MAPS_API_KEY}`
    );
    const data = await response.json();
    if (data.status !== "OK" || !data.routes.length)
      throw new AppError(
        "Could not calculate route. Please check the addresses.",
        500,
        "ROUTE_API_ERROR"
      );

    const leg = data.routes[0].legs[0];
    const distanceKm = leg.distance.value / 1000;
    const durationMin = Math.round(leg.duration.value / 60);
    const standardPrice = Math.round(50 + distanceKm * 20); // Base fare + per km

    const quotes = [
      { rideType: "Tuk-tuk", rideName: "Tuk-Tuk", price: standardPrice * 0.7 },
      { rideType: "Go", rideName: "Go", price: standardPrice },
      { rideType: "Comfort", rideName: "Comfort", price: standardPrice * 1.5 },
      {
        rideType: "Comfort X",
        rideName: "Comfort X",
        price: standardPrice * 1.8,
      },
      { rideType: "Premium", rideName: "Premium", price: standardPrice * 2.2 },
      {
        rideType: "Motorbike",
        rideName: "Delivery",
        price: standardPrice * 0.8,
      },
    ];

    res.json({
      route: {
        polyline: data.routes[0].overview_polyline.points,
        distance: distanceKm,
        duration: durationMin,
      },
      quotes,
    });
  })
);

// PUT /api/rides/:rideId/accept
app.put(
  "/api/rides/:rideId/accept",
  authenticateToken,
  authorize("driver"),
  validate({ params: schemas.rideIdParam }),
  asyncHandler(async (req, res) => {
    const { rideId } = req.params;

    const ride = await prisma.ride.findFirst({
      where: { id: rideId, status: "pending" },
    });
    if (!ride)
      throw new AppError(
        "Ride not found or has already been accepted.",
        404,
        "RIDE_NOT_AVAILABLE"
      );

    const driverActiveRide = await prisma.ride.findFirst({
      where: {
        driverId: req.user.id,
        status: { in: ["accepted", "driver_arrived", "in_progress"] },
      },
    });
    if (driverActiveRide)
      throw new AppError(
        "Cannot accept a new ride while another is active.",
        409,
        "DRIVER_BUSY"
      );

    const driver = await prisma.driver.findUnique({
      where: { id: req.user.id },
    });

    // Validate that the driver's vehicle is compatible with the ride type
    const compatibleRideTypes = getRideTypesForVehicle(driver.vehicleType);
    if (!compatibleRideTypes.includes(ride.rideType)) {
      throw new AppError(
        "Your vehicle is not suitable for this type of ride.",
        403,
        "VEHICLE_INCOMPATIBLE"
      );
    }

    const updatedRide = await prisma.ride.update({
      where: { id: rideId },
      data: {
        driverId: req.user.id,
        status: "accepted",
        acceptedAt: new Date(),
      },
    });

    await prisma.driver.update({
      where: { id: req.user.id },
      data: { isAvailable: false },
    });

    broadcastToUser(ride.clientId, {
      type: "ride_accepted",
      ride: { ...updatedRide, driver: formatDriverPayload(driver) },
    });

    // Notify other drivers this ride is gone
    connections.forEach((ws, userId) => {
      if (ws.userType === "driver" && userId !== req.user.id) {
        ws.send(JSON.stringify({ type: "ride_unavailable", rideId: rideId }));
      }
    });

    res.json({ message: "Ride accepted.", ride: updatedRide });
  })
);

// --- Ride Status Flow Endpoints ---

const updateRideStatus = async (
  rideId,
  userId,
  userType,
  currentStatus,
  nextStatus,
  updateData = {}
) => {
  const ride = await prisma.ride.findUnique({ where: { id: rideId } });
  if (!ride) throw new AppError("Ride not found.", 404, "RIDE_NOT_FOUND");

  const isDriver = ride.driverId === userId;
  const isClient = ride.clientId === userId;
  if (!isDriver && !isClient) {
    throw new AppError(
      "You are not authorized for this ride.",
      403,
      "UNAUTHORIZED"
    );
  }

  if (ride.status !== currentStatus) {
    throw new AppError(
      `Action failed: ride is not in the '${currentStatus}' state.`,
      409,
      "INVALID_RIDE_STATE"
    );
  }

  const updatedRide = await prisma.ride.update({
    where: { id: rideId },
    data: { status: nextStatus, ...updateData },
  });

  // Broadcast to the other party with correct event names
  const otherPartyId = isDriver ? ride.clientId : ride.driverId;
  if (otherPartyId) {
    broadcastToUser(otherPartyId, {
      type: `ride_${nextStatus}`, // Use raw status: ride_driver_arrived, ride_in_progress, ride_completed
      rideId: ride.id,
      ride: updatedRide,
    });
  }
  return updatedRide;
};

app.put(
  "/api/rides/:rideId/driver-arrived",
  authenticateToken,
  authorize("driver"),
  validate({ params: schemas.rideIdParam }),
  asyncHandler(async (req, res) => {
    const updatedRide = await updateRideStatus(
      req.params.rideId,
      req.user.id,
      req.user.userType,
      "accepted",
      "driver_arrived",
      { driverArrivedAt: new Date() }
    );
    res.json({
      message: "Status updated to 'driver_arrived'.",
      ride: updatedRide,
    });
  })
);

app.put(
  "/api/rides/:rideId/start",
  authenticateToken,
  authorize("driver"),
  validate({ params: schemas.rideIdParam }),
  asyncHandler(async (req, res) => {
    const updatedRide = await updateRideStatus(
      req.params.rideId,
      req.user.id,
      req.user.userType,
      "driver_arrived",
      "in_progress",
      { startedAt: new Date() }
    );
    res.json({ message: "Ride has started.", ride: updatedRide });
  })
);

app.put(
  "/api/rides/:rideId/complete",
  authenticateToken,
  authorize("client", "driver"),
  validate(schemas.completeRide),
  asyncHandler(async (req, res) => {
    const { finalPrice } = req.body;
    const rideId = req.params.rideId;

    const ride = await prisma.ride.findUnique({ where: { id: rideId } });
    if (!ride) throw new AppError("Ride not found.", 404, "RIDE_NOT_FOUND");

    let updateData = { completedAt: new Date() };

    if (req.user.userType === "driver") {
      if (!finalPrice)
        throw new AppError(
          "Final price is required for drivers.",
          400,
          "MISSING_FINAL_PRICE"
        );
      if (ride.driverId !== req.user.id)
        throw new AppError(
          "You are not the driver for this ride.",
          403,
          "UNAUTHORIZED"
        );
      updateData.finalPrice = finalPrice;
      await prisma.driver.update({
        where: { id: req.user.id },
        data: { isAvailable: true, totalRides: { increment: 1 } },
      });
    } else {
      // client
      if (ride.clientId !== req.user.id)
        throw new AppError(
          "You are not the client for this ride.",
          403,
          "UNAUTHORIZED"
        );
      if (!ride.estimatedPrice)
        throw new AppError(
          "Cannot complete without estimated price.",
          400,
          "MISSING_ESTIMATED_PRICE"
        );
      updateData.finalPrice = ride.estimatedPrice;
    }

    const updatedRide = await updateRideStatus(
      rideId,
      req.user.id,
      req.user.userType,
      "in_progress",
      "completed",
      updateData
    );

    // Add explicit broadcast to client
    if (ride.clientId) {
      broadcastToUser(ride.clientId, {
        type: "ride_completed",
        rideId: ride.id,
        ride: updatedRide,
        finalPrice: updateData.finalPrice,
      });
    }

    res.json({
      message: "Ride completed successfully.",
      finalPrice: updateData.finalPrice,
      ride: updatedRide,
    });
  })
);

// 👇 ADDED THIS NEW ENDPOINT
app.post(
  "/rides/decline/:rideId",
  authorize("driver"),
  validate(schemas.declineRide),
  asyncHandler(async (req, res, next) => {
    const { rideId } = req.params;
    const driverId = req.user.id;

    try {
      const ride = await prisma.ride.findUnique({
        where: { id: rideId },
        include: { driver: true, client: true },
      });

      if (!ride) {
        throw new AppError("Ride not found.", 404, "RIDE_NOT_FOUND");
      }

      if (ride.status !== "pending") {
        return res.status(400).json({
          error: "Ride cannot be declined as it is no longer pending.",
        });
      }

      // Update the ride status to declined
      await prisma.ride.update({
        where: { id: rideId },
        data: { status: "cancelled", driverId: null },
      });

      // Notify the client that their ride was declined by the driver
      broadcastToUser(ride.clientId, {
        type: "ride_declined",
        rideId: ride.id,
        message:
          "Your ride request was declined by a driver. Searching for another driver...",
      });

      // Notify other drivers that the ride is available again, or a new request can be made
      // This is a placeholder, as the front-end logic would handle resubmitting
      broadcastToUser(driverId, {
        type: "decline_success",
        rideId: ride.id,
        message: "You have declined the ride request.",
      });

      res.status(200).json({
        message: "Ride declined successfully.",
        rideId: ride.id,
      });
    } catch (error) {
      console.error("Error declining ride:", error);
      next(error);
    }
  })
);

// PUT /api/rides/:rideId/cancel
app.put(
  "/api/rides/:rideId/cancel",
  authenticateToken,
  validate(schemas.cancelRide),
  asyncHandler(async (req, res) => {
    const { rideId } = req.params;
    const ride = await prisma.ride.findUnique({ where: { id: rideId } });
    if (!ride) throw new AppError("Ride not found.", 404);
    if (ride.clientId !== req.user.id && ride.driverId !== req.user.id)
      throw new AppError("You are not authorized to cancel this ride.", 403);
    if (!["pending", "accepted", "driver_arrived"].includes(ride.status))
      throw new AppError(
        "This ride can no longer be cancelled as it is in progress or completed.",
        409,
        "CANCELLATION_PERIOD_EXPIRED"
      );

    await prisma.ride.update({
      where: { id: rideId },
      data: {
        status: "cancelled",
        cancelledAt: new Date(),
        cancellationReason: req.body.reason,
      },
    });

    const otherPartyId =
      req.user.id === ride.clientId ? ride.driverId : ride.clientId;
    if (otherPartyId) {
      broadcastToUser(otherPartyId, {
        type: "ride_cancelled",
        rideId,
        message: `Your ride was cancelled by the ${req.user.userType}.`,
      });
      if (ride.driverId) {
        // Make driver available again
        await prisma.driver.update({
          where: { id: ride.driverId },
          data: { isAvailable: true },
        });
      }
    }
    res.json({ message: "Ride cancelled successfully." });
  })
);

// POST /api/rides/:rideId/rate
app.post(
  "/api/rides/:rideId/rate",
  authenticateToken,
  authorize("client"),
  validate(schemas.rateRide),
  asyncHandler(async (req, res) => {
    const { rideId } = req.params;
    const { rating, comment } = req.body;

    const ride = await prisma.ride.findUnique({ where: { id: rideId } });
    if (!ride) throw new AppError("Ride not found.", 404, "RIDE_NOT_FOUND");
    if (ride.status !== "completed")
      throw new AppError(
        "Only completed rides can be rated.",
        400,
        "RIDE_NOT_COMPLETED"
      );
    if (ride.clientId !== req.user.id)
      throw new AppError(
        "You can only rate rides you have taken.",
        403,
        "UNAUTHORIZED_RATING"
      );
    if (!ride.driverId)
      throw new AppError(
        "This ride has no driver to rate.",
        400,
        "NO_DRIVER_TO_RATE"
      );

    const existingRating = await prisma.rating.findFirst({
      where: { rideId, fromUserId: req.user.id },
    });
    if (existingRating)
      throw new AppError(
        "You have already rated this ride.",
        409,
        "ALREADY_RATED"
      );

    await prisma.rating.create({
      data: {
        id: uuidv4(),
        rideId,
        fromUserId: req.user.id,
        toUserId: ride.driverId,
        rating,
        ...(comment ? { comment } : {}),
      },
    });

    const driverRatings = await prisma.rating.aggregate({
      where: { toUserId: ride.driverId },
      _avg: { rating: true },
    });
    await prisma.driver.update({
      where: { id: ride.driverId },
      data: { rating: driverRatings._avg.rating },
    });

    return res.json({ message: "Thank you for your feedback!" });
  })
);

// GET /api/rides/current
app.get(
  "/api/rides/current",
  authenticateToken,
  asyncHandler(async (req, res) => {
    const where =
      req.user.userType === "client"
        ? { clientId: req.user.id }
        : { driverId: req.user.id };
    where.status = {
      in: ["pending", "accepted", "driver_arrived", "in_progress"],
    };

    const currentRide = await prisma.ride.findFirst({
      where,
      include: { driver: true, client: true },
    });
    if (currentRide && currentRide.driver) {
      currentRide.driver = formatDriverPayload(currentRide.driver);
    }
    res.json({ ride: currentRide || null });
  })
);

// GET /api/rides/history
app.get(
  "/api/rides/history",
  authenticateToken,
  validate(schemas.getHistory),
  asyncHandler(async (req, res) => {
    const { page, limit, status } = req.query;
    const where =
      req.user.userType === "client"
        ? { clientId: req.user.id }
        : { driverId: req.user.id };
    if (status) where.status = status;

    const rides = await prisma.ride.findMany({
      where,
      orderBy: { createdAt: "desc" },
      skip: (page - 1) * limit,
      take: limit,
    });
    const total = await prisma.ride.count({ where });

    res.json({
      rides,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  })
);

// PUT /api/profile
app.put(
  "/api/profile",
  authenticateToken,
  upload.single("profileImage"),
  parseJsonField("vehicle"), // For multipart form data where vehicle details are a JSON string
  asyncHandler(async (req, res) => {
    const updateProfileSchema = Joi.object({
      name: Joi.string().min(2).max(50).optional(),
      phone: Joi.string()
        .pattern(/^\+?[\d\s\-\(\)]+$/)
        .optional(),
      vehicle: Joi.object({
        type: Joi.string()
          .valid("sedan", "suv", "hatchback", "minivan", "tuk-tuk", "motorbike")
          .optional(),
        model: Joi.string().min(2).max(50).optional(),
        licensePlate: Joi.string().min(3).max(15).optional(),
        color: Joi.string().min(2).max(30).optional(),
        year: Joi.number()
          .integer()
          .min(1990)
          .max(new Date().getFullYear())
          .optional(),
      }).optional(),
    });

    const { error } = updateProfileSchema.validate(req.body);
    if (error)
      throw new AppError(error.details.map((d) => d.message).join(", "), 400);

    const { name, phone, vehicle } = req.body;
    const userId = req.user.id;

    // --- Update User Table (Common for both) ---
    const userDataToUpdate = {};
    if (name) userDataToUpdate.name = name;
    if (phone) userDataToUpdate.phone = phone;

    if (Object.keys(userDataToUpdate).length > 0) {
      await prisma.user.update({
        where: { id: userId },
        data: userDataToUpdate,
      });
    }

    // --- Update Driver Table (Driver only) ---
    if (req.user.userType === "driver") {
      const driverDataToUpdate = {};
      if (name) driverDataToUpdate.name = name; // Keep driver name in sync
      if (phone) driverDataToUpdate.phone = phone; // Keep driver phone in sync

      if (req.file) {
        const baseUrl = `${req.protocol}://${req.get("host")}`;
        driverDataToUpdate.profileImageUrl = `${baseUrl}/uploads/profiles/${req.file.filename}`;
      }
      if (vehicle) {
        Object.keys(vehicle).forEach((key) => {
          if (vehicle[key]) {
            driverDataToUpdate[key] =
              key === "year" ? parseInt(vehicle[key]) : vehicle[key];
          }
        });
      }
      if (Object.keys(driverDataToUpdate).length > 0) {
        await prisma.driver.update({
          where: { id: userId },
          data: driverDataToUpdate,
        });
      }
    }

    const updatedUser = await prisma.user.findUnique({
      where: { id: userId },
      include: { driver: true },
    });

    res.json({
      message: "Profile updated successfully.",
      profile: { ...updatedUser, password: "redacted" },
    });
  })
);

// DELETE /api/profile
app.delete(
  "/api/profile",
  authenticateToken,
  asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const user = await prisma.user.findUnique({ where: { id: userId } });

    if (!user) throw new AppError("User not found.", 404);

    // Soft delete: make user inactive and anonymize personal data for privacy
    await prisma.$transaction([
      prisma.user.update({
        where: { id: userId },
        data: {
          isActive: false,
          email: `${user.email}_deleted_${Date.now()}`,
          phone: `${user.phone}_deleted_${Date.now()}`,
        },
      }),
      ...(user.userType === "driver"
        ? [
            prisma.driver.update({
              where: { id: userId },
              data: { isAvailable: false },
            }),
          ]
        : []),
    ]);

    // Terminate any active WebSocket connection
    const connection = connections.get(userId);
    if (connection) connection.terminate();

    res
      .status(200)
      .json({ message: "Your account has been successfully deleted." });
  })
);

app.use("/api/delete-account", deleteAccountRouter);

// --- 404 Handler ---
app.use("*", (req, res, next) => {
  next(
    new AppError(
      `The requested URL ${req.originalUrl} was not found on this server.`,
      404,
      "ROUTE_NOT_FOUND"
    )
  );
});

// Global error handling middleware (must be last in the middleware chain)
app.use((err, req, res, next) => {
  console.error("ERROR 💥", err);
  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    if (err.code === "P2002") {
      const field = err.meta?.target?.[0];
      return res.status(409).json({
        error: `An account with this ${field} already exists.`,
        code: "DUPLICATE_FIELD",
      });
    }
  }

  if (err instanceof multer.MulterError) {
    if (err.code === "LIMIT_FILE_SIZE") {
      return res
        .status(400)
        .json({ error: "File size is too large. Maximum is 2MB." });
    }
  }

  if (err.isOperational) {
    res.status(err.statusCode).json({
      error: err.message,
      code: err.code,
    });
  } else {
    // Handle non-operational errors (e.g., programming errors)
    res.status(500).json({
      error: "An unexpected internal server error occurred.",
    });
  }
});

// --- SERVER START ---
server.listen(PORT, "0.0.0.0", async () => {
  try {
    await prisma.$connect();
    console.log("✅ Connected to database via Prisma.");
    console.log(`🚀 Server running on port ${PORT}.`);
  } catch (error) {
    console.error("❌ Failed to connect to the database.", error);
    process.exit(1);
  }
});
