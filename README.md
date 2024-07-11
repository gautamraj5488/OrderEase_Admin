# OrderEase_Admin

Welcome to OrderEase_Admin! This Flutter application serves as the admin interface for OrderEase, streamlining menu management for various categories and enhancing the administrative experience in managing and organizing items.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Dependencies](#dependencies)
- [Contributing](#contributing)

## Overview

OrderEase_Admin is a mobile application designed for administrators to efficiently manage menu items across different categories like Fast Food, Veg, Non-Veg, Meal, Starter, and Healthy options. It integrates Firebase for real-time data management and user authentication, ensuring seamless operation and security.

## Features

- **Category Management**: Organize menu items into distinct categories for easy access.
- **Real-time Updates**: Utilize Firebase Firestore for instant updates and synchronization of menu data.
- **User Authentication**: Secure user login and authentication via Firebase Authentication.
- **Intuitive UI**: User-friendly interface with smooth navigation and responsive design.
- **Image Upload**: Upload and manage images for menu items using Firebase Storage.
- **Coupon Management**: Manage discount coupons using the `coupon_uikit` package.
- **Custom Borders**: Assign different borders to containers based on item ratings to enhance visual appeal.

## Installation

To get started with OrderEase_Admin on your local machine, follow these steps:

1. **Clone the repository**:

   ```sh
   git clone https://github.com/gautamraj5488/OrderEase_Admin.git
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

Upon launching OrderEase_Admin, you can manage menu items categorized under various types such as Fast Food, Veg, Non-Veg, Meal, Starter, and Healthy. Use the intuitive interface to add, edit, or delete items, ensuring seamless operation in both online and offline modes.

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

---