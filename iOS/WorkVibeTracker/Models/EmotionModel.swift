import SwiftUI
import Foundation

/// The 3 signature workplace emotions
enum EmotionType: String, Codable, CaseIterable, Identifiable {
    case fcuk = "FCUK!!"
    case onFire = "On Fire"
    case happyChick = "Happy Chick"
    
    var id: String { rawValue }
    
    var title: String { rawValue }
    
    var emoji: String {
        switch self {
        case .fcuk: return "🤬"
        case .onFire: return "🔥"
        case .happyChick: return "🐥"
        }
    }
    
    var subtitle: String {
        switch self {
        case .fcuk: return "Overwhelmed / WTF moment"
        case .onFire: return "Fierce anger & friction"
        case .happyChick: return "Good vibes & peaceful progress"
        }
    }
    
    var colorHex: String {
        switch self {
        case .fcuk: return "#FF3B30"
        case .onFire: return "#FF9500"
        case .happyChick: return "#34C759"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .fcuk: return Color(red: 0.95, green: 0.22, blue: 0.25)
        case .onFire: return Color(red: 1.0, green: 0.55, blue: 0.15)
        case .happyChick: return Color(red: 0.2, green: 0.82, blue: 0.45)
        }
    }
    
    var badgeGradient: LinearGradient {
        switch self {
        case .fcuk:
            return LinearGradient(colors: [Color.red, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .onFire:
            return LinearGradient(colors: [Color.orange, Color.red], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .happyChick:
            return LinearGradient(colors: [Color.green, Color.mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

/// Final Career Decision Slot options at the end of the 30-day cycle
enum FinalVerdict: String, Codable, CaseIterable, Identifiable {
    case stayForNow = "I WILL STAY for now"
    case quit = "FCUK THIS I QUIT!! 🤬💣"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .stayForNow: return "🛡️"
        case .quit: return "💣"
        }
    }
}

/// Represents a single day entry in the 30-day tracking slot grid (Single emotion per day)
struct DayEntry: Identifiable, Codable {
    var id: Int { dayNumber }
    let dayNumber: Int // 1 to 30
    var emotion: EmotionType? // Single emotion selection per day slot
    var note: String
    var lastUpdated: Date
    
    init(dayNumber: Int, emotion: EmotionType? = nil, note: String = "", lastUpdated: Date = Date()) {
        self.dayNumber = dayNumber
        self.emotion = emotion
        self.note = note
        self.lastUpdated = lastUpdated
    }
}

/// Main State Manager for 30-day workplace vibe tracking
@Observable
final class TrackerViewModel {
    var entries: [DayEntry] = []
    var selectedDayForEditing: DayEntry? = nil
    var finalVerdict: FinalVerdict? = nil
    
    private let storageKey = "WorkVibeTracker_30DayEntries_v2"
    private let verdictKey = "WorkVibeTracker_FinalVerdict_v2"
    
    init() {
        loadData()
    }
    
    /// Initialize 30 default days if no data exists
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([DayEntry].self, from: data),
           decoded.count == 30 {
            self.entries = decoded
        } else {
            self.entries = (1...30).map { DayEntry(dayNumber: $0) }
            saveData()
        }
        
        if let rawVerdict = UserDefaults.standard.string(forKey: verdictKey) {
            self.finalVerdict = FinalVerdict(rawValue: rawVerdict)
        }
    }
    
    func setVerdict(_ verdict: FinalVerdict?) {
        self.finalVerdict = verdict
        if let verdict {
            UserDefaults.standard.set(verdict.rawValue, forKey: verdictKey)
        } else {
            UserDefaults.standard.removeObject(forKey: verdictKey)
        }
    }
    
    func saveData() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    /// Update entry for a specific day with single emotion selection
    func updateDay(dayNumber: Int, emotion: EmotionType?, note: String) {
        guard let index = entries.firstIndex(where: { $0.dayNumber == dayNumber }) else { return }
        entries[index].emotion = emotion
        entries[index].note = note
        entries[index].lastUpdated = Date()
        saveData()
    }
    
    /// Reset all 30 days
    func resetAllData() {
        self.entries = (1...30).map { DayEntry(dayNumber: $0) }
        self.finalVerdict = nil
        UserDefaults.standard.removeObject(forKey: verdictKey)
        saveData()
    }
    
    // MARK: - Auto-Computed Verdict Logic
    
    var fcukCount: Int { count(for: .fcuk) }
    var fireCount: Int { count(for: .onFire) }
    var happyCount: Int { count(for: .happyChick) }
    
    var negativeEmotionsTotal: Int { fcukCount + fireCount }
    var positiveEmotionsTotal: Int { happyCount }
    
    /// Auto-computes verdict: If (FCUK + On Fire) > Happy Chick -> QUIT, else STAY for now
    var computedVerdict: FinalVerdict? {
        guard totalEmotionsLogged > 0 else { return nil }
        if negativeEmotionsTotal > positiveEmotionsTotal {
            return .quit
        } else {
            return .stayForNow
        }
    }
    
    /// Effective active verdict (user manual override or auto-computed verdict)
    var activeVerdict: FinalVerdict? {
        finalVerdict ?? computedVerdict
    }
    
    // MARK: - Stats & Analytics
    
    var completedDaysCount: Int {
        entries.filter { $0.emotion != nil }.count
    }
    
    var progressPercentage: Double {
        Double(completedDaysCount) / 30.0 * 100.0
    }
    
    func count(for emotionTarget: EmotionType) -> Int {
        entries.compactMap { $0.emotion }.filter { $0 == emotionTarget }.count
    }
    
    var totalEmotionsLogged: Int {
        entries.compactMap { $0.emotion }.count
    }
    
    /// Calculates Work Vibe Balance Score (0 to 100)
    var vibeBalanceScore: Int {
        guard totalEmotionsLogged > 0 else { return 50 }
        let rawScore = (Double(happyCount) * 100.0 + Double(fireCount) * 40.0 + Double(fcukCount) * 0.0) / Double(totalEmotionsLogged)
        return min(100, max(0, Int(rawScore)))
    }
    
    var dominantMood: EmotionType? {
        if happyCount >= fireCount && happyCount >= fcukCount && happyCount > 0 { return .happyChick }
        if fireCount >= fcukCount && fireCount > 0 { return .onFire }
        if fcukCount > 0 { return .fcuk }
        return nil
    }
}
