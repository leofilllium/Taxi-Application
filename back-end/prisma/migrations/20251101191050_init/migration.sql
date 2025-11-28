-- CreateTable
CREATE TABLE `User` (
    `id` VARCHAR(191) NOT NULL,
    `email` VARCHAR(191) NOT NULL,
    `password` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `user_type` VARCHAR(191) NOT NULL,
    `phone` VARCHAR(191) NOT NULL,
    `isActive` BOOLEAN NOT NULL DEFAULT true,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `User_email_key`(`email`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Driver` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `email` VARCHAR(191) NOT NULL,
    `phone` VARCHAR(191) NOT NULL,
    `profile_image_url` VARCHAR(191) NULL,
    `latitude` DOUBLE NOT NULL DEFAULT 0,
    `longitude` DOUBLE NOT NULL DEFAULT 0,
    `bearing` DOUBLE NOT NULL DEFAULT 0,
    `isAvailable` BOOLEAN NOT NULL DEFAULT false,
    `rating` DOUBLE NOT NULL DEFAULT 5.0,
    `totalRides` INTEGER NOT NULL DEFAULT 0,
    `vehicle_type` VARCHAR(191) NOT NULL,
    `license_plate` VARCHAR(191) NOT NULL,
    `color` VARCHAR(191) NOT NULL,
    `model` VARCHAR(191) NOT NULL,
    `year` INTEGER NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Ride` (
    `id` VARCHAR(191) NOT NULL,
    `client_id` VARCHAR(191) NOT NULL,
    `driver_id` VARCHAR(191) NULL,
    `pickup_latitude` DOUBLE NOT NULL,
    `pickup_longitude` DOUBLE NOT NULL,
    `destination_latitude` DOUBLE NOT NULL,
    `destination_longitude` DOUBLE NOT NULL,
    `pickup_address` VARCHAR(191) NOT NULL,
    `destination_address` VARCHAR(191) NOT NULL,
    `ride_type` VARCHAR(191) NOT NULL DEFAULT 'standard',
    `payment_method` VARCHAR(191) NOT NULL DEFAULT 'cash',
    `notes` VARCHAR(191) NULL,
    `status` VARCHAR(191) NOT NULL DEFAULT 'pending',
    `estimated_price` DOUBLE NOT NULL,
    `final_price` DOUBLE NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,
    `accepted_at` DATETIME(3) NULL,
    `completed_at` DATETIME(3) NULL,
    `started_at` DATETIME(3) NULL,
    `cancelled_at` DATETIME(3) NULL,
    `cancellation_reason` VARCHAR(191) NULL,
    `driver_arrived_at` DATETIME(3) NULL,
    `distance` DOUBLE NULL,
    `duration` INTEGER NULL,
    `route_polyline` VARCHAR(191) NULL,
    `route_steps` JSON NULL,
    `eta` INTEGER NULL,
    `service_type` VARCHAR(191) NOT NULL DEFAULT 'ride',
    `recipient_name` VARCHAR(191) NULL,
    `recipient_phone` VARCHAR(191) NULL,
    `package_details` VARCHAR(191) NULL,
    `is_fragile` BOOLEAN NULL DEFAULT false,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Rating` (
    `id` VARCHAR(191) NOT NULL,
    `ride_id` VARCHAR(191) NOT NULL,
    `from_user_id` VARCHAR(191) NOT NULL,
    `to_user_id` VARCHAR(191) NOT NULL,
    `rating` INTEGER NOT NULL,
    `comment` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `DeletionRequest` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `userId` VARCHAR(191) NOT NULL,
    `reason` VARCHAR(191) NULL,
    `status` VARCHAR(191) NOT NULL DEFAULT 'pending',
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `processedAt` DATETIME(3) NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `Driver` ADD CONSTRAINT `Driver_id_fkey` FOREIGN KEY (`id`) REFERENCES `User`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Ride` ADD CONSTRAINT `Ride_client_id_fkey` FOREIGN KEY (`client_id`) REFERENCES `User`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Ride` ADD CONSTRAINT `Ride_driver_id_fkey` FOREIGN KEY (`driver_id`) REFERENCES `Driver`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Rating` ADD CONSTRAINT `Rating_ride_id_fkey` FOREIGN KEY (`ride_id`) REFERENCES `Ride`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Rating` ADD CONSTRAINT `Rating_from_user_id_fkey` FOREIGN KEY (`from_user_id`) REFERENCES `User`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Rating` ADD CONSTRAINT `Rating_to_user_id_fkey` FOREIGN KEY (`to_user_id`) REFERENCES `Driver`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `DeletionRequest` ADD CONSTRAINT `DeletionRequest_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `User`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;
