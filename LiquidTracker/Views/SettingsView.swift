import SwiftUI

struct SettingsView: View {
    @ObservedObject var liquidData: LiquidData
    
    var body: some View {
        Form {
            Section(header: Text("Daily Goal")) {
                Stepper(value: $liquidData.dailyGoal, in: 500...5000, step: 100) {
                    Text("\(Int(liquidData.dailyGoal)) ml")
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView(liquidData: LiquidData())
    }
} 