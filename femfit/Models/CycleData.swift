import Foundation
import SwiftUI

enum CyclePhase: String, CaseIterable {
    case menstrual = "Menstrual"
    case follicular = "Follicular"
    case ovulatory = "Ovulatory"
    case luteal = "Luteal"

    var description: String {
        switch self {
        case .menstrual:
            return "Days 1-5: Focus on gentle movement, rest, and self-care"
        case .follicular:
            return "Days 6-13: Energy is building, great for trying new workouts"
        case .ovulatory:
            return "Days 14-16: Peak energy, perfect for intense workouts"
        case .luteal:
            return "Days 17-28: Energy may fluctuate, listen to your body"
        }
    }

    var workoutRecommendations: [String] {
        switch self {
        case .menstrual:
            return ["Gentle yoga", "Walking", "Light stretching", "Meditation", "Restorative poses"]
        case .follicular:
            return ["Strength training", "Cardio", "Dance", "Pilates", "New workout classes"]
        case .ovulatory:
            return ["HIIT", "Heavy lifting", "Sprint intervals", "Boxing", "Intense cardio"]
        case .luteal:
            return ["Moderate cardio", "Yoga", "Swimming", "Barre", "Mindful movement"]
        }
    }

    var nutritionFocus: [String] {
        switch self {
        case .menstrual:
            return ["Iron-rich foods", "Magnesium", "Warm meals", "Anti-inflammatory foods"]
        case .follicular:
            return ["Protein for muscle building", "Complex carbs", "Fresh fruits", "Leafy greens"]
        case .ovulatory:
            return ["Antioxidant-rich foods", "Healthy fats", "Fiber", "Adequate protein"]
        case .luteal:
            return ["B vitamins", "Calcium", "Complex carbs", "Mood-supporting foods"]
        }
    }

    var color: Color {
        switch self {
        case .menstrual:
            return .red
        case .follicular:
            return .green
        case .ovulatory:
            return .orange
        case .luteal:
            return .purple
        }
    }
}

struct CycleCalculator {
    static func getCurrentPhase(lastPeriodDate: Date, cycleLength: Int = 28) -> (phase: CyclePhase, day: Int) {
        let daysSinceLastPeriod = Calendar.current.dateComponents([.day], from: lastPeriodDate, to: Date()).day ?? 0
        let currentDay = daysSinceLastPeriod + 1
        let cycleDay = ((currentDay - 1) % cycleLength) + 1

        let phase: CyclePhase
        switch cycleDay {
        case 1...5:
            phase = .menstrual
        case 6...13:
            phase = .follicular
        case 14...16:
            phase = .ovulatory
        case 17...28:
            phase = .luteal
        default:
            phase = .follicular
        }

        return (phase, cycleDay)
    }

    static func predictNextPeriod(lastPeriodDate: Date, cycleLength: Int = 28) -> Date {
        return Calendar.current.date(byAdding: .day, value: cycleLength, to: lastPeriodDate) ?? Date()
    }
}

// Helper extension to convert string to CyclePhase color
extension String {
    var cyclePhaseColor: Color {
        switch self.lowercased() {
        case "menstrual":
            return .red
        case "follicular":
            return .green
        case "ovulatory":
            return .orange
        case "luteal":
            return .purple
        default:
            return .gray
        }
    }
}