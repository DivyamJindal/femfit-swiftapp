import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.date, order: .reverse) private var journalEntries: [JournalEntry]
    @Query private var userProfiles: [UserProfile]

    @State private var showingJournalEntry = false
    @State private var selectedEntry: JournalEntry?
    @State private var showingNewEntry = false

    var currentProfile: UserProfile? {
        userProfiles.first
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if journalEntries.isEmpty {
                    EmptyJournalView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(journalEntries, id: \.id) { entry in
                                JournalEntryCard(entry: entry) {
                                    selectedEntry = entry
                                    showingJournalEntry = true
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewEntry = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewEntry) {
                NewJournalEntryView()
            }
            .sheet(isPresented: $showingJournalEntry) {
                if let entry = selectedEntry {
                    JournalEntryDetailView(entry: entry)
                }
            }
        }
    }
}

struct EmptyJournalView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            VStack(spacing: 8) {
                Text("No Journal Entries Yet")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Start tracking your mood, symptoms, and daily experiences to help FemFit understand your patterns better.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    let action: () -> Void

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dateFormatter.string(from: entry.date))
                            .font(.headline)
                            .fontWeight(.semibold)

                        HStack {
                            Text("Day \(entry.cycleDay)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(entry.cyclePhase.cyclePhaseColor.opacity(0.2))
                                .foregroundColor(entry.cyclePhase.cyclePhaseColor)
                                .cornerRadius(8)

                            Text(entry.cyclePhase)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    VStack {
                        HStack {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= entry.dayRating ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                            }
                        }
                        Text("Overall")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                if !entry.journalText.isEmpty {
                    Text(entry.journalText)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                HStack {
                    if !entry.moods.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Moods")
                                .font(.caption2)
                                .fontWeight(.medium)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(entry.moods.prefix(3), id: \.self) { mood in
                                        Text(mood)
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

                    Spacer()

                    if !entry.symptoms.isEmpty {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Symptoms")
                                .font(.caption2)
                                .fontWeight(.medium)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(entry.symptoms.prefix(2), id: \.self) { symptom in
                                        Text(symptom)
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
                }

                HStack {
                    Label("Energy: \(entry.energy)/10", systemImage: "bolt.fill")
                    Spacer()
                    Label("Sleep: \(entry.sleep)/10", systemImage: "moon.fill")
                    Spacer()
                    Label("Stress: \(entry.stress)/10", systemImage: "brain.head.profile")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }

}

struct NewJournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]

    @State private var selectedDate = Date()
    @State private var dayRating = 5
    @State private var journalText = ""
    @State private var selectedMoods: Set<String> = []
    @State private var selectedSymptoms: Set<String> = []
    @State private var energy = 5
    @State private var sleep = 5
    @State private var stress = 5
    @State private var exercise = 5
    @State private var nutrition = 5
    @State private var socialConnection = 5

    var currentProfile: UserProfile? {
        userProfiles.first
    }

    var currentCycleInfo: (phase: CyclePhase, day: Int) {
        guard let profile = currentProfile else {
            return (.follicular, 1)
        }
        return CycleCalculator.getCurrentPhase(
            lastPeriodDate: profile.lastPeriodDate,
            cycleLength: profile.averageCycleLength
        )
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("How was your day?")
                            .font(.title2)
                            .fontWeight(.bold)

                        DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Overall Day Rating")
                                .font(.headline)

                            HStack {
                                ForEach(1...10, id: \.self) { rating in
                                    Button(action: { dayRating = rating }) {
                                        Image(systemName: rating <= dayRating ? "star.fill" : "star")
                                            .foregroundColor(.yellow)
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Journal Entry")
                                .font(.headline)

                            TextEditor(text: $journalText)
                                .frame(minHeight: 100)
                                .padding(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }

                    MoodSelectionSection(selectedMoods: $selectedMoods)

                    SymptomsSelectionSection(selectedSymptoms: $selectedSymptoms)

                    WellnessMetricsSection(
                        energy: $energy,
                        sleep: $sleep,
                        stress: $stress,
                        exercise: $exercise,
                        nutrition: $nutrition,
                        socialConnection: $socialConnection
                    )
                }
                .padding()
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveEntry() {
        let cycleInfo = currentCycleInfo
        let entry = JournalEntry(
            date: selectedDate,
            dayRating: dayRating,
            journalText: journalText,
            moods: Array(selectedMoods),
            symptoms: Array(selectedSymptoms),
            energy: energy,
            sleep: sleep,
            stress: stress,
            exercise: exercise,
            nutrition: nutrition,
            socialConnection: socialConnection,
            cycleDay: cycleInfo.day,
            cyclePhase: cycleInfo.phase.rawValue
        )

        modelContext.insert(entry)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save journal entry: \(error)")
        }
    }
}

struct MoodSelectionSection: View {
    @Binding var selectedMoods: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How are you feeling?")
                .font(.headline)

            Text("Select all that apply")
                .font(.caption)
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                ForEach(JournalEntry.availableMoods, id: \.self) { mood in
                    MoodButton(
                        mood: mood,
                        isSelected: selectedMoods.contains(mood)
                    ) {
                        if selectedMoods.contains(mood) {
                            selectedMoods.remove(mood)
                        } else {
                            selectedMoods.insert(mood)
                        }
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

struct SymptomsSelectionSection: View {
    @Binding var selectedSymptoms: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Any symptoms today?")
                .font(.headline)

            Text("Select all that apply")
                .font(.caption)
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                ForEach(JournalEntry.availableSymptoms, id: \.self) { symptom in
                    SymptomButton(
                        symptom: symptom,
                        isSelected: selectedSymptoms.contains(symptom)
                    ) {
                        if selectedSymptoms.contains(symptom) {
                            selectedSymptoms.remove(symptom)
                        } else {
                            selectedSymptoms.insert(symptom)
                        }
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

struct WellnessMetricsSection: View {
    @Binding var energy: Int
    @Binding var sleep: Int
    @Binding var stress: Int
    @Binding var exercise: Int
    @Binding var nutrition: Int
    @Binding var socialConnection: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Wellness Metrics")
                .font(.headline)

            VStack(spacing: 12) {
                MetricSlider(title: "Energy Level", value: $energy, color: .orange)
                MetricSlider(title: "Sleep Quality", value: $sleep, color: .blue)
                MetricSlider(title: "Stress Level", value: $stress, color: .red)
                MetricSlider(title: "Exercise", value: $exercise, color: .green)
                MetricSlider(title: "Nutrition", value: $nutrition, color: .purple)
                MetricSlider(title: "Social Connection", value: $socialConnection, color: .pink)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct MoodButton: View {
    let mood: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(mood)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}

struct SymptomButton: View {
    let symptom: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(symptom)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(isSelected ? Color.red : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}

struct MetricSlider: View {
    let title: String
    @Binding var value: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text("\(value)/10")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }

            Slider(value: Binding(
                get: { Double(value) },
                set: { value = Int($0) }
            ), in: 1...10, step: 1)
            .tint(color)
        }
    }
}

#Preview {
    JournalView()
}