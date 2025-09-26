import Foundation

class OpenAIService: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"

    init() {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let key = config["OPENAI_API_KEY"] as? String else {
            fatalError("OpenAI API key not found in Config.plist")
        }
        self.apiKey = key
    }

    func generateWorkout(for phase: CyclePhase,
                        userProfile: UserProfile,
                        journalEntries: [JournalEntry]) async throws -> WorkoutPlan {
        let prompt = buildWorkoutPrompt(phase: phase, userProfile: userProfile, journalEntries: journalEntries)

        let response = try await sendRequest(prompt: prompt, systemMessage: workoutSystemMessage)
        return parseWorkoutResponse(response, phase: phase)
    }

    func generateMealPlan(for phase: CyclePhase,
                         userProfile: UserProfile,
                         journalEntries: [JournalEntry]) async throws -> MealPlan {
        let prompt = buildNutritionPrompt(phase: phase, userProfile: userProfile, journalEntries: journalEntries)

        let response = try await sendRequest(prompt: prompt, systemMessage: nutritionSystemMessage)
        return parseMealPlanResponse(response, phase: phase)
    }

    func generatePersonalizedInsights(userProfile: UserProfile,
                                    journalEntries: [JournalEntry],
                                    currentPhase: CyclePhase) async throws -> String {
        let prompt = buildInsightsPrompt(userProfile: userProfile, journalEntries: journalEntries, currentPhase: currentPhase)

        return try await sendRequest(prompt: prompt, systemMessage: insightsSystemMessage)
    }

    private func sendRequest(prompt: String, systemMessage: String) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": systemMessage],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 2000,
            "temperature": 0.7
        ] as [String: Any]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw OpenAIError.requestFailed
        }

        let responseObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = responseObject?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw OpenAIError.parseError
        }

        return content
    }

    private let workoutSystemMessage = """
    You are FemFit's AI workout specialist, expert in creating personalized workouts for women based on their menstrual cycle phases. Create workouts that respect the natural rhythms of the female body and optimize performance while minimizing discomfort.

    Always respond with a valid JSON object containing:
    - title: workout name
    - exercises: array of exercises with name, sets, reps, instructions
    - duration: total workout time in minutes
    - difficulty: Beginner/Moderate/Advanced
    - description: brief overview
    - tags: relevant tags

    Focus on cycle-appropriate exercises and always consider the user's energy levels, symptoms, and preferences.
    """

    private let nutritionSystemMessage = """
    You are FemFit's AI nutrition specialist, expert in creating personalized meal plans for women based on their menstrual cycle phases. Create nutrition plans that support hormonal health, energy levels, and overall wellness throughout the menstrual cycle.

    Always respond with a valid JSON object containing:
    - title: meal plan name
    - meals: array of meals with name, mealType, ingredients, instructions, calories
    - totalCalories: estimated total calories
    - description: brief overview
    - nutritionalFocus: key nutrients emphasized
    - tags: relevant tags

    Focus on cycle-appropriate nutrition that addresses common symptoms and supports optimal health.
    """

    private let insightsSystemMessage = """
    You are FemFit's AI wellness companion, providing personalized insights and support for women's health and fitness journey. Analyze patterns in mood, symptoms, and cycle data to provide meaningful, actionable insights.

    Provide empathetic, scientifically-informed guidance that helps women understand their bodies better and make informed decisions about their health and fitness.
    """

    private func buildWorkoutPrompt(phase: CyclePhase, userProfile: UserProfile, journalEntries: [JournalEntry]) -> String {
        let recentEntries = journalEntries.prefix(7)
        let avgEnergy = recentEntries.isEmpty ? 5 : Int(recentEntries.map { $0.energy }.reduce(0, +) / recentEntries.count)
        let commonSymptoms = recentEntries.flatMap { $0.symptoms }.reduce(into: [:]) { counts, symptom in
            counts[symptom, default: 0] += 1
        }.sorted { $0.value > $1.value }.prefix(3).map { $0.key }

        return """
        Create a personalized workout for a \(userProfile.age)-year-old woman in her \(phase.rawValue.lowercased()) phase.

        User Profile:
        - Workout experience: \(userProfile.workoutExperienceYears) years
        - Major workout issues: \(userProfile.majorWorkoutIssues.joined(separator: ", "))
        - Workouts per week: \(userProfile.workoutDaysPerWeek)
        - Preferred time: \(userProfile.preferredWorkoutTime)
        - Fitness goals: \(userProfile.fitnessGoals.joined(separator: ", "))

        Recent patterns:
        - Average energy level: \(avgEnergy)/10
        - Common symptoms: \(commonSymptoms.joined(separator: ", "))

        Phase-specific needs for \(phase.rawValue) phase:
        \(phase.description)
        Recommended exercises: \(phase.workoutRecommendations.joined(separator: ", "))

        Create a workout that respects these patterns and optimizes for this cycle phase.
        """
    }

    private func buildNutritionPrompt(phase: CyclePhase, userProfile: UserProfile, journalEntries: [JournalEntry]) -> String {
        let recentEntries = journalEntries.prefix(7)
        let avgEnergy = recentEntries.isEmpty ? 5 : Int(recentEntries.map { $0.energy }.reduce(0, +) / recentEntries.count)
        let commonSymptoms = recentEntries.flatMap { $0.symptoms }.reduce(into: [:]) { counts, symptom in
            counts[symptom, default: 0] += 1
        }.sorted { $0.value > $1.value }.prefix(3).map { $0.key }

        return """
        Create a personalized daily meal plan for a \(userProfile.age)-year-old woman in her \(phase.rawValue.lowercased()) phase.

        User Profile:
        - Diet type: \(userProfile.dietType)
        - Activity level: \(userProfile.workoutDaysPerWeek) workouts/week
        - Fitness goals: \(userProfile.fitnessGoals.joined(separator: ", "))

        Recent patterns:
        - Average energy level: \(avgEnergy)/10
        - Common symptoms: \(commonSymptoms.joined(separator: ", "))

        Phase-specific nutrition focus for \(phase.rawValue) phase:
        \(phase.nutritionFocus.joined(separator: ", "))

        Create 3 meals (breakfast, lunch, dinner) that support hormonal health and address common symptoms.
        """
    }

    private func buildInsightsPrompt(userProfile: UserProfile, journalEntries: [JournalEntry], currentPhase: CyclePhase) -> String {
        let recentEntries = journalEntries.prefix(14)

        return """
        Analyze this woman's health patterns and provide personalized insights.

        User: \(userProfile.age) years old, \(userProfile.workoutExperienceYears) years workout experience
        Current phase: \(currentPhase.rawValue)

        Recent journal entries (last 14 days):
        \(recentEntries.map { entry in
            "Day \(entry.cycleDay) (\(entry.cyclePhase)): Energy \(entry.energy)/10, Mood: \(entry.moods.joined(separator: ", ")), Symptoms: \(entry.symptoms.joined(separator: ", "))"
        }.joined(separator: "\n"))

        Provide supportive insights about patterns you notice and gentle recommendations for wellness.
        """
    }

    private func parseWorkoutResponse(_ response: String, phase: CyclePhase) -> WorkoutPlan {
        guard let data = response.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return createFallbackWorkout(for: phase)
        }

        let title = json["title"] as? String ?? "AI Workout for \(phase.rawValue) Phase"
        let duration = json["duration"] as? Int ?? 30
        let difficulty = json["difficulty"] as? String ?? "Moderate"
        let description = json["description"] as? String ?? ""
        let tags = json["tags"] as? [String] ?? ["AI Generated"]

        var exercises: [Exercise] = []
        if let exercisesData = json["exercises"] as? [[String: Any]] {
            exercises = exercisesData.compactMap { exerciseJson in
                guard let name = exerciseJson["name"] as? String else { return nil }

                let sets = exerciseJson["sets"] as? Int ?? 3
                let reps = exerciseJson["reps"] as? String ?? "10-12"
                let instructions = exerciseJson["instructions"] as? String ?? ""

                return Exercise(name: name, sets: sets, reps: reps, instructions: instructions)
            }
        }

        return WorkoutPlan(
            title: title,
            exercises: exercises,
            duration: duration,
            difficulty: difficulty,
            cyclePhase: phase.rawValue,
            tags: tags,
            workoutDescription: description
        )
    }

    private func parseMealPlanResponse(_ response: String, phase: CyclePhase) -> MealPlan {
        guard let data = response.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return createFallbackMealPlan(for: phase)
        }

        let title = json["title"] as? String ?? "AI Meal Plan for \(phase.rawValue) Phase"
        let totalCalories = json["totalCalories"] as? Int ?? 1800
        let description = json["description"] as? String ?? ""
        let nutritionalFocus = json["nutritionalFocus"] as? [String] ?? phase.nutritionFocus
        let tags = json["tags"] as? [String] ?? ["AI Generated"]

        var meals: [Meal] = []
        if let mealsData = json["meals"] as? [[String: Any]] {
            meals = mealsData.compactMap { mealJson in
                guard let name = mealJson["name"] as? String,
                      let mealType = mealJson["mealType"] as? String else { return nil }

                let ingredients = mealJson["ingredients"] as? [String] ?? []
                let instructions = mealJson["instructions"] as? String ?? ""
                let calories = mealJson["calories"] as? Int ?? 300

                return Meal(
                    name: name,
                    mealType: mealType,
                    ingredients: ingredients,
                    instructions: instructions,
                    calories: calories
                )
            }
        }

        return MealPlan(
            title: title,
            meals: meals,
            totalCalories: totalCalories,
            cyclePhase: phase.rawValue,
            tags: tags,
            planDescription: description,
            nutritionalFocus: nutritionalFocus
        )
    }

    private func createFallbackWorkout(for phase: CyclePhase) -> WorkoutPlan {
        let exercises = phase.workoutRecommendations.prefix(5).map { exerciseName in
            Exercise(name: exerciseName, instructions: "Perform with proper form and listen to your body")
        }

        return WorkoutPlan(
            title: "\(phase.rawValue) Phase Workout",
            exercises: Array(exercises),
            cyclePhase: phase.rawValue,
            tags: ["AI Generated", "Fallback"],
            workoutDescription: phase.description
        )
    }

    private func createFallbackMealPlan(for phase: CyclePhase) -> MealPlan {
        let meals = [
            Meal(name: "Nutritious Breakfast", mealType: "Breakfast"),
            Meal(name: "Balanced Lunch", mealType: "Lunch"),
            Meal(name: "Healthy Dinner", mealType: "Dinner")
        ]

        return MealPlan(
            title: "\(phase.rawValue) Phase Nutrition",
            meals: meals,
            cyclePhase: phase.rawValue,
            tags: ["AI Generated", "Fallback"],
            planDescription: phase.description,
            nutritionalFocus: phase.nutritionFocus
        )
    }
}

enum OpenAIError: Error {
    case invalidURL
    case requestFailed
    case parseError
}
