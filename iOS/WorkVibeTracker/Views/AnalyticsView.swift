import SwiftUI

struct AnalyticsView: View {
    @Bindable var viewModel: TrackerViewModel
    @State private var showResetConfirm = false
    @State private var copiedToClipboard = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Resignation Score Card
                        VStack(spacing: 14) {
                            Text("RESIGNATION SCORE")
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                                .foregroundColor(.secondary)
                            
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text("\(viewModel.vibeBalanceScore)")
                                    .font(.system(size: 56, weight: .bold, design: .rounded))
                                    .foregroundColor(scoreColor(viewModel.vibeBalanceScore))
                                Text("/100")
                                    .font(.title3.bold())
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(vibeStatusText(viewModel.vibeBalanceScore))
                                .font(.subheadline.bold())
                                .foregroundColor(scoreColor(viewModel.vibeBalanceScore))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(scoreColor(viewModel.vibeBalanceScore).opacity(0.15)))
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                .shadow(color: Color.black.opacity(0.06), radius: 10, y: 4)
                        )
                        .padding(.horizontal)
                        
                        // Emotion Breakdown Distribution
                        VStack(alignment: .leading, spacing: 16) {
                            Text("30-Day Emotion Breakdown")
                                .font(.headline.bold())
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 14) {
                                emotionRow(emotion: .fcuk)
                                emotionRow(emotion: .onFire)
                                emotionRow(emotion: .happyChick)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 3)
                        )
                        .padding(.horizontal)
                        
                        // Dominant Vibe Insights Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.orange)
                                Text("Workplace Insight")
                                    .font(.headline.bold())
                            }
                            
                            if let dominant = viewModel.dominantMood {
                                HStack(spacing: 12) {
                                    Text(dominant.emoji)
                                        .font(.system(size: 38))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Dominant Vibe: \(dominant.title)")
                                            .font(.subheadline.bold())
                                        Text(insightDescription(dominant))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            } else {
                                Text("Log emotions across the 30-day grid to unlock deep workplace mood insights!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                        )
                        .padding(.horizontal)
                        
                        // Share / Export Report Button
                        Button {
                            copyReportToClipboard()
                        } label: {
                            HStack {
                                Image(systemName: copiedToClipboard ? "checkmark.circle.fill" : "square.and.arrow.up")
                                Text(copiedToClipboard ? "Report Copied to Clipboard!" : "Copy 30-Day Vibe Summary")
                            }
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                                    .cornerRadius(16)
                            )
                        }
                        .padding(.horizontal)
                        
                        // Reset All Data Button
                        Button(role: .destructive) {
                            showResetConfirm = true
                        } label: {
                            Text("Reset 30-Day Cycle Data")
                                .font(.subheadline.bold())
                                .foregroundColor(.red)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Vibe Analytics")
            .confirmationDialog("Reset 30-Day Tracker?", isPresented: $showResetConfirm, titleVisibility: .visible) {
                Button("Reset All Entries", role: .destructive) {
                    viewModel.resetAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will clear all 30 days of logged emotions and notes.")
            }
        }
    }
    
    @ViewBuilder
    private func emotionRow(emotion: EmotionType) -> some View {
        let count = viewModel.count(for: emotion)
        let total = viewModel.totalEmotionsLogged
        let pct = total > 0 ? (Double(count) / Double(total) * 100.0) : 0.0
        
        VStack(spacing: 6) {
            HStack {
                Text("\(emotion.emoji) \(emotion.title)")
                    .font(.subheadline.bold())
                Spacer()
                Text("\(count) slots (\(Int(pct))%)")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 10)
                    
                    Capsule()
                        .fill(emotion.badgeGradient)
                        .frame(width: geo.size.width * CGFloat(pct / 100.0), height: 10)
                }
            }
            .frame(height: 10)
        }
    }
    
    private func scoreColor(_ score: Int) -> Color {
        if score >= 70 { return .green }
        if score >= 40 { return .orange }
        return .red
    }
    
    private func vibeStatusText(_ score: Int) -> String {
        if score >= 85 { return "🌟 Thriving Workplace Vibe" }
        if score >= 70 { return "😊 Chill & Balanced Progress" }
        if score >= 50 { return "⚡ Intense Work Energy" }
        if score >= 30 { return "🔥 High Friction Zone" }
        return "🤬 Extreme Overwhelm Alert"
    }
    
    private func insightDescription(_ emotion: EmotionType) -> String {
        switch emotion {
        case .fcuk:
            return "You have high 'FCUK!!' entries. Time to review workload bounds or set meeting boundaries!"
        case .onFire:
            return "High urgency and rage points detected. Channel this fire into focused problem solving."
        case .happyChick:
            return "Great emotional baseline at work! Keep nurturing positive team dynamics."
        }
    }
    
    private func copyReportToClipboard() {
        let text = """
        📊 RESIGNATION TRACKER - 30 DAY REPORT
        ------------------------------------
        Progress: \(viewModel.completedDaysCount)/30 Days Logged
        Vibe Score: \(viewModel.vibeBalanceScore)/100
        
        Emotions Breakdown:
        🤬 FCUK!!: \(viewModel.count(for: .fcuk)) slots
        🔥 On Fire: \(viewModel.count(for: .onFire)) slots
        🐥 Happy Chick: \(viewModel.count(for: .happyChick)) slots
        """
        
        UIPasteboard.general.string = text
        copiedToClipboard = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            copiedToClipboard = false
        }
    }
}
