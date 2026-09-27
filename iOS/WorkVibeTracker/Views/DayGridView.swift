import SwiftUI

struct DayGridView: View {
    @Bindable var viewModel: TrackerViewModel
    @State private var activeDayForSheet: Int? = nil
    @State private var showVerdictSheet = false
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Top Vibe Header Summary
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("RESIGNATION TRACKER")
                                        .font(.system(size: 12, weight: .black, design: .monospaced))
                                        .foregroundColor(.orange)
                                    
                                    Text("30-Day Emotion Challenge")
                                        .font(.title2.bold())
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                ZStack {
                                    Circle()
                                        .stroke(Color.orange.opacity(0.2), lineWidth: 6)
                                        .frame(width: 58, height: 58)
                                    
                                    Circle()
                                        .trim(from: 0, to: CGFloat(viewModel.progressPercentage / 100.0))
                                        .stroke(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                        .frame(width: 58, height: 58)
                                        .rotationEffect(.degrees(-90))
                                    
                                    VStack(spacing: 0) {
                                        Text("\(viewModel.completedDaysCount)")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                        Text("/30")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            // 3 Emotion Legend Pill
                            HStack(spacing: 8) {
                                Label("🤬 FCUK!! (\(viewModel.count(for: .fcuk)))", systemImage: "")
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(Color.red.opacity(0.15)))
                                    .foregroundColor(.red)
                                
                                Label("🔥 On Fire (\(viewModel.count(for: .onFire)))", systemImage: "")
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(Color.orange.opacity(0.15)))
                                    .foregroundColor(.orange)
                                
                                Label("🐥 Happy (\(viewModel.count(for: .happyChick)))", systemImage: "")
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(Color.green.opacity(0.15)))
                                    .foregroundColor(.green)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                .shadow(color: Color.black.opacity(0.06), radius: 10, y: 4)
                        )
                        .padding(.horizontal)
                        
                        // 30 Slot Grid (Single Emotion Selection)
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(viewModel.entries) { entry in
                                Button {
                                    activeDayForSheet = entry.dayNumber
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("DAY \(entry.dayNumber)")
                                                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                                                .foregroundColor(entry.emotion == nil ? .secondary : .orange)
                                            
                                            Spacer()
                                            
                                            if !entry.note.isEmpty {
                                                Image(systemName: "note.text")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.orange)
                                            }
                                        }
                                        
                                        // Single emotion display
                                        if let emotion = entry.emotion {
                                            HStack(spacing: 6) {
                                                Text(emotion.emoji)
                                                    .font(.system(size: 26))
                                                Text(emotion.title)
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(.primary)
                                                    .lineLimit(1)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .frame(height: 52)
                                        } else {
                                            VStack {
                                                Spacer()
                                                Image(systemName: "plus.circle")
                                                    .font(.title2)
                                                    .foregroundColor(Color.gray.opacity(0.4))
                                                Text("Log Vibe")
                                                    .font(.system(size: 10, weight: .medium))
                                                    .foregroundColor(.gray)
                                                Spacer()
                                            }
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 52)
                                        }
                                    }
                                    .padding(12)
                                    .frame(height: 94)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                            .shadow(color: entry.emotion == nil ? Color.clear : Color.orange.opacity(0.12), radius: 6, y: 3)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(entry.emotion == nil ? Color.gray.opacity(0.15) : Color.orange.opacity(0.6), lineWidth: entry.emotion == nil ? 1 : 1.5)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // SPECIAL LAST TRIANGLE VERDICT SLOT (DAY 31 / CAREER DECISION)
                        VStack(spacing: 12) {
                            Button {
                                showVerdictSheet = true
                            } label: {
                                VStack(spacing: 10) {
                                    ZStack {
                                        TriangleShape()
                                            .fill(viewModel.activeVerdict == .stayForNow ? LinearGradient(colors: [Color(red: 0.22, green: 0.74, blue: 0.98), Color(red: 0.05, green: 0.65, blue: 0.92)], startPoint: .top, endPoint: .bottom) : LinearGradient(colors: [.yellow, .red], startPoint: .top, endPoint: .bottom))
                                            .frame(width: 54, height: 48)
                                            .shadow(color: viewModel.activeVerdict == .stayForNow ? Color(red: 0.22, green: 0.74, blue: 0.98).opacity(0.5) : Color.red.opacity(0.5), radius: 8, y: 4)
                                        
                                        Text("⚠️")
                                            .font(.system(size: 20))
                                            .offset(y: 4)
                                    }
                                    
                                    Text("FINAL VERDICT SLOT")
                                        .font(.system(size: 12, weight: .black, design: .monospaced))
                                        .foregroundColor(viewModel.activeVerdict == .stayForNow ? Color(red: 0.22, green: 0.74, blue: 0.98) : .red)
                                    
                                    if let verdict = viewModel.activeVerdict {
                                        VStack(spacing: 6) {
                                            Text(viewModel.finalVerdict != nil ? "MANUAL OVERRIDE" : "⚡ AUTO-COMPUTED VERDICT")
                                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                                .foregroundColor(verdict == .stayForNow ? Color(red: 0.49, green: 0.83, blue: 0.99) : Color.red.opacity(0.8))
                                            
                                            HStack(spacing: 6) {
                                                Text(verdict.emoji)
                                                    .font(.headline)
                                                
                                                if verdict == .stayForNow {
                                                    (Text("I WILL STAY ")
                                                        .font(.headline.bold())
                                                        .foregroundColor(Color(red: 0.22, green: 0.74, blue: 0.98)) +
                                                     Text("for now")
                                                        .font(.subheadline.weight(.semibold))
                                                        .foregroundColor(Color(red: 0.49, green: 0.83, blue: 0.99)))
                                                } else {
                                                    Text(verdict.rawValue)
                                                        .font(.headline.bold())
                                                        .foregroundColor(.red)
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Capsule().fill(verdict == .quit ? Color.red.opacity(0.2) : Color(red: 0.22, green: 0.74, blue: 0.98).opacity(0.18)))
                                            .overlay(Capsule().stroke(verdict == .quit ? Color.red : Color(red: 0.22, green: 0.74, blue: 0.98), lineWidth: 1.5))
                                            
                                            Text("🤬+🔥: \(viewModel.negativeEmotionsTotal) vs 🐥: \(viewModel.positiveEmotionsTotal)")
                                                .font(.caption2.bold())
                                                .foregroundColor(.secondary)
                                        }
                                    } else {
                                        Text("Log 30-day slots to auto-compute final verdict")
                                            .font(.caption.bold())
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(20)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 22)
                                        .fill(viewModel.activeVerdict == .stayForNow ? Color(red: 0.22, green: 0.74, blue: 0.98).opacity(0.12) : Color(uiColor: .secondarySystemGroupedBackground))
                                        .shadow(color: viewModel.activeVerdict == .stayForNow ? Color(red: 0.22, green: 0.74, blue: 0.98).opacity(0.2) : Color.red.opacity(0.15), radius: 12, y: 4)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(viewModel.activeVerdict == .stayForNow ? Color(red: 0.22, green: 0.74, blue: 0.98) : Color.red, lineWidth: 2)
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationTitle("30-Day Work Grid")
            .sheet(item: Binding(
                get: { activeDayForSheet.map { IdentifiableInt(value: $0) } },
                set: { activeDayForSheet = $0?.value }
            )) { item in
                EmotionPickerSheet(dayNumber: item.value, viewModel: viewModel)
            }
            .sheet(isPresented: $showVerdictSheet) {
                VerdictSheet(viewModel: viewModel)
            }
        }
    }
}

/// Custom Triangle Shape for the Verdict Slot
struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Verdict Picker Sheet
struct VerdictSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: TrackerViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ZStack {
                    TriangleShape()
                        .fill(LinearGradient(colors: [.yellow, .red], startPoint: .top, endPoint: .bottom))
                        .frame(width: 70, height: 60)
                    Text("⚠️")
                        .font(.title)
                        .offset(y: 6)
                }
                .padding(.top, 20)
                
                VStack(spacing: 6) {
                    Text("30-DAY FINAL VERDICT")
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(.red)
                    Text("What is your work decision?")
                        .font(.title2.bold())
                }
                
                VStack(spacing: 16) {
                    // Option 1: FCUK THIS I QUIT!!
                    Button {
                        viewModel.setVerdict(.quit)
                        dismiss()
                    } label: {
                        HStack(spacing: 14) {
                            Text("💣")
                                .font(.largeTitle)
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("FCUK THIS I QUIT!! 🤬💣")
                                        .font(.headline.bold())
                                        .foregroundColor(.red)
                                    Spacer()
                                    if viewModel.computedVerdict == .quit {
                                        Text("AUTO-RECOMMENDED")
                                            .font(.caption2.bold())
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Capsule().fill(Color.red.opacity(0.2)))
                                            .foregroundColor(.red)
                                    }
                                }
                                Text("Hand in resignation / rage quit work")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if viewModel.finalVerdict == .quit {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                .shadow(color: Color.red.opacity(0.2), radius: 8)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.red, lineWidth: viewModel.finalVerdict == .quit ? 2 : 1)
                        )
                    }
                    
                    // Option 2: I WILL STAY for now
                    Button {
                        viewModel.setVerdict(.stayForNow)
                        dismiss()
                    } label: {
                        HStack(spacing: 14) {
                            Text("🛡️")
                                .font(.largeTitle)
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 4) {
                                    Text("I WILL STAY")
                                        .font(.headline.bold())
                                        .foregroundColor(Color(red: 0.22, green: 0.74, blue: 0.98))
                                    Text("for now")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(Color(red: 0.49, green: 0.83, blue: 0.99))
                                    Spacer()
                                    if viewModel.computedVerdict == .stayForNow {
                                        Text("AUTO-RECOMMENDED")
                                            .font(.caption2.bold())
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Capsule().fill(Color(red: 0.22, green: 0.74, blue: 0.98).opacity(0.2)))
                                            .foregroundColor(Color(red: 0.22, green: 0.74, blue: 0.98))
                                    }
                                }
                                Text("Endure another month & evaluate later")
                                    .font(.caption)
                                    .foregroundColor(Color(red: 0.7, green: 0.85, blue: 0.98))
                            }
                            Spacer()
                            if viewModel.finalVerdict == .stayForNow {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 0.22, green: 0.74, blue: 0.98))
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(red: 0.22, green: 0.74, blue: 0.98).opacity(viewModel.finalVerdict == .stayForNow ? 0.3 : 0.18))
                                .shadow(color: Color(red: 0.22, green: 0.74, blue: 0.98).opacity(0.25), radius: 8)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color(red: 0.22, green: 0.74, blue: 0.98), lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Final Decision Slot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
