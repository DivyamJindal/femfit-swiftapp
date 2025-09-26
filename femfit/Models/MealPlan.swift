import Foundation
import SwiftData

@Model
class MealPlan {
    var id: UUID
    var title: String
    var meals: [Meal]
    var totalCalories: Int
    var macros: MacroNutrients
    var cyclePhase: String
    var isAIGenerated: Bool
    var dateCreated: Date
    var isAddedToSchedule: Bool
    var scheduledDate: Date?
    var tags: [String]
    var planDescription: String
    var nutritionalFocus: [String]

    init(title: String,
         meals: [Meal] = [],
         totalCalories: Int = 1800,
         macros: MacroNutrients = MacroNutrients(),
         cyclePhase: String = "Follicular",
         isAIGenerated: Bool = true,
         dateCreated: Date = Date(),
         isAddedToSchedule: Bool = false,
         scheduledDate: Date? = nil,
         tags: [String] = [],
         planDescription: String = "",
         nutritionalFocus: [String] = []) {
        self.id = UUID()
        self.title = title
        self.meals = meals
        self.totalCalories = totalCalories
        self.macros = macros
        self.cyclePhase = cyclePhase
        self.isAIGenerated = isAIGenerated
        self.dateCreated = dateCreated
        self.isAddedToSchedule = isAddedToSchedule
        self.scheduledDate = scheduledDate
        self.tags = tags
        self.planDescription = planDescription
        self.nutritionalFocus = nutritionalFocus
    }
}

@Model
class Meal {
    var id: UUID
    var name: String
    var mealType: String
    var ingredients: [String]
    var instructions: String
    var prepTime: Int
    var cookTime: Int
    var servings: Int
    var calories: Int
    var macros: MacroNutrients
    var allergens: [String]
    var tags: [String]

    init(name: String,
         mealType: String = "Breakfast",
         ingredients: [String] = [],
         instructions: String = "",
         prepTime: Int = 15,
         cookTime: Int = 15,
         servings: Int = 1,
         calories: Int = 300,
         macros: MacroNutrients = MacroNutrients(),
         allergens: [String] = [],
         tags: [String] = []) {
        self.id = UUID()
        self.name = name
        self.mealType = mealType
        self.ingredients = ingredients
        self.instructions = instructions
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.servings = servings
        self.calories = calories
        self.macros = macros
        self.allergens = allergens
        self.tags = tags
    }
}

@Model
class MacroNutrients {
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var sugar: Double

    init(protein: Double = 0,
         carbs: Double = 0,
         fat: Double = 0,
         fiber: Double = 0,
         sugar: Double = 0) {
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
    }
}

extension Meal {
    static let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    static let commonAllergens = ["Gluten", "Dairy", "Nuts", "Eggs", "Soy", "Shellfish", "Fish"]
    static let dietaryTags = ["Vegetarian", "Vegan", "Gluten-free", "Dairy-free", "Low-carb", "High-protein", "Keto", "Paleo"]
}

extension MealPlan {
    static let nutritionalFocusOptions = [
        "Iron-rich foods", "Magnesium", "Anti-inflammatory", "Protein for muscle building",
        "Complex carbs", "Antioxidant-rich", "Healthy fats", "B vitamins", "Calcium",
        "Mood-supporting foods", "Energy boosting", "Recovery foods"
    ]
}