import SwiftUI
import SwiftData

@main
struct FemFitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [JournalEntry.self, WorkoutPlan.self, MealPlan.self, UserProfile.self])
    }
}