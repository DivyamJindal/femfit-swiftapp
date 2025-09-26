import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @State private var selectedTab: Int = 0

    var currentProfile: UserProfile? {
        userProfiles.first
    }

    var body: some View {
        Group {
            if let profile = currentProfile, profile.isOnboarded {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }

            WorkoutListView()
                .tabItem {
                    Image(systemName: "figure.strengthtraining.traditional")
                    Text("Workouts")
                }

            MealPlanListView()
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("Nutrition")
                }

            JournalView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Journal")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .tint(.pink)
    }
}

#Preview {
    ContentView()
}