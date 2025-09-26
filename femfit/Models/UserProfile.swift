import Foundation
import SwiftData

@Model
class UserProfile {
    var id: UUID
    var age: Int
    var workoutExperienceYears: Int
    var majorWorkoutIssues: [String]
    var dietType: String
    var workoutDaysPerWeek: Int
    var preferredWorkoutTime: String
    var fitnessGoals: [String]
    var lastPeriodDate: Date
    var averageCycleLength: Int
    var isOnboarded: Bool
    var createdAt: Date

    init(age: Int = 25,
         workoutExperienceYears: Int = 1,
         majorWorkoutIssues: [String] = [],
         dietType: String = "balanced",
         workoutDaysPerWeek: Int = 3,
         preferredWorkoutTime: String = "morning",
         fitnessGoals: [String] = [],
         lastPeriodDate: Date = Date(),
         averageCycleLength: Int = 28,
         isOnboarded: Bool = false) {
        self.id = UUID()
        self.age = age
        self.workoutExperienceYears = workoutExperienceYears
        self.majorWorkoutIssues = majorWorkoutIssues
        self.dietType = dietType
        self.workoutDaysPerWeek = workoutDaysPerWeek
        self.preferredWorkoutTime = preferredWorkoutTime
        self.fitnessGoals = fitnessGoals
        self.lastPeriodDate = lastPeriodDate
        self.averageCycleLength = averageCycleLength
        self.isOnboarded = isOnboarded
        self.createdAt = Date()
    }
}