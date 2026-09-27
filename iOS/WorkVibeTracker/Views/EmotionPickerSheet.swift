import SwiftUI

struct EmotionPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let dayNumber: Int
    @Bindable var viewModel: TrackerViewModel
    
    @State private var selectedEmotion: EmotionType? = nil
    @State private var noteText: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Day Header Banner
                        VStack(spacing: 8) {
                            Text("DAY \(dayNumber)")
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.orange.opacity(0.2)))
                                .foregroundColor(.orange)
                            
                            Text("How was work today?")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                            
                            Text("Select 1 emotion for this day slot")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 10)
                        
                        // Single Emotion Selection Cards
                        VStack(spacing: 16) {
                            ForEach(EmotionType.allCases) { emotion in
                                let isSelected = selectedEmotion == emotion
                                
                                Button {
                                    if selectedEmotion == emotion {
                                        selectedEmotion = nil
                                    } else {
                                        selectedEmotion = emotion
                                    }
                                } label: {
                                    HStack(spacing: 16) {
                                        EmotionIconView(emotion: emotion, isSelected: isSelected, showLabel: false, size: 52)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(emotion.title)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text(emotion.subtitle)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                            .font(.title2)
                                            .foregroundColor(isSelected ? emotion.themeColor : Color.gray.opacity(0.4))
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                            .shadow(color: isSelected ? emotion.themeColor.opacity(0.25) : Color.black.opacity(0.05), radius: 8, y: 3)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(isSelected ? emotion.themeColor : Color.clear, lineWidth: 2)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Selected Emotion Indicator Card
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Selected Slot:")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                if selectedEmotion != nil {
                                    Button("Clear Selection") {
                                        selectedEmotion = nil
                                    }
                                    .font(.caption.bold())
                                    .foregroundColor(.red)
                                }
                            }
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                                    .frame(height: 54)
                                
                                if let selected = selectedEmotion {
                                    HStack(spacing: 8) {
                                        Text(selected.emoji)
                                            .font(.title2)
                                        Text(selected.title)
                                            .font(.headline.bold())
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(Capsule().fill(selected.badgeGradient))
                                    .foregroundColor(.white)
                                    .padding(4)
                                } else {
                                    Text("No Emotion Selected")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Optional Work Note Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Work Note (Optional)")
                                .font(.subheadline.bold())
                                .foregroundColor(.secondary)
                            
                            TextField("e.g., Tough client meeting, or peaceful coding session...", text: $noteText, axis: .vertical)
                                .lineLimit(3...5)
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                )
                        }
                        .padding(.horizontal)
                        
                        // Save Button
                        Button {
                            saveEntry()
                        } label: {
                            Text(selectedEmotion == nil ? "Save Empty Day" : "Save Day \(dayNumber) Vibe")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(
                                    LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
                                        .cornerRadius(16)
                                        .shadow(color: Color.orange.opacity(0.4), radius: 10, y: 4)
                                )
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Day \(dayNumber) Vibe Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                if let existing = viewModel.entries.first(where: { $0.dayNumber == dayNumber }) {
                    self.selectedEmotion = existing.emotion
                    self.noteText = existing.note
                }
            }
        }
    }
    
    private func saveEntry() {
        viewModel.updateDay(dayNumber: dayNumber, emotion: selectedEmotion, note: noteText)
        dismiss()
    }
}
