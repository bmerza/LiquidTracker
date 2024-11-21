//
//  ContentView.swift
//  LiquidTracker
//
//  Created by Bogdan Merza on 20.11.24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var liquidData = LiquidData()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Progress Circle
                ProgressCircle(progress: liquidData.getProgress(),
                             currentIntake: liquidData.currentIntake,
                             dailyGoal: liquidData.dailyGoal)
                    .padding(.top, 20)
                
                // Action Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        withAnimation {
                            liquidData.undoLastIntake()
                        }
                    }) {
                        Label("Undo", systemImage: "arrow.uturn.backward.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .disabled(liquidData.intakeHistory.isEmpty)
                    
                    Button(action: {
                        withAnimation {
                            liquidData.resetDaily()
                        }
                    }) {
                        Label("Reset", systemImage: "arrow.counterclockwise.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .padding(.horizontal)
                
                // Quick Add Buttons
                VStack(spacing: 20) {
                    Text("Quick Add")
                        .font(.headline)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(liquidData.quickAddAmounts, id: \.self) { amount in
                            QuickAddButton(amount: amount,
                                         count: liquidData.amountCounts[amount] ?? 0) {
                                withAnimation {
                                    liquidData.addIntake(amount)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Liquid Tracker")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: HistoryView(liquidData: liquidData)) {
                        Image(systemName: "chart.bar.fill")
                            .frame(width: 44, height: 44)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView(liquidData: liquidData)) {
                        Image(systemName: "gear")
                            .frame(width: 44, height: 44)
                    }
                }
            }
        }
    }
}

struct ProgressCircle: View {
    let progress: Double
    let currentIntake: Double
    let dailyGoal: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, style: StrokeStyle(
                    lineWidth: 20,
                    lineCap: .round
                ))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            
            VStack(spacing: 8) {
                Text("\(Int(currentIntake))ml")
                    .font(.system(size: 32, weight: .bold))
                Text("of \(Int(dailyGoal))ml")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 250, height: 250)
    }
}

struct QuickAddButton: View {
    let amount: Double
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("\(Int(amount))ml")
                    .font(.headline)
                if count > 0 {
                    Text("×\(count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(15)
        }
        .frame(minWidth: 44, minHeight: 44)
    }
}

#Preview {
    ContentView()
}
