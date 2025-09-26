import SwiftUI
import SwiftData

struct MealPlanDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let mealPlan: MealPlan

    @State private var showingSchedulePicker = false
    @State private var selectedScheduleDate = Date()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    MealPlanHeaderSection(mealPlan: mealPlan)

                    if !mealPlan.nutritionalFocus.isEmpty {
                        NutritionalFocusSection(nutritionalFocus: mealPlan.nutritionalFocus)
                    }

                    if !mealPlan.meals.isEmpty {
                        MealsSection(meals: mealPlan.meals)
                    }

                    MealPlanActionsSection(
                        mealPlan: mealPlan,
                        showingSchedulePicker: $showingSchedulePicker
                    )
                }
                .padding()
            }
            .navigationTitle("Meal Plan Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingSchedulePicker) {
                ScheduleMealPlanView(
                    mealPlan: mealPlan,
                    selectedDate: $selectedScheduleDate
                )
            }
        }
    }
}

struct MealPlanHeaderSection: View {
    let mealPlan: MealPlan

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(mealPlan.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)

                    Text(mealPlan.cyclePhase)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(mealPlan.cyclePhase.cyclePhaseColor.opacity(0.2))
                        .foregroundColor(mealPlan.cyclePhase.cyclePhaseColor)
                        .cornerRadius(16)
                }

                Spacer()

                if mealPlan.isAIGenerated {
                    Image(systemName: "sparkles")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }

            HStack(spacing: 20) {
                MealPlanStatItem(
                    icon: "flame.fill",
                    value: "\(mealPlan.totalCalories)",
                    unit: "cal"
                )

                MealPlanStatItem(
                    icon: "fork.knife",
                    value: "\(mealPlan.meals.count)",
                    unit: "meals"
                )

                MealPlanStatItem(
                    icon: "target",
                    value: "\(mealPlan.nutritionalFocus.count)",
                    unit: "focus areas"
                )
            }

            if !mealPlan.planDescription.isEmpty {
                Text(mealPlan.planDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }

            if !mealPlan.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(mealPlan.tags, id: \.self) { tag in
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

struct MealPlanStatItem: View {
    let icon: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.green)

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

struct NutritionalFocusSection: View {
    let nutritionalFocus: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Nutritional Focus")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                ForEach(nutritionalFocus, id: \.self) { focus in
                    Text(focus)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
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

struct MealsSection: View {
    let meals: [Meal]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Meals")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()
            }

            LazyVStack(spacing: 12) {
                ForEach(meals, id: \.id) { meal in
                    MealDetailCard(meal: meal)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct MealDetailCard: View {
    let meal: Meal
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(meal.mealType)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(mealTypeColor(meal.mealType).opacity(0.2))
                                .foregroundColor(mealTypeColor(meal.mealType))
                                .cornerRadius(8)

                            Spacer()
                        }

                        Text(meal.name)
                            .font(.headline)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)

                        HStack {
                            Text("\(meal.calories) cal")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if meal.prepTime > 0 || meal.cookTime > 0 {
                                Text("• \(meal.prepTime + meal.cookTime) min")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            if meal.servings > 1 {
                                Text("• \(meal.servings) servings")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
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
                VStack(alignment: .leading, spacing: 12) {
                    if !meal.ingredients.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Ingredients:")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(meal.ingredients, id: \.self) { ingredient in
                                    Text("• \(ingredient)")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }

                    if !meal.instructions.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Instructions:")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Text(meal.instructions)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }

                    if !meal.allergens.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Allergens:")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(meal.allergens, id: \.self) { allergen in
                                        Text(allergen)
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.red.opacity(0.2))
                                            .foregroundColor(.red)
                                            .cornerRadius(4)
                                    }
                                }
                            }
                        }
                    }

                    if !meal.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(meal.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }

    private func mealTypeColor(_ type: String) -> Color {
        switch type.lowercased() {
        case "breakfast":
            return .orange
        case "lunch":
            return .blue
        case "dinner":
            return .purple
        case "snack":
            return .green
        default:
            return .gray
        }
    }
}

struct MealPlanActionsSection: View {
    let mealPlan: MealPlan
    @Binding var showingSchedulePicker: Bool

    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                Button(action: { showingSchedulePicker = true }) {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                        Text(mealPlan.isAddedToSchedule ? "Reschedule" : "Schedule")
                    }
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green, lineWidth: 1)
                    )
                }

                ShareMealPlanButton(mealPlan: mealPlan)
            }
        }
    }
}

struct ShareMealPlanButton: View {
    let mealPlan: MealPlan

    var shareText: String {
        var text = "Check out this \(mealPlan.cyclePhase) phase meal plan: \(mealPlan.title)\n\n"
        text += "Total Calories: \(mealPlan.totalCalories)\n"
        text += "Meals: \(mealPlan.meals.count)\n\n"

        if !mealPlan.planDescription.isEmpty {
            text += "\(mealPlan.planDescription)\n\n"
        }

        if !mealPlan.nutritionalFocus.isEmpty {
            text += "Focus: \(mealPlan.nutritionalFocus.joined(separator: ", "))\n\n"
        }

        text += "Generated with FemFit - AI-powered nutrition for women's wellness"
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

struct ScheduleMealPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let mealPlan: MealPlan
    @Binding var selectedDate: Date

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Schedule Meal Plan")
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
                    scheduleMealPlan()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
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

    private func scheduleMealPlan() {
        mealPlan.isAddedToSchedule = true
        mealPlan.scheduledDate = selectedDate

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to schedule meal plan: \(error)")
        }
    }
}

#Preview {
    MealPlanDetailView(
        mealPlan: MealPlan(
            title: "Follicular Phase Nutrition",
            meals: [
                Meal(name: "Energizing Breakfast", mealType: "Breakfast"),
                Meal(name: "Balanced Lunch", mealType: "Lunch"),
                Meal(name: "Nourishing Dinner", mealType: "Dinner")
            ],
            cyclePhase: "Follicular"
        )
    )
}