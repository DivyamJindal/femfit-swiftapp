import Foundation
import SwiftData

@Model
class WorkoutPlan {
    var id: UUID
    var title: String
    var exercises: [Exercise]
    var duration: Int
    var difficulty: String
    var cyclePhase: String
    var isAIGenerated: Bool
    var dateCreated: Date
    var isAddedToSchedule: Bool
    var scheduledDate: Date?
    var tags: [String]
    var workoutDescription: String

    init(title: String,
         exercises: [Exercise] = [],
         duration: Int = 30,
         difficulty: String = "Moderate",
         cyclePhase: String = "Follicular",
         isAIGenerated: Bool = true,
         dateCreated: Date = Date(),
         isAddedToSchedule: Bool = false,
         scheduledDate: Date? = nil,
         tags: [String] = [],
         workoutDescription: String = "") {
        self.id = UUID()
        self.title = title
        self.exercises = exercises
        self.duration = duration
        self.difficulty = difficulty
        self.cyclePhase = cyclePhase
        self.isAIGenerated = isAIGenerated
        self.dateCreated = dateCreated
        self.isAddedToSchedule = isAddedToSchedule
        self.scheduledDate = scheduledDate
        self.tags = tags
        self.workoutDescription = workoutDescription
    }
}

@Model
class Exercise {
    var id: UUID
    var name: String
    var sets: Int
    var reps: String
    var duration: Int?
    var restTime: Int
    var instructions: String
    var targetMuscles: [String]
    var equipment: [String]
    var difficulty: String
    var category: String

    init(name: String,
         sets: Int = 3,
         reps: String = "10-12",
         duration: Int? = nil,
         restTime: Int = 60,
         instructions: String = "",
         targetMuscles: [String] = [],
         equipment: [String] = [],
         difficulty: String = "Moderate",
         category: String = "Strength") {
        self.id = UUID()
        self.name = name
        self.sets = sets
        self.reps = reps
        self.duration = duration
        self.restTime = restTime
        self.instructions = instructions
        self.targetMuscles = targetMuscles
        self.equipment = equipment
        self.difficulty = difficulty
        self.category = category
    }
}

extension Exercise {
    static let categories = ["Strength", "Cardio", "Flexibility", "Balance", "Core", "HIIT", "Yoga", "Pilates"]
    static let equipmentOptions = ["None", "Dumbbells", "Resistance bands", "Yoga mat", "Kettlebell", "Barbell", "Medicine ball", "Foam roller"]
    static let difficultyLevels = ["Beginner", "Moderate", "Advanced"]
}

extension WorkoutPlan {
    static let difficultyLevels = ["Beginner", "Moderate", "Advanced"]
    static let defaultTags = ["AI Generated", "Custom", "Favorite", "Quick", "Strength", "Cardio", "Flexibility"]
}