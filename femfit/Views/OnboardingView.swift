import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentPage = 0
    @State private var userProfile = UserProfile()

    private let totalPages = 6

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ProgressView(value: Double(currentPage + 1), total: Double(totalPages))
                    .progressViewStyle(LinearProgressViewStyle(tint: .pink))
                    .padding()

                TabView(selection: $currentPage) {
                    WelcomePageView()
                        .tag(0)

                    BasicInfoPageView(userProfile: $userProfile)
                        .tag(1)

                    WorkoutExperiencePageView(userProfile: $userProfile)
                        .tag(2)

                    FitnessGoalsPageView(userProfile: $userProfile)
                        .tag(3)

                    CycleInfoPageView(userProfile: $userProfile)
                        .tag(4)

                    CompletionPageView(userProfile: $userProfile)
                        .tag(5)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(.gray)
                    }

                    Spacer()

                    if currentPage < totalPages - 1 {
                        Button("Next") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .foregroundColor(.pink)
                        .fontWeight(.semibold)
                    } else {
                        Button("Get Started") {
                            completeOnboarding()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.pink)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }

    private func completeOnboarding() {
        userProfile.isOnboarded = true
        modelContext.insert(userProfile)
        try? modelContext.save()
    }
}

struct WelcomePageView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "heart.fill")
                .font(.system(size: 80))
                .foregroundColor(.pink)

            VStack(spacing: 15) {
                Text("Welcome to FemFit")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("Your AI-powered wellness companion designed specifically for women's unique needs throughout their menstrual cycle")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }

            Spacer()

            VStack(spacing: 10) {
                FeatureRow(icon: "calendar", title: "Cycle-Aware Workouts", description: "Workouts that adapt to your cycle phase")
                FeatureRow(icon: "leaf.fill", title: "Personalized Nutrition", description: "Meal plans for every phase")
                FeatureRow(icon: "brain.head.profile", title: "AI Insights", description: "Learn about your patterns")
            }
            .padding()

            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.pink)
                .frame(width: 30)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

struct BasicInfoPageView: View {
    @Binding var userProfile: UserProfile

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("Tell us about yourself")
                    .font(.title)
                    .fontWeight(.bold)

                Text("This helps us personalize your experience")
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Age")
                        .font(.headline)
                    TextField("Enter your age", value: $userProfile.age, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                VStack(alignment: .leading) {
                    Text("Diet Type")
                        .font(.headline)
                    Picker("Diet Type", selection: $userProfile.dietType) {
                        Text("Balanced").tag("balanced")
                        Text("Vegetarian").tag("vegetarian")
                        Text("Vegan").tag("vegan")
                        Text("Keto").tag("keto")
                        Text("Paleo").tag("paleo")
                        Text("Mediterranean").tag("mediterranean")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .padding()

            Spacer()
        }
    }
}

struct WorkoutExperiencePageView: View {
    @Binding var userProfile: UserProfile

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("Your Fitness Journey")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Help us understand your workout experience")
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Years working out")
                        .font(.headline)
                    TextField("Years", value: $userProfile.workoutExperienceYears, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                VStack(alignment: .leading) {
                    Text("Workouts per week")
                        .font(.headline)
                    Picker("Workouts per week", selection: $userProfile.workoutDaysPerWeek) {
                        ForEach(1...7, id: \.self) { number in
                            Text("\(number)").tag(number)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                VStack(alignment: .leading) {
                    Text("Preferred workout time")
                        .font(.headline)
                    Picker("Preferred time", selection: $userProfile.preferredWorkoutTime) {
                        Text("Morning").tag("morning")
                        Text("Afternoon").tag("afternoon")
                        Text("Evening").tag("evening")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                VStack(alignment: .leading) {
                    Text("Common workout challenges")
                        .font(.headline)
                    Text("Select all that apply")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    let issues = ["Fatigue", "Cramps", "Low motivation", "Back pain", "Time constraints", "Equipment access"]
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
                        ForEach(issues, id: \.self) { issue in
                            ToggleButton(
                                text: issue,
                                isSelected: userProfile.majorWorkoutIssues.contains(issue)
                            ) {
                                if userProfile.majorWorkoutIssues.contains(issue) {
                                    userProfile.majorWorkoutIssues.removeAll { $0 == issue }
                                } else {
                                    userProfile.majorWorkoutIssues.append(issue)
                                }
                            }
                        }
                    }
                }
            }
            .padding()

            Spacer()
        }
    }
}

struct FitnessGoalsPageView: View {
    @Binding var userProfile: UserProfile

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("Your Fitness Goals")
                    .font(.title)
                    .fontWeight(.bold)

                Text("What do you want to achieve?")
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading) {
                Text("Select your goals")
                    .font(.headline)

                let goals = ["Weight loss", "Muscle building", "Endurance", "Flexibility", "Stress relief", "Better sleep", "Overall health"]
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))]) {
                    ForEach(goals, id: \.self) { goal in
                        ToggleButton(
                            text: goal,
                            isSelected: userProfile.fitnessGoals.contains(goal)
                        ) {
                            if userProfile.fitnessGoals.contains(goal) {
                                userProfile.fitnessGoals.removeAll { $0 == goal }
                            } else {
                                userProfile.fitnessGoals.append(goal)
                            }
                        }
                    }
                }
            }
            .padding()

            Spacer()
        }
    }
}

struct CycleInfoPageView: View {
    @Binding var userProfile: UserProfile

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("Cycle Information")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Help us sync with your natural rhythm")
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Last period start date")
                        .font(.headline)
                    DatePicker("Last period", selection: $userProfile.lastPeriodDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                }

                VStack(alignment: .leading) {
                    Text("Average cycle length (days)")
                        .font(.headline)
                    Picker("Cycle length", selection: $userProfile.averageCycleLength) {
                        ForEach(21...35, id: \.self) { days in
                            Text("\(days) days").tag(days)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 120)
                }
            }
            .padding()

            Spacer()
        }
    }
}

struct CompletionPageView: View {
    @Binding var userProfile: UserProfile

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            VStack(spacing: 15) {
                Text("You're all set!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("FemFit is now personalized for your unique needs. Let's start your wellness journey!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }

            Spacer()
        }
    }
}

struct ToggleButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.pink : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}

#Preview {
    OnboardingView()
}