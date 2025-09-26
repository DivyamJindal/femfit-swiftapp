import SwiftUI
import SwiftData

struct InsightsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var aiService = OpenAIService()

    let profile: UserProfile
    let journalEntries: [JournalEntry]

    @State private var insights = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var currentCycleInfo: (phase: CyclePhase, day: Int) {
        CycleCalculator.getCurrentPhase(
            lastPeriodDate: profile.lastPeriodDate,
            cycleLength: profile.averageCycleLength
        )
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    InsightsHeaderView(
                        currentPhase: currentCycleInfo.phase,
                        currentDay: currentCycleInfo.day
                    )

                    if isLoading {
                        LoadingInsightsView()
                    } else if !insights.isEmpty {
                        AIInsightsView(insights: insights)
                    } else if let error = errorMessage {
                        ErrorView(message: error) {
                            generateInsights()
                        }
                    } else {
                        EmptyInsightsView {
                            generateInsights()
                        }
                    }

                    if !journalEntries.isEmpty {
                        RecentPatternsView(journalEntries: Array(journalEntries.prefix(7)))
                    }
                }
                .padding()
            }
            .navigationTitle("AI Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if insights.isEmpty && errorMessage == nil {
                    generateInsights()
                }
            }
        }
    }

    private func generateInsights() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let generatedInsights = try await aiService.generatePersonalizedInsights(
                    userProfile: profile,
                    journalEntries: journalEntries,
                    currentPhase: currentCycleInfo.phase
                )

                await MainActor.run {
                    self.insights = generatedInsights
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to generate insights. Please try again."
                    self.isLoading = false
                }
            }
        }
    }
}

struct InsightsHeaderView: View {
    let currentPhase: CyclePhase
    let currentDay: Int

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.purple)

                Text("Your AI Insights")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Phase")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(currentPhase.rawValue)
                        .font(.headline)
                        .foregroundColor(currentPhase.color)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Cycle Day")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(currentDay)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }

            Text("Based on your journal entries and cycle tracking, here's what FemFit has learned about your patterns:")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct LoadingInsightsView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Analyzing your patterns...")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("Our AI is reviewing your journal entries and cycle data to provide personalized insights about your wellness journey.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct AIInsightsView: View {
    let insights: String

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)

                Text("AI Analysis")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()
            }

            Text(insights)
                .font(.body)
                .multilineTextAlignment(.leading)

            HStack {
                Spacer()
                Text("Generated by FemFit AI")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color.purple.opacity(0.05))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct EmptyInsightsView: View {
    let onGenerate: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            VStack(spacing: 8) {
                Text("No Insights Yet")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Start journaling to help FemFit learn your patterns and provide personalized insights.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("Generate Insights") {
                onGenerate()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.purple)
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.red)

            Text("Unable to Generate Insights")
                .font(.headline)
                .fontWeight(.semibold)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                onRetry()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.red)
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct RecentPatternsView: View {
    let journalEntries: [JournalEntry]

    var averageEnergy: Double {
        guard !journalEntries.isEmpty else { return 0 }
        let total = journalEntries.reduce(0) { $0 + $1.energy }
        return Double(total) / Double(journalEntries.count)
    }

    var averageStress: Double {
        guard !journalEntries.isEmpty else { return 0 }
        let total = journalEntries.reduce(0) { $0 + $1.stress }
        return Double(total) / Double(journalEntries.count)
    }

    var averageSleep: Double {
        guard !journalEntries.isEmpty else { return 0 }
        let total = journalEntries.reduce(0) { $0 + $1.sleep }
        return Double(total) / Double(journalEntries.count)
    }

    var mostCommonMoods: [String] {
        let allMoods = journalEntries.flatMap { $0.moods }
        let moodCounts = Dictionary(grouping: allMoods, by: { $0 })
            .mapValues { $0.count }
        return moodCounts.sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
    }

    var mostCommonSymptoms: [String] {
        let allSymptoms = journalEntries.flatMap { $0.symptoms }
        let symptomCounts = Dictionary(grouping: allSymptoms, by: { $0 })
            .mapValues { $0.count }
        return symptomCounts.sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Recent Patterns")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Text("Last 7 days")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                PatternCard(
                    icon: "bolt.fill",
                    title: "Energy",
                    value: String(format: "%.1f/10", averageEnergy),
                    color: .orange
                )

                PatternCard(
                    icon: "brain.head.profile",
                    title: "Stress",
                    value: String(format: "%.1f/10", averageStress),
                    color: .red
                )

                PatternCard(
                    icon: "moon.fill",
                    title: "Sleep",
                    value: String(format: "%.1f/10", averageSleep),
                    color: .blue
                )
            }

            if !mostCommonMoods.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Common Moods")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(mostCommonMoods, id: \.self) { mood in
                                Text(mood)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }

            if !mostCommonSymptoms.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Common Symptoms")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(mostCommonSymptoms, id: \.self) { symptom in
                                Text(symptom)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red.opacity(0.2))
                                    .foregroundColor(.red)
                                    .cornerRadius(8)
                            }
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

struct PatternCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    InsightsView(
        profile: UserProfile(),
        journalEntries: []
    )
}