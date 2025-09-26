import SwiftUI
import SwiftData

struct MealPlanGeneratorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let currentPhase: CyclePhase
    let userProfile: UserProfile
    let journalEntries: [JournalEntry]
    let aiService: OpenAIService

    @State private var isGenerating = false
    @State private var generatedMealPlan: MealPlan?
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    NutritionPhaseInfoSection(phase: currentPhase)

                    if isGenerating {
                        GeneratingNutritionSection()
                    } else if let mealPlan = generatedMealPlan {
                        GeneratedMealPlanSection(mealPlan: mealPlan)
                    } else {
                        GenerateNutritionPromptSection()
                    }

                    if let error = errorMessage {
                        ErrorSection(message: error)
                    }
                }
                .padding()
            }
            .navigationTitle("AI Nutrition Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if generatedMealPlan != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add to Schedule") {
                            addMealPlanToSchedule()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
        .onAppear {
            generateMealPlan()
        }
    }

    private func generateMealPlan() {
        isGenerating = true
        errorMessage = nil

        Task {
            do {
                let mealPlan = try await aiService.generateMealPlan(
                    for: currentPhase,
                    userProfile: userProfile,
                    journalEntries: journalEntries
                )

                await MainActor.run {
                    self.generatedMealPlan = mealPlan
                    self.isGenerating = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to generate meal plan. Please try again."
                    self.isGenerating = false
                }
            }
        }
    }

    private func addMealPlanToSchedule() {
        guard let mealPlan = generatedMealPlan else { return }

        mealPlan.isAddedToSchedule = true
        mealPlan.scheduledDate = Date()
        modelContext.insert(mealPlan)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save meal plan to schedule."
        }
    }
}

struct NutritionPhaseInfoSection: View {
    let phase: CyclePhase

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)

                Text("\(phase.rawValue) Phase Nutrition")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
            }

            Text(phase.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)

            VStack(alignment: .leading, spacing: 8) {
                Text("Nutritional focus for this phase:")
                    .font(.subheadline)
                    .fontWeight(.medium)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 8) {
                    ForEach(phase.nutritionFocus, id: \.self) { focus in
                        Text(focus)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
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

struct GeneratingNutritionSection: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Creating your personalized meal plan...")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("Our AI is analyzing your cycle phase, dietary preferences, and nutritional needs to create the perfect meal plan for you.")
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

struct GenerateNutritionPromptSection: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.green)

            Text("AI Nutrition Generation")
                .font(.title2)
                .fontWeight(.bold)

            Text("We'll create personalized meals that support your hormonal health and address cycle-specific nutritional needs.")
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

struct GeneratedMealPlanSection: View {
    let mealPlan: MealPlan

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text(mealPlan.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                HStack {
                    Label("\(mealPlan.totalCalories) cal", systemImage: "flame.fill")
                    Spacer()
                    Label("\(mealPlan.meals.count) meals", systemImage: "fork.knife")
                    Spacer()
                    Label(mealPlan.cyclePhase, systemImage: "circle.fill")
                        .foregroundColor(Color(mealPlan.cyclePhase.lowercased() == "menstrual" ? "red" :
                                             mealPlan.cyclePhase.lowercased() == "follicular" ? "green" :
                                             mealPlan.cyclePhase.lowercased() == "ovulatory" ? "orange" : "purple"))
                }
                .font(.caption)
                .foregroundColor(.secondary)

                if !mealPlan.planDescription.isEmpty {
                    Text(mealPlan.planDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            if !mealPlan.nutritionalFocus.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nutritional Focus")
                        .font(.headline)
                        .fontWeight(.medium)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                        ForEach(mealPlan.nutritionalFocus, id: \.self) { focus in
                            Text(focus)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(8)
                        }
                    }
                }
            }

            LazyVStack(spacing: 12) {
                ForEach(Array(mealPlan.meals.enumerated()), id: \.offset) { index, meal in
                    MealCard(meal: meal)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct MealCard: View {
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

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 4) {
                                ForEach(meal.ingredients, id: \.self) { ingredient in
                                    Text("• \(ingredient)")
                                        .font(.caption)
                                        .multilineTextAlignment(.leading)
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

                    if !meal.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(meal.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.gray.opacity(0.2))
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

#Preview {
    MealPlanGeneratorView(
        currentPhase: .follicular,
        userProfile: UserProfile(),
        journalEntries: [],
        aiService: OpenAIService()
    )
}