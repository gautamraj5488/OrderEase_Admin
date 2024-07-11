# OrderEase_Admin

Welcome to OrderEase_Admin! This Flutter application serves as the admin interface for OrderEase, providing comprehensive features to manage menu items, handle orders, and monitor various aspects of the business efficiently.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Firestore Structure](#firestore-structure)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Overview

OrderEase_Admin is a mobile application designed for administrators to efficiently manage menu items across different categories like Fast Food, Veg, Non-Veg, Meal, Starter, and Healthy options. It integrates Firebase for real-time data management, user authentication, and notifications, ensuring seamless operation and security.

## Features

- **Phone Number OTP Verification**: Secure login using OTP sent to the admin's phone number.
- **Google Sign-In**: Easy login using Google accounts.
- **Profile Completion**: Ensure complete profile information for all admins.
- **Total Revenue**: View the total revenue generated.
- **Pending Revenue**: Track the pending revenue that is yet to be completed.
- **Current Status Change**: Update the current status of orders.
- **Gmail Notification**: Receive notifications via Gmail for important updates.
- **Number of Orders**: Monitor the number of orders placed.
- **All Orders**: View and manage all orders in the system.
- **Menu Updation**: Add menu items.
- **Coupons**: Manage discount coupons.
- **Feedbacks**: View customer feedback.
- **Logout**: Securely log out from the admin interface.
- **Profile Updation**: Update admin profile information.

## Installation

To get started with OrderEase_Admin on your local machine, follow these steps:

1. **Clone the repository**:

   ```sh
   git clone https://github.com/gautamraj5488/OrderEase_Admin
   cd OrderEase_Admin
   ```

2. **Install dependencies**:

   ```sh
   flutter pub get
   ```

3. **Set up Firebase**:

   - Follow Firebase setup instructions to add Firebase to your Flutter project.
   - Place your `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) files in the appropriate directories.

4. **Run the app**:

   ```sh
   flutter run
   ```

## Usage

Upon launching OrderEase_Admin, you can manage menu items categorized under various types such as Fast Food, Veg, Non-Veg, Meal, Starter, and Healthy. Use the intuitive interface to add, edit, or delete items, track orders, manage revenues, and handle customer feedback.

## Firestore Structure

Here's the detailed Firestore structure used in the app:

### admins (collection)

### feedback (collection)

#### feedbackId (document)
- `createdAt`: timestamp
- `customerId`: string
- `feedbackText`: string
- `items`: array
- `orderId`: string
- `rating`: number
- `shopId`: string

### orders (collection)

#### orderId (document)
- `createdAt`: timestamp
- `estimatedWaitTime`: string
- `items`: array of maps
   - `imageUrl`: string
   - `itemId`: string
   - `name`: string
   - `price`: number
   - `quantity`: number
- `orderId`: string
- `paymentMethod`: string
- `shopId`: string
- `status`: string
- `tableNumber`: string
- `totalBill`: number
- `userId`: string

### shops (collection)

#### shopId (document)
- `coupons`: sub-collection
- `items`: sub-collection
   - `avgRating`: string
   - `imageUrl`: string
   - `numberOfTables`: number
   - `shopId`: string
   - `shopName`: string

### users (collection)

#### userId (document)
- `cart`: array of maps
   - `imageUrl`: string
   - `itemId`: string
   - `name`: string
   - `price`: number
   - `quantity`: number
- `createdAt`: timestamp
- `email`: string
- `phoneNumber`: string
- `uid`: string

## Dependencies

OrderEase_Admin relies on several dependencies to function properly:

- **flutter**: The framework for building the app.
- **firebase_core**: Firebase Flutter plugin for initializing Firebase core libraries.
- **cloud_firestore**: Firebase plugin for Flutter, adding Cloud Firestore support.
- **firebase_auth**: Firebase plugin for Flutter, providing authentication support.
- **firebase_storage**: Firebase plugin for Flutter, providing cloud storage support.
- **google_sign_in**: Plugin for Google Sign-In.
- **google_fonts**: Access to Google Fonts in the Flutter app.
- **coupon_uikit**: Package for managing coupons.

## Contributing

Contributions to OrderEase_Admin are welcome! To contribute, follow these steps:

1. **Fork the repository**.
2. **Create a new branch**:

   ```sh
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes and commit them**:

   ```sh
   git commit -m "Add some feature"
   ```

4. **Push to the branch**:

   ```sh
   git push origin feature/your-feature-name
   ```

5. **Open a pull request**.

Please ensure your code follows the established coding standards and passes all tests.

## Contact

Gautam Raj - gautam_r@ce.iitr.ac.in

Project Link: [OrderEase_Admin](https://github.com/gautamraj5488/OrderEase_Admin)

---
