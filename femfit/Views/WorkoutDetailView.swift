import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let workout: WorkoutPlan

    @State private var isStartingWorkout = false
    @State private var showingSchedulePicker = false
    @State private var selectedScheduleDate = Date()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    WorkoutHeaderSection(workout: workout)

                    if !workout.exercises.isEmpty {
                        ExercisesSection(exercises: workout.exercises)
                    }

                    WorkoutActionsSection(
                        workout: workout,
                        isStartingWorkout: $isStartingWorkout,
                        showingSchedulePicker: $showingSchedulePicker
                    )
                }
                .padding()
            }
            .navigationTitle("Workout Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingSchedulePicker) {
                ScheduleWorkoutView(
                    workout: workout,
                    selectedDate: $selectedScheduleDate
                )
            }
            .sheet(isPresented: $isStartingWorkout) {
                ActiveWorkoutView(workout: workout)
            }
        }
    }
}

struct WorkoutHeaderSection: View {
    let workout: WorkoutPlan

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)

                    Text(workout.cyclePhase)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(workout.cyclePhase.cyclePhaseColor.opacity(0.2))
                        .foregroundColor(workout.cyclePhase.cyclePhaseColor)
                        .cornerRadius(16)
                }

                Spacer()

                if workout.isAIGenerated {
                    Image(systemName: "sparkles")
                        .foregroundColor(.pink)
                        .font(.title2)
                }
            }

            HStack(spacing: 20) {
                WorkoutStatItem(
                    icon: "clock",
                    value: "\(workout.duration)",
                    unit: "min"
                )

                WorkoutStatItem(
                    icon: "star.fill",
                    value: workout.difficulty,
                    unit: ""
                )

                WorkoutStatItem(
                    icon: "list.number",
                    value: "\(workout.exercises.count)",
                    unit: "exercises"
                )
            }

            if !workout.workoutDescription.isEmpty {
                Text(workout.workoutDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }

            if !workout.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(workout.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }

}

struct WorkoutStatItem: View {
    let icon: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.pink)

            HStack(spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)

                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ExercisesSection: View {
    let exercises: [Exercise]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Exercises")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()
            }

            LazyVStack(spacing: 12) {
                ForEach(Array(exercises.enumerated()), id: \.offset) { index, exercise in
                    ExerciseDetailCard(exercise: exercise, index: index + 1)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct ExerciseDetailCard: View {
    let exercise: Exercise
    let index: Int

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.pink)
                        .cornerRadius(14)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.headline)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)

                        HStack {
                            if exercise.sets > 0 {
                                Text("\(exercise.sets) sets")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            if !exercise.reps.isEmpty {
                                Text("• \(exercise.reps) reps")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            if let duration = exercise.duration {
                                Text("• \(duration)s")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        if !exercise.targetMuscles.isEmpty {
                            Text("Targets: \(exercise.targetMuscles.joined(separator: ", "))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    if !exercise.instructions.isEmpty {
                        Text("Instructions:")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text(exercise.instructions)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    if !exercise.equipment.isEmpty {
                        Text("Equipment: \(exercise.equipment.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if exercise.restTime > 0 {
                        Text("Rest: \(exercise.restTime)s between sets")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.leading, 40)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct WorkoutActionsSection: View {
    let workout: WorkoutPlan
    @Binding var isStartingWorkout: Bool
    @Binding var showingSchedulePicker: Bool

    var body: some View {
        VStack(spacing: 15) {
            Button(action: { isStartingWorkout = true }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Workout")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.pink)
                .cornerRadius(12)
            }

            HStack(spacing: 15) {
                Button(action: { showingSchedulePicker = true }) {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                        Text(workout.isAddedToSchedule ? "Reschedule" : "Schedule")
                    }
                    .font(.subheadline)
                    .foregroundColor(.pink)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.pink, lineWidth: 1)
                    )
                }

                ShareWorkoutButton(workout: workout)
            }
        }
    }
}

struct ShareWorkoutButton: View {
    let workout: WorkoutPlan

    var shareText: String {
        var text = "Check out this \(workout.cyclePhase) phase workout: \(workout.title)\n\n"
        text += "Duration: \(workout.duration) minutes\n"
        text += "Difficulty: \(workout.difficulty)\n"
        text += "Exercises: \(workout.exercises.count)\n\n"

        if !workout.workoutDescription.isEmpty {
            text += "\(workout.workoutDescription)\n\n"
        }

        text += "Generated with FemFit - AI-powered workouts for women's wellness"
        return text
    }

    var body: some View {
        ShareLink(item: shareText) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share")
            }
            .font(.subheadline)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 1)
            )
        }
    }
}

struct ScheduleWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let workout: WorkoutPlan
    @Binding var selectedDate: Date

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Schedule Workout")
                    .font(.title2)
                    .fontWeight(.bold)

                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())

                Spacer()

                Button("Schedule for \(selectedDate.formatted(date: .abbreviated, time: .omitted))") {
                    scheduleWorkout()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.pink)
                .cornerRadius(12)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func scheduleWorkout() {
        workout.isAddedToSchedule = true
        workout.scheduledDate = selectedDate

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to schedule workout: \(error)")
        }
    }
}

#Preview {
    WorkoutDetailView(
        workout: WorkoutPlan(
            title: "Follicular Phase Strength",
            exercises: [
                Exercise(name: "Squats", sets: 3, reps: "12-15"),
                Exercise(name: "Push-ups", sets: 3, reps: "8-12")
            ],
            cyclePhase: "Follicular"
        )
    )
}