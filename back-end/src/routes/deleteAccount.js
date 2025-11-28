import express from "express";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();
const router = express.Router();

router.post("/", async (req, res) => {
  try {
    const { userId, reason } = req.body;

    if (!userId) {
      return res.status(400).json({ error: "userId is required" });
    }

    const user = await prisma.user.findUnique({
      where: { id: userId }, // 👈 no Number()
    });
    if (!user) return res.status(404).json({ error: "User not found" });

    const deletion = await prisma.deletionRequest.create({
      data: {
        userId, // 👈 keep as string
        reason: reason || null,
      },
    });

    res.json({ success: true, request: deletion });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Internal server error" });
  }
});

export default router;
