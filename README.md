# 🍽️ AI Meal Planner

An intelligent Flutter-based meal planning application powered by AI that creates personalized meal plans, tracks nutrition, and generates shopping lists based on your dietary preferences and health goals.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

### 🤖 AI-Powered Meal Suggestions

- Get personalized meal recommendations based on your dietary preferences
- Interactive AI chat for meal ideas and nutrition advice
- Real-time streaming responses for a seamless experience

### 📅 Weekly Meal Planning

- Auto-generate complete weekly meal plans
- Calendar view with meal slots (Breakfast, Lunch, Snacks, Dinner)
- Track daily completion progress

### 🎯 Personalized Nutrition Tracking

- BMI calculation and health insights
- Calorie targets using Mifflin-St Jeor equation
- Protein and macro recommendations
- Support for weight loss, maintenance, or gain goals

### 🛒 Smart Shopping Lists

- Auto-generated shopping lists from meal plans
- Category-organized items
- Easy check-off functionality

### 👤 Comprehensive User Profiles

- Detailed onboarding flow
- Support for multiple diet types (Vegetarian, Vegan, Non-Veg, Eggetarian, Pescatarian)
- Allergy and food preference management
- Cooking skill level and time preferences
- Budget-conscious meal planning (INR)

### 🔥 Gamification & Streaks

- Daily meal logging streaks
- Progress tracking and achievements
- Visual completion rings

## 📱 Screenshots

_Coming soon_

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10 or higher
- Dart 3.10 or higher

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/karanxa1/any-feast.git
   cd any-feast
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── config/
│   └── theme.dart          # App theme and colors
├── models/
│   ├── daily_log.dart      # Daily meal tracking
│   ├── meal.dart           # Meal data model
│   ├── meal_plan.dart      # Weekly meal plan model
│   ├── shopping_item.dart  # Shopping list item
│   └── user_profile.dart   # User preferences & settings
├── providers/
│   └── app_provider.dart   # State management
├── screens/
│   ├── ai_suggest_screen.dart      # AI chat & suggestions
│   ├── home_screen.dart            # Dashboard
│   ├── meal_plan_screen.dart       # Weekly calendar
│   ├── onboarding_screen.dart      # User setup
│   ├── profile_screen.dart         # User settings
│   └── shopping_list_screen.dart   # Shopping list
├── services/
│   ├── ai_service.dart      # AI integration
│   └── database_service.dart # Local data persistence
└── main.dart
```

## 🛠️ Tech Stack

| Technology               | Purpose                     |
| ------------------------ | --------------------------- |
| **Flutter**              | Cross-platform UI framework |
| **Provider**             | State management            |
| **SQLite**               | Local database storage      |
| **HTTP**                 | API communication           |
| **Table Calendar**       | Calendar widget             |
| **Google Generative AI** | AI-powered suggestions      |

## 📦 Dependencies

- `provider` - State management
- `sqflite` - Local SQLite database
- `google_generative_ai` - AI integration
- `table_calendar` - Calendar UI
- `flutter_slidable` - Swipe actions
- `shared_preferences` - Local preferences
- `intl` - Date formatting
- `http` - HTTP requests

## 🎨 Design

The app features a modern, vibrant design with:

- Gradient-based UI elements
- Smooth animations and transitions
- Custom progress rings
- Responsive layouts for all screen sizes

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Karan**

---

<p align="center">Made with ❤️ and Flutter</p>
