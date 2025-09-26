# FemFit - AI-Powered Wellness for Women

FemFit is a native iOS app designed specifically for women's wellness, providing AI-powered workout and nutrition recommendations based on menstrual cycle phases, personal goals, and daily patterns.

## 🌟 Features

### Core Functionality
- **Cycle-Aware Workouts**: AI-generated workouts tailored to your menstrual cycle phase
- **Personalized Nutrition**: Meal plans that support hormonal health throughout your cycle
- **Smart Calendar**: Visual cycle tracking with workout and meal scheduling
- **Journal & Mood Tracking**: Daily wellness metrics and pattern recognition
- **AI Insights**: Personalized analysis of your health patterns and recommendations

### Key Components
- **Onboarding**: Comprehensive setup for personalized experience
- **Calendar View**: Main dashboard showing cycle phases and scheduled activities
- **Workout Management**: Create, schedule, and track AI-generated workouts
- **Nutrition Planning**: Generate and manage cycle-specific meal plans
- **Journal**: Daily tracking of mood, symptoms, energy, and wellness metrics
- **Profile & Insights**: User settings and AI-powered pattern analysis

## 🏗️ Technical Architecture

### Framework & Tools
- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Core Data successor for local data persistence
- **OpenAI API**: GPT-4 integration for AI-powered recommendations
- **iOS 17.0+**: Target deployment

### Project Structure
```
FemFit/
├── FemFitApp.swift                 # App entry point
├── ContentView.swift               # Main navigation
├── Models/                         # Data models
│   ├── UserProfile.swift
│   ├── CycleData.swift
│   ├── JournalEntry.swift
│   ├── WorkoutPlan.swift
│   └── MealPlan.swift
├── Views/                          # SwiftUI views
│   ├── OnboardingView.swift
│   ├── CalendarView.swift
│   ├── WorkoutViews/
│   ├── MealPlanViews/
│   ├── JournalViews/
│   └── ProfileView.swift
├── Services/                       # API integrations
│   └── OpenAIService.swift
└── Assets.xcassets                # App resources
```

### Data Models

#### UserProfile
- Basic info (age, diet type, fitness goals)
- Workout preferences and experience
- Cycle information (last period, cycle length)
- Onboarding status

#### JournalEntry
- Daily wellness metrics (energy, sleep, stress)
- Mood and symptom tracking
- Cycle day and phase information
- Free-form journal text

#### WorkoutPlan & Exercise
- AI-generated workout routines
- Exercise details (sets, reps, instructions)
- Cycle phase optimization
- Scheduling and favorites

#### MealPlan & Meal
- Nutrition plans with macro tracking
- Phase-specific nutritional focus
- Meal preparation details
- Dietary restriction support

## 🤖 AI Integration

### OpenAI GPT-4 Integration
The app uses OpenAI's GPT-4 model to generate personalized content:

1. **Workout Generation**: Creates exercise routines based on:
   - Current menstrual cycle phase
   - User fitness level and goals
   - Recent energy levels and symptoms
   - Workout preferences and limitations

2. **Nutrition Planning**: Develops meal plans considering:
   - Cycle phase nutritional needs
   - Dietary preferences and restrictions
   - Caloric and macro requirements
   - Symptom management through food

3. **Personalized Insights**: Analyzes journal data to provide:
   - Pattern recognition across cycles
   - Health trend identification
   - Personalized recommendations
   - Wellness journey feedback

### API Configuration
1. Create a `Config.plist` file with your OpenAI API key:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>OPENAI_API_KEY</key>
    <string>your_openai_api_key_here</string>
</dict>
</plist>
```

## 🎨 Design Philosophy

### Modern iOS Design
- Clean, minimal interface following iOS Human Interface Guidelines
- Accessibility-first approach with proper contrast and font sizing
- Intuitive navigation with clear visual hierarchy
- Responsive design for various iPhone and iPad sizes

### Color Psychology
- **Pink**: Primary brand color, representing femininity and empowerment
- **Phase Colors**:
  - Red (Menstrual): Rest and self-care
  - Green (Follicular): Growth and new beginnings
  - Orange (Ovulatory): Peak energy and performance
  - Purple (Luteal): Preparation and mindfulness

### User Experience
- Progressive disclosure to avoid overwhelming users
- Smart defaults based on user profile and patterns
- Seamless AI integration that feels natural and helpful
- Clear feedback for all user actions

## 📱 Installation & Setup

### Requirements
- Xcode 15.0+
- iOS 17.0+
- OpenAI API key

### Setup Steps
1. Clone the repository
2. Open `FemFit.xcodeproj` in Xcode
3. Add your OpenAI API key to `Config.plist`
4. Build and run the project

### First Launch
1. Complete the onboarding flow
2. Set up your profile with basic information
3. Enter your cycle information for accurate phase tracking
4. Start journaling to enable AI insights
5. Generate your first AI-powered workout or meal plan

## 🔮 Future Enhancements

### Planned Features
- **Apple Health Integration**: Sync with HealthKit for comprehensive data
- **Wearable Support**: Apple Watch app for workout tracking
- **Social Features**: Community support and shared experiences
- **Advanced Analytics**: Detailed cycle and wellness trend analysis
- **Telemedicine Integration**: Connect with healthcare providers

### Technical Improvements
- **Offline Mode**: Core functionality without internet connection
- **Widget Support**: Home screen widgets for quick cycle info
- **Siri Integration**: Voice commands for logging and scheduling
- **Core ML**: On-device AI for enhanced privacy

## 🔒 Privacy & Security

FemFit prioritizes user privacy and data security:

- **Local Data Storage**: All personal data stored locally using SwiftData
- **Secure API Communication**: Encrypted HTTPS connections to OpenAI
- **No Data Selling**: Your health data is never shared or sold
- **Transparent AI**: Clear indication when AI features are being used
- **User Control**: Full control over data sharing and deletion

## 📧 Support & Feedback

For support, feature requests, or bug reports:
- Create an issue in the GitHub repository
- Email: support@femfit.app
- Follow development updates: [@FemFitApp](https://twitter.com/femfitapp)

## 📄 License

FemFit is open source under the MIT License. See LICENSE file for details.

---

**FemFit** - Empowering women's wellness through AI-driven personalization and cycle awareness. 💪🌸# femfit-swiftapp
