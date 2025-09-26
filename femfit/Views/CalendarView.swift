import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query private var workoutPlans: [WorkoutPlan]
    @Query private var mealPlans: [MealPlan]
    @Query private var journalEntries: [JournalEntry]

    @State private var selectedDate = Date()
    @State private var showingWorkoutGenerator = false
    @State private var showingMealPlanGenerator = false
    @StateObject private var aiService = OpenAIService()

    var currentProfile: UserProfile? {
        userProfiles.first
    }

    var currentCycleInfo: (phase: CyclePhase, day: Int) {
        guard let profile = currentProfile else {
            return (.follicular, 1)
        }
        return CycleCalculator.getCurrentPhase(
            lastPeriodDate: profile.lastPeriodDate,
            cycleLength: profile.averageCycleLength
        )
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    CycleInfoCard(
                        currentPhase: currentCycleInfo.phase,
                        currentDay: currentCycleInfo.day,
                        profile: currentProfile
                    )

                    CalendarGridView(selectedDate: $selectedDate)

                    DayDetailsCard(
                        selectedDate: selectedDate,
                        workoutPlans: workoutPlans,
                        mealPlans: mealPlans,
                        journalEntries: journalEntries
                    )

                    AIGenerationSection(
                        currentPhase: currentCycleInfo.phase,
                        showingWorkoutGenerator: $showingWorkoutGenerator,
                        showingMealPlanGenerator: $showingMealPlanGenerator
                    )
                }
                .padding()
            }
            .navigationTitle("Your Cycle")
            .sheet(isPresented: $showingWorkoutGenerator) {
                WorkoutGeneratorView(
                    currentPhase: currentCycleInfo.phase,
                    userProfile: currentProfile!,
                    journalEntries: journalEntries,
                    aiService: aiService
                )
            }
            .sheet(isPresented: $showingMealPlanGenerator) {
                MealPlanGeneratorView(
                    currentPhase: currentCycleInfo.phase,
                    userProfile: currentProfile!,
                    journalEntries: journalEntries,
                    aiService: aiService
                )
            }
        }
    }
}

struct CycleInfoCard: View {
    let currentPhase: CyclePhase
    let currentDay: Int
    let profile: UserProfile?

    var nextPeriodDate: Date {
        guard let profile = profile else { return Date() }
        return CycleCalculator.predictNextPeriod(
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
                VStack(alignment: .leading, spacing: 5) {
                    Text("Day \(currentDay)")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("\(currentPhase.rawValue) Phase")
                        .font(.headline)
                        .foregroundColor(currentPhase.color)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
                    Text("Next period in")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(daysUntilNext) days")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }

            Text(currentPhase.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)

            HStack {
                ForEach(CyclePhase.allCases, id: \.self) { phase in
                    Rectangle()
                        .fill(phase == currentPhase ? Color(phase.color) : Color.gray.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct CalendarGridView: View {
    @Binding var selectedDate: Date
    @State private var currentMonth = Date()

    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }

    var body: some View {
        VStack {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(monthFormatter.string(from: currentMonth))
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }

                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        CalendarDayView(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            isToday: Calendar.current.isDate(date, inSameDayAs: Date())
                        ) {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }

    private var daysInMonth: [Date?] {
        guard let monthRange = Calendar.current.range(of: .day, in: .month, for: currentMonth) else {
            return []
        }

        let firstDayOfMonth = Calendar.current.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1

        var days: [Date?] = Array(repeating: nil, count: firstWeekday)

        for day in monthRange {
            if let date = Calendar.current.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }

        return days
    }

    private func previousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }

    private func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void

    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }

    var body: some View {
        Button(action: action) {
            Text(dayFormatter.string(from: date))
                .font(.system(size: 16, weight: isToday ? .bold : .medium))
                .foregroundColor(
                    isSelected ? .white :
                    isToday ? .pink : .primary
                )
                .frame(width: 40, height: 40)
                .background(
                    isSelected ? Color.pink :
                    isToday ? Color.pink.opacity(0.2) : Color.clear
                )
                .cornerRadius(20)
        }
    }
}

struct DayDetailsCard: View {
    let selectedDate: Date
    let workoutPlans: [WorkoutPlan]
    let mealPlans: [MealPlan]
    let journalEntries: [JournalEntry]

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }

    private var workoutsForDay: [WorkoutPlan] {
        workoutPlans.filter { plan in
            guard let scheduledDate = plan.scheduledDate else { return false }
            return Calendar.current.isDate(scheduledDate, inSameDayAs: selectedDate)
        }
    }

    private var mealsForDay: [MealPlan] {
        mealPlans.filter { plan in
            guard let scheduledDate = plan.scheduledDate else { return false }
            return Calendar.current.isDate(scheduledDate, inSameDayAs: selectedDate)
        }
    }

    private var journalForDay: JournalEntry? {
        journalEntries.first { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(dateFormatter.string(from: selectedDate))
                .font(.headline)
                .fontWeight(.semibold)

            if workoutsForDay.isEmpty && mealsForDay.isEmpty && journalForDay == nil {
                Text("No activities planned for this day")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                if !workoutsForDay.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Workouts", systemImage: "figure.strengthtraining.traditional")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        ForEach(workoutsForDay, id: \.id) { workout in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(workout.title)
                                        .font(.body)
                                    Text("\(workout.duration) min • \(workout.difficulty)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Circle()
                                    .fill(Color(workout.cyclePhase.lowercased() == "menstrual" ? "red" :
                                               workout.cyclePhase.lowercased() == "follicular" ? "green" :
                                               workout.cyclePhase.lowercased() == "ovulatory" ? "orange" : "purple"))
                                    .frame(width: 12, height: 12)
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                if !mealsForDay.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Nutrition", systemImage: "leaf.fill")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        ForEach(mealsForDay, id: \.id) { mealPlan in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(mealPlan.title)
                                        .font(.body)
                                    Text("\(mealPlan.totalCalories) cal • \(mealPlan.meals.count) meals")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 12, height: 12)
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                if let journal = journalForDay {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Journal", systemImage: "book.fill")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        HStack {
                            VStack(alignment: .leading) {
                                Text("Energy: \(journal.energy)/10")
                                    .font(.caption)
                                if !journal.moods.isEmpty {
                                    Text("Moods: \(journal.moods.joined(separator: ", "))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 12, height: 12)
                        }
                        .padding(.horizontal)
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

struct AIGenerationSection: View {
    let currentPhase: CyclePhase
    @Binding var showingWorkoutGenerator: Bool
    @Binding var showingMealPlanGenerator: Bool

    var body: some View {
        VStack(spacing: 15) {
            Text("Generate for \(currentPhase.rawValue) Phase")
                .font(.headline)
                .fontWeight(.semibold)

            HStack(spacing: 15) {
                Button(action: { showingWorkoutGenerator = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 24))

                        Text("AI Workout")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(12)
                }

                Button(action: { showingMealPlanGenerator = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 24))

                        Text("AI Nutrition")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}


#Preview {
    CalendarView()
}