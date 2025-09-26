import Foundation
import SwiftData

@Model
class JournalEntry {
    var id: UUID
    var date: Date
    var dayRating: Int
    var journalText: String
    var moods: [String]
    var symptoms: [String]
    var energy: Int
    var sleep: Int
    var stress: Int
    var exercise: Int
    var nutrition: Int
    var socialConnection: Int
    var cycleDay: Int
    var cyclePhase: String
    var voiceNoteURL: String?
    var createdAt: Date

    init(date: Date = Date(),
         dayRating: Int = 5,
         journalText: String = "",
         moods: [String] = [],
         symptoms: [String] = [],
         energy: Int = 5,
         sleep: Int = 5,
         stress: Int = 5,
         exercise: Int = 5,
         nutrition: Int = 5,
         socialConnection: Int = 5,
         cycleDay: Int = 1,
         cyclePhase: String = "Menstrual",
         voiceNoteURL: String? = nil) {
        self.id = UUID()
        self.date = date
        self.dayRating = dayRating
        self.journalText = journalText
        self.moods = moods
        self.symptoms = symptoms
        self.energy = energy
        self.sleep = sleep
        self.stress = stress
        self.exercise = exercise
        self.nutrition = nutrition
        self.socialConnection = socialConnection
        self.cycleDay = cycleDay
        self.cyclePhase = cyclePhase
        self.voiceNoteURL = voiceNoteURL
        self.createdAt = Date()
    }
}

extension JournalEntry {
    static let availableMoods = ["Happy", "Sad", "Anxious", "Energetic", "Tired", "Calm", "Frustrated", "Excited", "Peaceful", "Overwhelmed", "Confident", "Emotional"]

    static let availableSymptoms = ["Cramps", "Headache", "Bloating", "Breast tenderness", "Back pain", "Nausea", "Food cravings", "Mood swings", "Fatigue", "Acne", "Hot flashes", "Insomnia"]
}