import SwiftUI

struct ActiveWorkoutView: View {
    @Environment(\.dismiss) private var dismiss

    let workout: WorkoutPlan

    @State private var currentExerciseIndex = 0
    @State private var isTimerRunning = false
    @State private var timeRemaining = 0
    @State private var timer: Timer?
    @State private var workoutStartTime = Date()
    @State private var showingCompletionView = false

    var currentExercise: Exercise? {
        guard currentExerciseIndex < workout.exercises.count else { return nil }
        return workout.exercises[currentExerciseIndex]
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if showingCompletionView {
                    WorkoutCompletionView(
                        workout: workout,
                        duration: Int(Date().timeIntervalSince(workoutStartTime))
                    )
                } else if let exercise = currentExercise {
                    WorkoutProgressView(
                        currentIndex: currentExerciseIndex,
                        totalExercises: workout.exercises.count
                    )

                    ActiveExerciseView(
                        exercise: exercise,
                        isTimerRunning: $isTimerRunning,
                        timeRemaining: $timeRemaining,
                        onTimerToggle: toggleTimer
                    )

                    WorkoutControlsView(
                        currentIndex: currentExerciseIndex,
                        totalExercises: workout.exercises.count,
                        isTimerRunning: $isTimerRunning,
                        onPrevious: previousExercise,
                        onNext: nextExercise,
                        onFinish: finishWorkout
                    )
                }

                Spacer()
            }
            .padding()
            .navigationTitle(workout.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("End") {
                        endWorkout()
                    }
                }
            }
            .onAppear {
                workoutStartTime = Date()
                if let exercise = currentExercise, let duration = exercise.duration {
                    timeRemaining = duration
                }
            }
            .onDisappear {
                stopTimer()
            }
        }
    }

    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                // Auto-advance to next exercise or finish
                if currentExerciseIndex < workout.exercises.count - 1 {
                    nextExercise()
                } else {
                    finishWorkout()
                }
            }
        }
    }

    private func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func previousExercise() {
        if currentExerciseIndex > 0 {
            stopTimer()
            currentExerciseIndex -= 1
            if let exercise = currentExercise, let duration = exercise.duration {
                timeRemaining = duration
            }
        }
    }

    private func nextExercise() {
        if currentExerciseIndex < workout.exercises.count - 1 {
            stopTimer()
            currentExerciseIndex += 1
            if let exercise = currentExercise, let duration = exercise.duration {
                timeRemaining = duration
            }
        }
    }

    private func finishWorkout() {
        stopTimer()
        showingCompletionView = true
    }

    private func endWorkout() {
        stopTimer()
        dismiss()
    }

    private func toggleTimer() {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
}

struct WorkoutProgressView: View {
    let currentIndex: Int
    let totalExercises: Int

    var progress: Double {
        Double(currentIndex) / Double(totalExercises)
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Exercise \(currentIndex + 1) of \(totalExercises)")
                    .font(.headline)
                    .fontWeight(.medium)

                Spacer()
            }

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .pink))
                .frame(height: 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct ActiveExerciseView: View {
    let exercise: Exercise
    @Binding var isTimerRunning: Bool
    @Binding var timeRemaining: Int
    let onTimerToggle: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text(exercise.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                if exercise.sets > 0 || !exercise.reps.isEmpty {
                    HStack {
                        if exercise.sets > 0 {
                            Text("\(exercise.sets) sets")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }

                        if !exercise.reps.isEmpty {
                            Text("• \(exercise.reps) reps")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            if let duration = exercise.duration, duration > 0 {
                VStack(spacing: 15) {
                    Text("\(timeRemaining)")
                        .font(.system(size: 60, weight: .bold, design: .monospaced))
                        .foregroundColor(.pink)

                    Button(action: onTimerToggle) {
                        HStack {
                            Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                            Text(isTimerRunning ? "Pause" : "Start")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.pink)
                        .cornerRadius(25)
                    }
                }
                .padding()
                .background(Color.pink.opacity(0.1))
                .cornerRadius(20)
            }

            if !exercise.instructions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Instructions")
                        .font(.headline)
                        .fontWeight(.medium)

                    Text(exercise.instructions)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
    }

}

struct WorkoutControlsView: View {
    let currentIndex: Int
    let totalExercises: Int
    @Binding var isTimerRunning: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onFinish: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            Button(action: onPrevious) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .font(.headline)
                .foregroundColor(currentIndex > 0 ? .blue : .gray)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            .disabled(currentIndex == 0)

            if currentIndex < totalExercises - 1 {
                Button(action: onNext) {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(12)
                }
            } else {
                Button(action: onFinish) {
                    HStack {
                        Text("Finish")
                        Image(systemName: "checkmark")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                }
            }
        }
    }
}

struct WorkoutCompletionView: View {
    let workout: WorkoutPlan
    let duration: Int

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            VStack(spacing: 10) {
                Text("Workout Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Great job finishing your \(workout.title) workout!")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 15) {
                HStack {
                    VStack {
                        Text("\(duration / 60)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Minutes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack {
                        Text("\(workout.exercises.count)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Exercises")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack {
                        Text("💪")
                            .font(.title)
                        Text("Completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }

            Text("You're building strength and supporting your wellness journey!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    ActiveWorkoutView(
        workout: WorkoutPlan(
            title: "Sample Workout",
            exercises: [
                Exercise(name: "Push-ups", sets: 3, reps: "10-15", duration: 30),
                Exercise(name: "Squats", sets: 3, reps: "12-20", duration: 45)
            ]
        )
    )
}