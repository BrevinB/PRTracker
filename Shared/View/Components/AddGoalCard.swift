//
//  AddGoalCard.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 7/20/23.
//

import SwiftUI

struct AddGoalCard: View {
    @AppStorage("isImperial") private var isImperial = true
    @Environment(WorkoutViewModel.self) private var WorkoutVM
    @Environment(WeightViewModel.self) private var WeightVM
    @Binding var type: WorkoutModel
    @Environment(\.dismiss) var dismiss
    @Binding var refresh: Bool
    @State private var goal: Double?
    @State var targetValue : Double
    @Binding var isMetric: Bool
    
    private var startingValue: Double {
        return WeightVM.weights.last?.value ?? 0.0
    }
    
    private var currentValue: Double {
        return WeightVM.weights.first?.value ?? 0.0
    }
    
    var progress: Double {
            guard startingValue != targetValue else { return 1.0 }
            guard currentValue != targetValue else { return 1.0}
            guard startingValue != currentValue else { return targetValue / currentValue}
            guard currentValue > targetValue else { return 1.0 }
            return (currentValue - targetValue) / (startingValue - targetValue)
    }
    
    var progress2: Double {
        guard currentValue != targetValue else { return 1.0 }
        return (currentValue / targetValue)
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                if type.goal == 0.0 {
                    Text("Add a \(type.type!) goal")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                        .padding(.leading)
                } else {
                    Text("Current \(type.type!) goal: \(type.goal!.formatted())")
                }
                
                Spacer()
            }.padding()
            
            HStack(spacing: 40) {
                HStack {
                    switch(type.type) {
                    case "Body Weight":
                        Image(systemName: "scalemass")
                    case "Squat":
                        Image(systemName: "scalemass")
                    case "Bench":
                        Image(systemName: "scalemass")
                    case "Deadlift":
                        Image(systemName: "figure.strengthtraining.traditional")
                    default:
                        Image(systemName: "scalemass")
                    }
                    if type.goal == 0.0 {
                        TextField("Enter Goal", value: $goal, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.automatic)
                            .background(
                                ZStack(alignment: .trailing) {
                                    if goal !=  nil {
                                        Text("\(isMetric ? "kgs" : "lbs")")
                                            .font(.system(size: 16, weight: .semibold))
                                            .padding(.leading, 50)
                                    }
                                }
                            )
                    } else {
                        if isMetric {
                            TextField("Current Goal: \(type.goal!.convertToMetric.formatted())", value: $goal, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.automatic)
                                .background(
                                    ZStack(alignment: .trailing) {
                                        if goal !=  nil {
                                            Text("kgs")
                                                .font(.system(size: 16, weight: .semibold))
                                                .padding(.leading, 50)
                                        }
                                    }
                                )
                        } else {
                            TextField("Current Goal: \(type.goal!.formatted())", value: $goal, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.automatic)
                                .background(
                                    ZStack(alignment: .trailing) {
                                        if goal !=  nil {
                                            Text("lbs")
                                                .font(.system(size: 16, weight: .semibold))
                                                .padding(.leading, 50)
                                        }
                                    }
                                )
                        }
                    }
                }.padding(.leading).padding(.trailing)
            }
            .onTapGesture {
                self.hideKeyboard()
            }.padding()
            
            HStack(spacing: 56) {
                Button(action: {
                    WorkoutVM.addGoal(workout: type, goal: goal!)
                    refresh.toggle()
                    self.hideKeyboard()
                    self.goal = nil
                    dismiss()
                }, label: {
                    Text("Submit")
                        .frame(maxWidth: 400)
                        //.foregroundColor(.green)
                })
                .buttonStyle(.borderedProminent)
                .tint(Color(.systemGreen))
                .buttonBorderShape(.roundedRectangle(radius: 12))
            }.padding(.bottom).padding(.trailing).padding(.leading)
            
            if targetValue != 0.0 {
                if type.type == "Body Weight" {
                    ProgressView("\(type.type ?? "Body Weight") Progress:", value: progress)
                        .padding()
                } else {
                    ProgressView("\(type.type ?? "Body Weight") Progress:", value: progress2)
                        .padding()
                }
            }
        }
    }
    
    struct CustomProgressViewStyle: ProgressViewStyle {
        func makeBody(configuration: Configuration) -> some View {
            GeometryReader { geometry in
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)
                    .overlay(
                        Capsule()
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * CGFloat(configuration.fractionCompleted ?? 0), height: 20)
                    )
            }
        }
    }
}

