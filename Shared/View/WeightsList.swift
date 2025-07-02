//
//  WeightsList.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 9/25/22.
//

import SwiftUI

struct testData: Hashable{
    var value: Double
    var date: Date
    var note: String
}

struct WeightsList: View {
    @Environment(WeightViewModel.self) private var WeightVM
    @Environment(HealthKitManager.self) private var HealthKitVM
    
    var weights: [WeightModel]
    @Binding var type: WorkoutModel
    @Binding var isMetric: Bool
    @Environment(\.dismiss) var dismiss
    var workoutType: String = ""
    @Binding var refresh: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if weights.isEmpty {
                    Text("No Weights")
                } else {
                    VStack(alignment: .trailing, spacing: 0) {
                        List {
                            ForEach(weights, id: \.id) { weight in
                                NavigationLink {
                                    EditWeightView(weight: weight, isMetric: $isMetric)
                                } label: {
                                    VStack {
                                        HStack {
                                            if checkInt(val: weight.value) {
                                                Text(weight.value.intFormat)
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                                    .padding(.trailing)
                                            } else {
                                                Text(weight.value.doubleFormat)
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                                    .padding(.trailing)
                                            }
                                            
                                            Text(weight.date?.formatted(date: .numeric, time: .omitted) ?? Date.now.formatted(date:.numeric, time: .omitted))
                                                .font(.title3)
                                            Spacer()
                                        }
                                        Text(weight.note ?? "")
                                            .font(.subheadline)
                                    }
                                    .accessibilityElement(children: .combine)
                                    .accessibilityLabel("Weight \(checkInt(val: weight.value) ? weight.value.intFormat : weight.value.doubleFormat) on \(weight.date?.formatted(date: .numeric, time: .omitted) ?? "")")
                                    .accessibilityHint(weight.note ?? "")
                                }
                            }.onDelete(perform: deleteValue)
                        }
                        .padding(.top, 0)
                    }
                    .frame(minWidth: 400, minHeight: 500)
                }
            }
        }.tint(.green)
    }
    
    private func deleteValue(at offsets: IndexSet) {
        offsets.forEach { offset in
            let weight = WeightVM.weights[offset]
            if type.type == "Body Weight" {
                HealthKitVM.deleteData(date: weight.date ?? Date.now, bodyMass: weight.value)
            }
            WeightVM.deleteWeight(weight: weight)
        }
        
        Task {
            WeightVM.getWeightsByType(workoutModel: type)
            WeightVM.filterWeights(month: 0)
        }
    }
    
    func checkInt(val: Double) -> Bool {
        return floor(val) == val
    }
}
