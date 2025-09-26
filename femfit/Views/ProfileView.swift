import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query private var journalEntries: [JournalEntry]
    @Query private var workoutPlans: [WorkoutPlan]
    @Query private var mealPlans: [MealPlan]

    @State private var showingEditProfile = false
    @State private var showingInsights = false

    var currentProfile: UserProfile? {
        userProfiles.first
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let profile = currentProfile {
                        ProfileHeaderSection(profile: profile)

                        CycleStatusSection(profile: profile)

                        StatsOverviewSection(
                            journalEntries: journalEntries,
                            workoutPlans: workoutPlans,
                            mealPlans: mealPlans
                        )

                        SettingsSection(
                            showingEditProfile: $showingEditProfile,
                            showingInsights: $showingInsights
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingEditProfile) {
                if let profile = currentProfile {
                    EditProfileView(profile: profile)
                }
            }
            .sheet(isPresented: $showingInsights) {
                if let profile = currentProfile {
                    InsightsView(profile: profile, journalEntries: journalEntries)
                }
            }
        }
    }
}

struct ProfileHeaderSection: View {
    let profile: UserProfile

    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.pink)

            VStack(spacing: 4) {
                Text("Welcome to FemFit!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Age \(profile.age) • \(profile.workoutExperienceYears) years experience")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if !profile.fitnessGoals.isEmpty {
                VStack(spacing: 8) {
                    Text("Fitness Goals")
                        .font(.headline)
                        .fontWeight(.medium)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                        ForEach(profile.fitnessGoals.prefix(3), id: \.self) { goal in
                            Text(goal)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.pink.opacity(0.2))
                                .foregroundColor(.pink)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct CycleStatusSection: View {
    let profile: UserProfile

    var currentCycleInfo: (phase: CyclePhase, day: Int) {
        CycleCalculator.getCurrentPhase(
            lastPeriodDate: profile.lastPeriodDate,
            cycleLength: profile.averageCycleLength
        )
    }

    var nextPeriodDate: Date {
        CycleCalculator.predictNextPeriod(
            lastPeriodDate: profile.lastPeriodDate,
            cycleLength: profile.averageCycleLength
        )
    }

    var daysUntilNext: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: nextPeriodDate).day ?? 0
    }

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Cycle Status")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Phase")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(currentCycleInfo.phase.rawValue)
                        .font(.headline)
                        .foregroundColor(Color(currentCycleInfo.phase.color))
                }

                Spacer()

                VStack(alignment: .center, spacing: 4) {
                    Text("Cycle Day")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(currentCycleInfo.day)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Next Period")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(daysUntilNext) days")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }

            Text(currentCycleInfo.phase.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct StatsOverviewSection: View {
    let journalEntries: [JournalEntry]
    let workoutPlans: [WorkoutPlan]
    let mealPlans: [MealPlan]

    var totalJournalEntries: Int {
        journalEntries.count
    }

    var totalWorkouts: Int {
        workoutPlans.count
    }

    var scheduledWorkouts: Int {
        workoutPlans.filter { $0.isAddedToSchedule }.count
    }

    var totalMealPlans: Int {
        mealPlans.count
    }

    var averageEnergyLevel: Double {
        guard !journalEntries.isEmpty else { return 0 }
        let totalEnergy = journalEntries.reduce(0) { $0 + $1.energy }
        return Double(totalEnergy) / Double(journalEntries.count)
    }

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Your Stats")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    icon: "book.fill",
                    title: "Journal Entries",
                    value: "\(totalJournalEntries)",
                    color: .blue
                )

                StatCard(
                    icon: "figure.strengthtraining.traditional",
                    title: "Workouts Created",
                    value: "\(totalWorkouts)",
                    color: .pink
                )

                StatCard(
                    icon: "calendar.badge.checkmark",
                    title: "Scheduled Workouts",
                    value: "\(scheduledWorkouts)",
                    color: .green
                )

                StatCard(
                    icon: "leaf.fill",
                    title: "Meal Plans",
                    value: "\(totalMealPlans)",
                    color: .orange
                )
            }

            if averageEnergyLevel > 0 {
                HStack {
                    Text("Average Energy Level")
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "%.1f/10", averageEnergyLevel))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SettingsSection: View {
    @Binding var showingEditProfile: Bool
    @Binding var showingInsights: Bool

    var body: some View {
        VStack(spacing: 12) {
            SettingsRow(
                icon: "person.fill",
                title: "Edit Profile",
                action: { showingEditProfile = true }
            )

            SettingsRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "AI Insights",
                action: { showingInsights = true }
            )

            SettingsRow(
                icon: "bell.fill",
                title: "Notifications",
                action: { }
            )

            SettingsRow(
                icon: "questionmark.circle.fill",
                title: "Help & Support",
                action: { }
            )

            SettingsRow(
                icon: "info.circle.fill",
                title: "About FemFit",
                action: { }
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .frame(width: 24)

                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let profile: UserProfile

    @State private var age: Int
    @State private var workoutExperienceYears: Int
    @State private var selectedMajorWorkoutIssues: Set<String>
    @State private var dietType: String
    @State private var workoutDaysPerWeek: Int
    @State private var preferredWorkoutTime: String
    @State private var selectedFitnessGoals: Set<String>
    @State private var lastPeriodDate: Date
    @State private var averageCycleLength: Int

    init(profile: UserProfile) {
        self.profile = profile
        self._age = State(initialValue: profile.age)
        self._workoutExperienceYears = State(initialValue: profile.workoutExperienceYears)
        self._selectedMajorWorkoutIssues = State(initialValue: Set(profile.majorWorkoutIssues))
        self._dietType = State(initialValue: profile.dietType)
        self._workoutDaysPerWeek = State(initialValue: profile.workoutDaysPerWeek)
        self._preferredWorkoutTime = State(initialValue: profile.preferredWorkoutTime)
        self._selectedFitnessGoals = State(initialValue: Set(profile.fitnessGoals))
        self._lastPeriodDate = State(initialValue: profile.lastPeriodDate)
        self._averageCycleLength = State(initialValue: profile.averageCycleLength)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    BasicInfoSection(
                        age: $age,
                        dietType: $dietType
                    )

                    WorkoutInfoSection(
                        workoutExperienceYears: $workoutExperienceYears,
                        workoutDaysPerWeek: $workoutDaysPerWeek,
                        preferredWorkoutTime: $preferredWorkoutTime,
                        selectedMajorWorkoutIssues: $selectedMajorWorkoutIssues
                    )

                    FitnessGoalsSection(
                        selectedFitnessGoals: $selectedFitnessGoals
                    )

                    CycleInfoSection(
                        lastPeriodDate: $lastPeriodDate,
                        averageCycleLength: $averageCycleLength
                    )
                }
                .padding()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveProfile() {
        profile.age = age
        profile.workoutExperienceYears = workoutExperienceYears
        profile.majorWorkoutIssues = Array(selectedMajorWorkoutIssues)
        profile.dietType = dietType
        profile.workoutDaysPerWeek = workoutDaysPerWeek
        profile.preferredWorkoutTime = preferredWorkoutTime
        profile.fitnessGoals = Array(selectedFitnessGoals)
        profile.lastPeriodDate = lastPeriodDate
        profile.averageCycleLength = averageCycleLength

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save profile: \(error)")
        }
    }
}

struct BasicInfoSection: View {
    @Binding var age: Int
    @Binding var dietType: String

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Basic Information")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading) {
                Text("Age")
                    .font(.subheadline)
                TextField("Enter your age", value: $age, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading) {
                Text("Diet Type")
                    .font(.subheadline)
                Picker("Diet Type", selection: $dietType) {
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
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct WorkoutInfoSection: View {
    @Binding var workoutExperienceYears: Int
    @Binding var workoutDaysPerWeek: Int
    @Binding var preferredWorkoutTime: String
    @Binding var selectedMajorWorkoutIssues: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Workout Information")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading) {
                Text("Years working out")
                    .font(.subheadline)
                TextField("Years", value: $workoutExperienceYears, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading) {
                Text("Workouts per week")
                    .font(.subheadline)
                Picker("Workouts per week", selection: $workoutDaysPerWeek) {
                    ForEach(1...7, id: \.self) { number in
                        Text("\(number)").tag(number)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            VStack(alignment: .leading) {
                Text("Preferred workout time")
                    .font(.subheadline)
                Picker("Preferred time", selection: $preferredWorkoutTime) {
                    Text("Morning").tag("morning")
                    Text("Afternoon").tag("afternoon")
                    Text("Evening").tag("evening")
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            VStack(alignment: .leading) {
                Text("Common workout challenges")
                    .font(.subheadline)

                let issues = ["Fatigue", "Cramps", "Low motivation", "Back pain", "Time constraints", "Equipment access"]
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
                    ForEach(issues, id: \.self) { issue in
                        ToggleButton(
                            text: issue,
                            isSelected: selectedMajorWorkoutIssues.contains(issue)
                        ) {
                            if selectedMajorWorkoutIssues.contains(issue) {
                                selectedMajorWorkoutIssues.remove(issue)
                            } else {
                                selectedMajorWorkoutIssues.insert(issue)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct FitnessGoalsSection: View {
    @Binding var selectedFitnessGoals: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Fitness Goals")
                .font(.headline)
                .fontWeight(.semibold)

            let goals = ["Weight loss", "Muscle building", "Endurance", "Flexibility", "Stress relief", "Better sleep", "Overall health"]
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))]) {
                ForEach(goals, id: \.self) { goal in
                    ToggleButton(
                        text: goal,
                        isSelected: selectedFitnessGoals.contains(goal)
                    ) {
                        if selectedFitnessGoals.contains(goal) {
                            selectedFitnessGoals.remove(goal)
                        } else {
                            selectedFitnessGoals.insert(goal)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct CycleInfoSection: View {
    @Binding var lastPeriodDate: Date
    @Binding var averageCycleLength: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Cycle Information")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading) {
                Text("Last period start date")
                    .font(.subheadline)
                DatePicker("Last period", selection: $lastPeriodDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
            }

            VStack(alignment: .leading) {
                Text("Average cycle length (days)")
                    .font(.subheadline)
                Picker("Cycle length", selection: $averageCycleLength) {
                    ForEach(21...35, id: \.self) { days in
                        Text("\(days) days").tag(days)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 120)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}


#Preview {
    ProfileView()
}