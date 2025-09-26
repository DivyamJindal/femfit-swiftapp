import SwiftUI
import SwiftData

struct MealPlanListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealPlan.dateCreated, order: .reverse) private var allMealPlans: [MealPlan]

    @State private var selectedFilter: MealPlanFilter = .all
    @State private var showingMealPlanDetail = false
    @State private var selectedMealPlan: MealPlan?

    var filteredMealPlans: [MealPlan] {
        switch selectedFilter {
        case .all:
            return allMealPlans
        case .scheduled:
            return allMealPlans.filter { $0.isAddedToSchedule }
        case .favorites:
            return allMealPlans.filter { $0.tags.contains("Favorite") }
        case .ai:
            return allMealPlans.filter { $0.isAIGenerated }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                MealPlanFilterBarView(selectedFilter: $selectedFilter)

                if filteredMealPlans.isEmpty {
                    EmptyMealPlanListView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredMealPlans, id: \.id) { mealPlan in
                                MealPlanCard(mealPlan: mealPlan) {
                                    selectedMealPlan = mealPlan
                                    showingMealPlanDetail = true
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Meal Plans")
            .sheet(isPresented: $showingMealPlanDetail) {
                if let mealPlan = selectedMealPlan {
                    MealPlanDetailView(mealPlan: mealPlan)
                }
            }
        }
    }
}

enum MealPlanFilter: String, CaseIterable {
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

struct MealPlanFilterBarView: View {
    @Binding var selectedFilter: MealPlanFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MealPlanFilter.allCases, id: \.self) { filter in
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

struct EmptyMealPlanListView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "leaf.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            VStack(spacing: 8) {
                Text("No Meal Plans Yet")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Generate AI-powered nutrition plans from the Calendar tab to get started!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
    }
}

struct MealPlanCard: View {
    let mealPlan: MealPlan
    let action: () -> Void

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mealPlan.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)

                        Text(mealPlan.cyclePhase)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(mealPlan.cyclePhase.cyclePhaseColor.opacity(0.2))
                            .foregroundColor(mealPlan.cyclePhase.cyclePhaseColor)
                            .cornerRadius(8)
                    }

                    Spacer()

                    Menu {
                        Button {
                            toggleFavorite()
                        } label: {
                            Label(
                                mealPlan.tags.contains("Favorite") ? "Remove from Favorites" : "Add to Favorites",
                                systemImage: mealPlan.tags.contains("Favorite") ? "heart.slash" : "heart"
                            )
                        }

                        Button {
                            toggleScheduled()
                        } label: {
                            Label(
                                mealPlan.isAddedToSchedule ? "Remove from Schedule" : "Add to Schedule",
                                systemImage: mealPlan.isAddedToSchedule ? "calendar.badge.minus" : "calendar.badge.plus"
                            )
                        }

                        Button(role: .destructive) {
                            deleteMealPlan()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                }

                HStack {
                    Label("\(mealPlan.totalCalories) cal", systemImage: "flame.fill")
                    Label("\(mealPlan.meals.count) meals", systemImage: "fork.knife")

                    if !mealPlan.nutritionalFocus.isEmpty {
                        Label("\(mealPlan.nutritionalFocus.count) focus areas", systemImage: "target")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)

                if !mealPlan.planDescription.isEmpty {
                    Text(mealPlan.planDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                if !mealPlan.nutritionalFocus.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(mealPlan.nutritionalFocus.prefix(3), id: \.self) { focus in
                                Text(focus)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }

                HStack {
                    ForEach(mealPlan.tags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }

                    Spacer()

                    if mealPlan.isAddedToSchedule {
                        Image(systemName: "calendar.badge.checkmark")
                            .foregroundColor(.green)
                            .font(.caption)
                    }

                    if mealPlan.tags.contains("Favorite") {
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
        if mealPlan.tags.contains("Favorite") {
            mealPlan.tags.removeAll { $0 == "Favorite" }
        } else {
            mealPlan.tags.append("Favorite")
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to save favorite status: \(error)")
        }
    }

    private func toggleScheduled() {
        mealPlan.isAddedToSchedule.toggle()
        if mealPlan.isAddedToSchedule && mealPlan.scheduledDate == nil {
            mealPlan.scheduledDate = Date()
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to save scheduled status: \(error)")
        }
    }

    private func deleteMealPlan() {
        modelContext.delete(mealPlan)

        do {
            try modelContext.save()
        } catch {
            print("Failed to delete meal plan: \(error)")
        }
    }
}

#Preview {
    MealPlanListView()
}