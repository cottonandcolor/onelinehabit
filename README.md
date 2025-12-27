# One Line Habit 📱

A beautiful, minimalist habit tracker for iOS built with SwiftUI and SwiftData.

![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-orange)
![SwiftData](https://img.shields.io/badge/SwiftData-Persistent-green)

## ✨ Features

- **Beautiful Dark UI** — Modern gradient design with purple accents
- **SwiftData Persistence** — Your habits are saved automatically
- **Streak Tracking** — Track your daily streaks 🔥
- **Calendar History** — View your completion history by month
- **Voice Input** — Add habits using your voice 🎤
- **Siri Shortcuts** — "Hey Siri, add habit..."
- **Haptic Feedback** — Satisfying vibrations on interactions
- **Particle Animations** — Delightful completion effects

## 📱 Screenshots

| Home | Calendar | Add Habit |
|------|----------|-----------|
| Stats & habit list | Monthly history view | Voice or text input |

## 🛠 Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 📦 Installation

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/OneLineHabit.git
```

2. Open `One Line Habit.xcodeproj` in Xcode

3. Build and run on your device or simulator

## 🏗 Architecture

```
One Line Habit/
├── One_Line_HabitApp.swift    # App entry point & SwiftData setup
├── ContentView.swift          # Main view with habit list
├── Habit.swift                # Habit model with streak calculations
├── HabitCompletion.swift      # Completion tracking by date
├── HabitRowView.swift         # Individual habit row with animations
├── CalendarView.swift         # Calendar history view
├── HabitIntents.swift         # Siri Shortcuts integration
└── SpeechRecognizer.swift     # Voice input handling
```

## 🎯 Core Features

### Habit Tracking
- Add, complete, and delete habits
- Swipe to delete
- Reset all habits for a new day

### Streak System
- Current streak calculation
- Best streak tracking
- Visual streak banner

### Calendar View
- Monthly calendar with completion dots
- Filter by individual habit
- Navigate between months
- Color-coded completion status

### Voice Features
- In-app microphone for voice input
- Siri Shortcuts integration

## 🎨 Design

- **Colors:** Deep indigo/violet gradient background
- **Typography:** SF Rounded for a friendly feel
- **Animations:** Spring physics for natural motion
- **Dark Mode:** Fully optimized for dark theme

## 📄 License

This project is available under the MIT License.

## 👩‍💻 Author

Created by Preeti Dave

---

⭐ If you like this project, give it a star on GitHub!

