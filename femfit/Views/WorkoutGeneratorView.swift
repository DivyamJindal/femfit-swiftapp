import SwiftUI
import SwiftData

struct WorkoutGeneratorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let currentPhase: CyclePhase
    let userProfile: UserProfile
    let journalEntries: [JournalEntry]
    let aiService: OpenAIService

    @State private var isGenerating = false
    @State private var generatedWorkout: WorkoutPlan?
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    PhaseInfoSection(phase: currentPhase)

                    if isGenerating {
                        GeneratingSection()
                    } else if let workout = generatedWorkout {
                        GeneratedWorkoutSection(workout: workout)
                    } else {
                        GeneratePromptSection()
                    }

                    if let error = errorMessage {
                        ErrorSection(message: error)
                    }
                }
                .padding()
            }
            .navigationTitle("AI Workout Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if generatedWorkout != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add to Schedule") {
                            addWorkoutToSchedule()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
        .onAppear {
            generateWorkout()
        }
    }

    private func generateWorkout() {
        isGenerating = true
        errorMessage = nil

        Task {
            do {
                let workout = try await aiService.generateWorkout(
                    for: currentPhase,
                    userProfile: userProfile,
                    journalEntries: journalEntries
                )

                await MainActor.run {
                    self.generatedWorkout = workout
                    self.isGenerating = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to generate workout. Please try again."
                    self.isGenerating = false
                }
            }
        }
    }

    private func addWorkoutToSchedule() {
        guard let workout = generatedWorkout else { return }

        workout.isAddedToSchedule = true
        workout.scheduledDate = Date()
        modelContext.insert(workout)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save workout to schedule."
        }
    }
}

struct PhaseInfoSection: View {
    let phase: CyclePhase

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(Color(phase.color))

                Text("\(phase.rawValue) Phase Workout")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
            }

            Text(phase.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)

            VStack(alignment: .leading, spacing: 8) {
                Text("Recommended for this phase:")
                    .font(.subheadline)
                    .fontWeight(.medium)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                    ForEach(phase.workoutRecommendations.prefix(4), id: \.self) { recommendation in
                        Text(recommendation)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(phase.color).opacity(0.2))
                            .cornerRadius(8)
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

struct GeneratingSection: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Generating your personalized workout...")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("This may take a few moments while our AI analyzes your cycle phase, fitness goals, and recent patterns.")
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

struct GeneratePromptSection: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.pink)

            Text("AI Workout Generation")
                .font(.title2)
                .fontWeight(.bold)

            Text("We'll create a personalized workout based on your current cycle phase, fitness goals, and recent activity patterns.")
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

struct GeneratedWorkoutSection: View {
    let workout: WorkoutPlan

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text(workout.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                HStack {
                    Label("\(workout.duration) min", systemImage: "clock")
                    Spacer()
                    Label(workout.difficulty, systemImage: "star.fill")
                    Spacer()
                    Label("\(workout.exercises.count) exercises", systemImage: "list.number")
                }
                .font(.caption)
                .foregroundColor(.secondary)

                if !workout.workoutDescription.isEmpty {
                    Text(workout.workoutDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            LazyVStack(spacing: 12) {
                ForEach(Array(workout.exercises.enumerated()), id: \.offset) { index, exercise in
                    ExerciseRow(exercise: exercise, index: index + 1)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    let index: Int

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(index)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.pink)
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                    .fontWeight(.medium)

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

                if !exercise.instructions.isEmpty {
                    Text(exercise.instructions)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ErrorSection: View {
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)

            Text(message)
                .font(.body)
                .foregroundColor(.red)

            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    WorkoutGeneratorView(
        currentPhase: .follicular,
        userProfile: UserProfile(),
        journalEntries: [],
        aiService: OpenAIService()
    )
}