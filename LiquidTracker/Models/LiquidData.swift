import Foundation

struct IntakeRecord: Codable, Identifiable {
    let id: UUID
    let amount: Double
    let timestamp: Date
    
    init(amount: Double, timestamp: Date = Date()) {
        self.id = UUID()
        self.amount = amount
        self.timestamp = timestamp
    }
}

class LiquidData: ObservableObject {
    @Published var currentIntake: Double {
        didSet {
            UserDefaults.standard.set(currentIntake, forKey: "currentIntake")
        }
    }
    
    @Published var dailyGoal: Double {
        didSet {
            UserDefaults.standard.set(dailyGoal, forKey: "dailyGoal")
            objectWillChange.send()
        }
    }
    
    @Published var intakeHistory: [IntakeRecord] = [] {
        didSet {
            saveIntakeHistory()
            if let lastRecord = intakeHistory.last {
                scheduleNextReminder(after: lastRecord.timestamp)
            }
        }
    }
    
    @Published var amountCounts: [Double: Int] = [:] {
        didSet {
            saveAmountCounts()
        }
    }
    
    let quickAddAmounts = [125.0, 250.0, 333.0, 500.0]
    
    init() {
        self.currentIntake = UserDefaults.standard.double(forKey: "currentIntake")
        self.dailyGoal = UserDefaults.standard.double(forKey: "dailyGoal") == 0 ? 2500 : UserDefaults.standard.double(forKey: "dailyGoal")
        self.loadIntakeHistory()
        self.loadAmountCounts()
    }
    
    func addIntake(_ amount: Double) {
        currentIntake += amount
        let record = IntakeRecord(amount: amount)
        intakeHistory.append(record)
        amountCounts[amount, default: 0] += 1
    }
    
    func undoLastIntake() {
        guard let lastIntake = intakeHistory.last else { return }
        
        // Safely update currentIntake
        let newIntake = max(0, currentIntake - lastIntake.amount)
        currentIntake = newIntake
        
        // Safely update amountCounts
        if let count = amountCounts[lastIntake.amount] {
            if count <= 1 {
                amountCounts.removeValue(forKey: lastIntake.amount)
            } else {
                amountCounts[lastIntake.amount] = count - 1
            }
        }
        
        // Remove the last record
        intakeHistory.removeLast()
    }
    
    func resetDaily() {
        currentIntake = 0
        intakeHistory.removeAll()
        amountCounts.removeAll()
    }
    
    func getProgress() -> Double {
        return min(currentIntake / dailyGoal, 1.0)
    }
    
    func getTotalCount() -> Int {
        amountCounts.values.reduce(0, +)
    }
    
    private func scheduleNextReminder(after date: Date) {
        let nextReminderDate = date.addingTimeInterval(90 * 60) // 1.5 hours
        ReminderManager.shared.scheduleReminder(at: nextReminderDate)
    }
    
    private func saveIntakeHistory() {
        let encodedData = try? JSONEncoder().encode(intakeHistory)
        UserDefaults.standard.set(encodedData, forKey: "intakeHistory")
    }
    
    private func loadIntakeHistory() {
        guard let data = UserDefaults.standard.data(forKey: "intakeHistory"),
              let decoded = try? JSONDecoder().decode([IntakeRecord].self, from: data)
        else { return }
        intakeHistory = decoded
    }
    
    private func saveAmountCounts() {
        // Convert Double keys to String for UserDefaults storage
        let stringDict = Dictionary(uniqueKeysWithValues: amountCounts.map { 
            (String($0.key), $0.value) 
        })
        UserDefaults.standard.set(stringDict, forKey: "amountCounts")
    }
    
    private func loadAmountCounts() {
        if let stringDict = UserDefaults.standard.dictionary(forKey: "amountCounts") as? [String: Int] {
            // Convert String keys back to Double
            amountCounts = Dictionary(uniqueKeysWithValues: stringDict.compactMap { 
                guard let key = Double($0.key) else { return nil }
                return (key, $0.value)
            })
        }
    }
} 