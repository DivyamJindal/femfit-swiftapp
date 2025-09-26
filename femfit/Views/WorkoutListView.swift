import SwiftUI
import SwiftData

struct WorkoutListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutPlan.dateCreated, order: .reverse) private var allWorkouts: [WorkoutPlan]

    @State private var selectedFilter: WorkoutFilter = .all
    @State private var showingWorkoutDetail = false
    @State private var selectedWorkout: WorkoutPlan?

    var filteredWorkouts: [WorkoutPlan] {
        switch selectedFilter {
        case .all:
            return allWorkouts
        case .scheduled:
            return allWorkouts.filter { $0.isAddedToSchedule }
        case .favorites:
            return allWorkouts.filter { $0.tags.contains("Favorite") }
        case .ai:
            return allWorkouts.filter { $0.isAIGenerated }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                FilterBarView(selectedFilter: $selectedFilter)

                if filteredWorkouts.isEmpty {
                    EmptyWorkoutListView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredWorkouts, id: \.id) { workout in
                                WorkoutCard(workout: workout) {
                                    selectedWorkout = workout
                                    showingWorkoutDetail = true
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Workouts")
            .sheet(isPresented: $showingWorkoutDetail) {
                if let workout = selectedWorkout {
                    WorkoutDetailView(workout: workout)
                }
            }
        }
    }
}

enum WorkoutFilter: String, CaseIterable {
    case all = "All"
    case scheduled = "Scheduled"
    case favorites = "Favorites"
    case ai = "AI Generated"

    var systemImage: String {
        switch self {
        case .all:
            return "list.bullet"
        case .scheduled:
            return "calendar"
        case .favorites:
            return "heart.fill"
        case .ai:
            return "sparkles"
        }
    }
}

struct FilterBarView: View {
    @Binding var selectedFilter: WorkoutFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(WorkoutFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        systemImage: filter.systemImage,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
}

struct FilterChip: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.pink : Color(.systemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyWorkoutListView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            VStack(spacing: 8) {
                Text("No Workouts Yet")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Generate AI-powered workouts from the Calendar tab to get started!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
    }
}

struct WorkoutCard: View {
    let workout: WorkoutPlan
    let action: () -> Void

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)

                        Text(workout.cyclePhase)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(workout.cyclePhase.cyclePhaseColor.opacity(0.2))
                            .foregroundColor(workout.cyclePhase.cyclePhaseColor)
                            .cornerRadius(8)
                    }

                    Spacer()

                    Menu {
                        Button {
                            toggleFavorite()
                        } label: {
                            Label(
                                workout.tags.contains("Favorite") ? "Remove from Favorites" : "Add to Favorites",
                                systemImage: workout.tags.contains("Favorite") ? "heart.slash" : "heart"
                            )
                        }

                        Button {
                            toggleScheduled()
                        } label: {
                            Label(
                                workout.isAddedToSchedule ? "Remove from Schedule" : "Add to Schedule",
                                systemImage: workout.isAddedToSchedule ? "calendar.badge.minus" : "calendar.badge.plus"
                            )
                        }

                        Button(role: .destructive) {
                            deleteWorkout()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                }

                HStack {
                    Label("\(workout.duration) min", systemImage: "clock")
                    Label(workout.difficulty, systemImage: "star.fill")
                    Label("\(workout.exercises.count) exercises", systemImage: "list.number")
                }
                .font(.caption)
                .foregroundColor(.secondary)

                if !workout.workoutDescription.isEmpty {
                    Text(workout.workoutDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                HStack {
                    ForEach(workout.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }

                    Spacer()

                    if workout.isAddedToSchedule {
                        Image(systemName: "calendar.badge.checkmark")
                            .foregroundColor(.green)
                            .font(.caption)
                    }

                    if workout.tags.contains("Favorite") {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }


    private func toggleFavorite() {
        if workout.tags.contains("Favorite") {
            workout.tags.removeAll { $0 == "Favorite" }
        } else {
            workout.tags.append("Favorite")
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to save favorite status: \(error)")
        }
    }

    private func toggleScheduled() {
        workout.isAddedToSchedule.toggle()
        if workout.isAddedToSchedule && workout.scheduledDate == nil {
            workout.scheduledDate = Date()
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to save scheduled status: \(error)")
        }
    }

    private func deleteWorkout() {
        modelContext.delete(workout)

        do {
            try modelContext.save()
        } catch {
            print("Failed to delete workout: \(error)")
        }
    }
}

#Preview {
    WorkoutListView()
}