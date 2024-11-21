import SwiftUI

struct HistoryView: View {
    @ObservedObject var liquidData: LiquidData
    
    var body: some View {
        List {
            Section(header: Text("Today's Intake")) {
                ForEach(liquidData.intakeHistory.reversed()) { record in
                    HStack {
                        Text("\(Int(record.amount))ml")
                            .font(.headline)
                        Spacer()
                        Text(record.timestamp.formatted(date: .omitted, time: .shortened))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section(header: Text("Summary")) {
                ForEach(Array(liquidData.amountCounts.sorted { $0.key < $1.key }), id: \.key) { amount, count in
                    HStack {
                        Text("\(Int(amount))ml")
                            .font(.headline)
                        Spacer()
                        Text("×\(count)")
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("Total drinks")
                        .font(.headline)
                    Spacer()
                    Text("\(liquidData.getTotalCount())")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("History")
    }
}

#Preview {
    NavigationStack {
        HistoryView(liquidData: LiquidData())
    }
} 