import SwiftUI

struct EmotionIconView: View {
    let emotion: EmotionType
    var isSelected: Bool = false
    var showLabel: Bool = true
    var size: CGFloat = 44
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(emotion.badgeGradient)
                    .frame(width: size, height: size)
                    .shadow(color: emotion.themeColor.opacity(isSelected ? 0.6 : 0.2), radius: isSelected ? 8 : 4)
                
                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 2.5)
                        .frame(width: size + 4, height: size + 4)
                }
                
                Text(emotion.emoji)
                    .font(.system(size: size * 0.52))
            }
            
            if showLabel {
                Text(emotion.title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .white : .secondary)
            }
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        EmotionIconView(emotion: .fcuk, isSelected: true)
        EmotionIconView(emotion: .onFire, isSelected: false)
        EmotionIconView(emotion: .happyChick, isSelected: true)
    }
    .padding()
    .background(Color.black)
}
