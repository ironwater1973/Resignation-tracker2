import SwiftUI

struct ContentView: View {
    @State private var viewModel = TrackerViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DayGridView(viewModel: viewModel)
                .tabItem {
                    Label("30-Day Grid", systemImage: "square.grid.3x3.fill")
                }
                .tag(0)
            
            AnalyticsView(viewModel: viewModel)
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            QuickGuideView()
                .tabItem {
                    Label("App Guide", systemImage: "info.circle.fill")
                }
                .tag(2)
        }
        .tint(.orange)
    }
}

struct QuickGuideView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("3 Signature Emotions") {
                    HStack(spacing: 14) {
                        Text("🤬")
                            .font(.largeTitle)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("FCUK!!")
                                .font(.headline.bold())
                                .foregroundColor(.red)
                            Text("Frustration, stressful meetings, WTF moments")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    HStack(spacing: 14) {
                        Text("🔥")
                            .font(.largeTitle)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("On Fire")
                                .font(.headline.bold())
                                .foregroundColor(.orange)
                            Text("High urgency, rage, intensity, friction")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    HStack(spacing: 14) {
                        Text("🐥")
                            .font(.largeTitle)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Happy Chick")
                                .font(.headline.bold())
                                .foregroundColor(.green)
                            Text("Peaceful work, accomplishment, positive vibes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("How 30-Day Tracking Works") {
                    Label("Select up to 3 emotion slots for each day slot", systemImage: "1.circle.fill")
                    Label("Add optional notes to remember specific work events", systemImage: "2.circle.fill")
                    Label("Check Vibe Analytics to view your 30-day work balance", systemImage: "3.circle.fill")
                }
                
                Section("App Store Deployment") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ready for Apple App Store")
                            .font(.headline)
                        Text("Built with native Swift & SwiftUI. Open in Xcode on macOS to compile into an iOS app bundle (.ipa) or submit via App Store Connect.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("App Info & Guide")
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
