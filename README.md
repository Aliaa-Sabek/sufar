<div align="center">

# 🌍 Sufar
### AI-Powered Smart Travel Assistant

An AI-powered travel platform that helps users discover destinations, plan personalized trips, book travel services, and receive intelligent travel recommendations through a modern, user-friendly mobile application.

<p>
<img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white"/>
<img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white"/>
<img src="https://img.shields.io/badge/Python-Flask-3776AB?logo=python&logoColor=white"/>
<img src="https://img.shields.io/badge/MongoDB-Database-47A248?logo=mongodb&logoColor=white"/>
<img src="https://img.shields.io/badge/REST-API-success"/>
<img src="https://img.shields.io/badge/AI-Powered-purple"/>
</p>

</div>

---

# 📖 Overview

**Sufar** is an AI-powered travel assistant developed as a **Computer Science Graduation Project**.

The application provides travelers with a complete digital travel experience by allowing them to:

- 🌍 Explore tourist destinations
- 🏨 Search hotels
- ✈️ Search flights
- 📅 Book travel services
- 🧳 Plan trips with Artificial Intelligence
- 💬 Chat with an AI Assistant
- 🛂 Receive visa guidance
- 🏢 Find travel agencies

The system follows a **Client–Server Architecture**, where the Flutter application communicates with a custom backend through RESTful APIs while all data is managed in a centralized MongoDB database.

---

# ✨ Features

## 👤 User Features

- User Registration
- Secure Login
- Email Verification
- Forgot Password
- Profile Management
- Browse Tourist Destinations
- Destination Details
- Search Hotels
- View Hotel Details
- Search Flights
- Flight Details
- Hotel Booking
- Flight Booking
- Booking History
- AI Trip Planner
- AI Chat Assistant
- Browse Travel Offices
- Visa Advisor
- Save Favorite Destinations
- Dark Mode & Light Mode

---

## 🛠️ Admin Features

- Manage Users
- Manage Destinations
- Manage Hotels
- Manage Flights
- Manage Bookings
- Manage Travel Offices
- Manage Reviews
- Monitor System Content

---

# 🤖 AI Features

- 🤖 AI Chat Assistant
- 🧠 AI Trip Planner
- 🌍 Smart Destination Recommendations
- 📍 Personalized Travel Suggestions

---

# 📱 Application Modules

- Splash Screen
- Authentication
- Home
- Destinations
- Hotels
- Flights
- Booking
- AI Planner
- Chat Bot
- Travel Offices
- Visa Advisor
- Favorites
- User Profile
- Settings

---

# 🏗️ System Architecture

```text
                Flutter Mobile Application
                         │
                    RESTful APIs
                         │
                         ▼
                 Python Flask Backend
                         │
            ┌────────────┴────────────┐
            ▼                         ▼
      MongoDB Database          AI Services
```

---

# 🛠️ Tech Stack

## 📱 Mobile Development

- Flutter
- Dart

## ⚙️ Backend

- Python
- Flask
- RESTful API

## 🗄️ Database

- MongoDB

## ☁️ Cloud Services

- Firebase Core
- Firebase Cloud Messaging
- Firebase Storage

## 🤖 Artificial Intelligence

- AI Trip Planner
- AI Recommendation Engine
- AI Chat Assistant

---

# 📦 Packages & Libraries

### State & Networking

- http
- shared_preferences

### UI

- flutter_svg
- google_fonts
- cached_network_image

### Maps

- flutter_map
- latlong2

### Utilities

- intl
- url_launcher

### Firebase

- firebase_core

---

# 📂 Project Structure

```text
lib/
│
├── ai_planner/
├── auth/
├── booking/
├── chat_bot/
├── config/
├── destinations/
├── flights/
├── home/
├── hotels/
├── models/
├── onboarding/
├── profile/
├── services/
├── theme/
├── travel_offices/
├── visa_advisor/
├── firebase_options.dart
└── main.dart
```

---

# 🌐 Backend API

The application communicates with the backend through RESTful APIs.

### Authentication

- Register
- Login
- Verify Email
- Logout
- Update Profile

### Destinations

- Get Destinations
- Destination Details

### Hotels

- Hotel List
- Hotel Details

### Flights

- Flight Search
- Flight Details

### Bookings

- Create Booking
- Booking History

### Travel Offices

- Travel Office List

### AI Services

- AI Trip Planner
- AI Chat Assistant

---

# 🗄️ Database Collections

The system stores:

- Users
- Destinations
- Hotels
- Flights
- Bookings
- Reviews
- Travel Offices

---

# 🔐 Authentication Flow

```text
Register
    │
    ▼
Email Verification
    │
    ▼
Login
    │
    ▼
JWT Token
    │
    ▼
Access Protected APIs
```

---

# 🚀 Getting Started

## Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Python Backend
- MongoDB

---

## Installation

Clone the repository

```bash
git clone https://github.com/your-username/sufar.git
```

Go to the project

```bash
cd sufar
```

Install dependencies

```bash
flutter pub get
```

Configure the backend API URL.

Run the application

```bash
flutter run
```

---

# 📸 Screenshots

| Home | Hotels | AI Planner |
|------|---------|------------|
| Add Screenshot | Add Screenshot | Add Screenshot |

---

# 📚 Software Engineering Concepts

This project applies several software engineering principles:

- Object-Oriented Programming (OOP)
- Encapsulation
- Inheritance
- Layered Architecture
- Client–Server Architecture
- RESTful API Design
- MVC Principles
- Separation of Concerns
- Modular Design
- Database Normalization

---

# 🚀 Future Enhancements


- 🌤️ Weather Forecast
- 🔔 Push Notifications
- 🌐 Multi-language Support
- 📶 Offline Mode
- 🎤 Voice Assistant
- 📍 Live Location Tracking
- 🤝 Trip Sharing
- 📊 Travel Analytics

---


<div align="center">

## 🌍 Travel Smarter with AI

**Built with Flutter • Python • MongoDB • REST APIs • Artificial Intelligence**

⭐ If you like this project, don't forget to star the repository!

</div>
