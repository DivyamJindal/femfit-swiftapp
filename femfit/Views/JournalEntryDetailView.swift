import SwiftUI
import SwiftData

struct JournalEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let entry: JournalEntry

    @State private var showingEditView = false

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    JournalHeaderSection(entry: entry)

                    if !entry.journalText.isEmpty {
                        JournalTextSection(text: entry.journalText)
                    }

                    if !entry.moods.isEmpty || !entry.symptoms.isEmpty {
                        MoodsAndSymptomsSection(entry: entry)
                    }

                    WellnessMetricsDisplaySection(entry: entry)

                    if entry.voiceNoteURL != nil {
                        VoiceNoteSection(entry: entry)
                    }
                }
                .padding()
            }
            .navigationTitle("Journal Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingEditView = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            deleteEntry()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditView) {
                EditJournalEntryView(entry: entry)
            }
        }
    }

    private func deleteEntry() {
        modelContext.delete(entry)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to delete entry: \(error)")
        }
    }
}

struct JournalHeaderSection: View {
    let entry: JournalEntry

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }

    var body: some View {
        VStack(spacing: 15) {
            VStack(spacing: 8) {
                Text(dateFormatter.string(from: entry.date))
                    .font(.title2)
                    .fontWeight(.bold)

                HStack {
                    Text("Day \(entry.cycleDay)")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(entry.cyclePhase.cyclePhaseColor.opacity(0.2))
                        .foregroundColor(entry.cyclePhase.cyclePhaseColor)
                        .cornerRadius(16)

                    Text(entry.cyclePhase)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            VStack(spacing: 8) {
                Text("Overall Day Rating")
                    .font(.headline)
                    .fontWeight(.medium)

                HStack {
                    ForEach(1...10, id: \.self) { star in
                        Image(systemName: star <= entry.dayRating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.title3)
                    }
                }

                Text("\(entry.dayRating)/10")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }

}

struct JournalTextSection: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Journal Entry")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            Text(text)
                .font(.body)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct MoodsAndSymptomsSection: View {
    let entry: JournalEntry

    var body: some View {
        VStack(spacing: 15) {
            if !entry.moods.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Moods")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                        ForEach(entry.moods, id: \.self) { mood in
                            Text(mood)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                        }
                    }
                }
            }

            if !entry.symptoms.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Symptoms")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(entry.symptoms, id: \.self) { symptom in
                            Text(symptom)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.2))
                                .foregroundColor(.red)
                                .cornerRadius(12)
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

struct WellnessMetricsDisplaySection: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Wellness Metrics")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            VStack(spacing: 12) {
                MetricDisplayRow(title: "Energy Level", value: entry.energy, color: .orange, icon: "bolt.fill")
                MetricDisplayRow(title: "Sleep Quality", value: entry.sleep, color: .blue, icon: "moon.fill")
                MetricDisplayRow(title: "Stress Level", value: entry.stress, color: .red, icon: "brain.head.profile")
                MetricDisplayRow(title: "Exercise", value: entry.exercise, color: .green, icon: "figure.walk")
                MetricDisplayRow(title: "Nutrition", value: entry.nutrition, color: .purple, icon: "leaf.fill")
                MetricDisplayRow(title: "Social Connection", value: entry.socialConnection, color: .pink, icon: "person.2.fill")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct MetricDisplayRow: View {
    let title: String
    let value: Int
    let color: Color
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)

            Text(title)
                .font(.subheadline)

            Spacer()

            HStack(spacing: 8) {
                HStack(spacing: 2) {
                    ForEach(1...10, id: \.self) { index in
                        Rectangle()
                            .fill(index <= value ? color : Color.gray.opacity(0.3))
                            .frame(width: 12, height: 8)
                            .cornerRadius(2)
                    }
                }

                Text("\(value)/10")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                    .frame(width: 35, alignment: .trailing)
            }
        }
    }
}

struct VoiceNoteSection: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Voice Note")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            HStack {
                Image(systemName: "mic.fill")
                    .foregroundColor(.blue)

                Text("Voice note available")
                    .font(.body)
                    .foregroundColor(.secondary)

                Spacer()

                Button("Play") {
                    // TODO: Implement voice note playback
                }
                .foregroundColor(.blue)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct EditJournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let entry: JournalEntry

    @State private var dayRating: Int
    @State private var journalText: String
    @State private var selectedMoods: Set<String>
    @State private var selectedSymptoms: Set<String>
    @State private var energy: Int
    @State private var sleep: Int
    @State private var stress: Int
    @State private var exercise: Int
    @State private var nutrition: Int
    @State private var socialConnection: Int

    init(entry: JournalEntry) {
        self.entry = entry
        self._dayRating = State(initialValue: entry.dayRating)
        self._journalText = State(initialValue: entry.journalText)
        self._selectedMoods = State(initialValue: Set(entry.moods))
        self._selectedSymptoms = State(initialValue: Set(entry.symptoms))
        self._energy = State(initialValue: entry.energy)
        self._sleep = State(initialValue: entry.sleep)
        self._stress = State(initialValue: entry.stress)
        self._exercise = State(initialValue: entry.exercise)
        self._nutrition = State(initialValue: entry.nutrition)
        self._socialConnection = State(initialValue: entry.socialConnection)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 15) {
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
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveChanges() {
        entry.dayRating = dayRating
        entry.journalText = journalText
        entry.moods = Array(selectedMoods)
        entry.symptoms = Array(selectedSymptoms)
        entry.energy = energy
        entry.sleep = sleep
        entry.stress = stress
        entry.exercise = exercise
        entry.nutrition = nutrition
        entry.socialConnection = socialConnection

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
}

#Preview {
    JournalEntryDetailView(
        entry: JournalEntry(
            journalText: "Had a great day today! Felt energetic and accomplished a lot.",
            moods: ["Happy", "Energetic"],
            symptoms: ["Mild cramps"],
            energy: 8,
            sleep: 7,
            stress: 3
        )
    )
}