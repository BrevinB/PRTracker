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
    @ObservedObject var WeightVM: WeightViewModel
    @ObservedObject var HealthKitVM: HealthKitViewModel
    @Binding var weights: [WeightModel]
    @Binding var type: WorkoutModel
    @Binding var isMetric: Bool
    @Environment(\.dismiss) var dismiss
    var workoutType: String = ""
    @Binding var refresh: Bool
    
    var body: some View {
        ScrollView {
            if weights.isEmpty {
                Text("No Weights")
            } else {
                VStack(alignment: .trailing, spacing: 0) {
                    //TODO: add edit button to display sheet with weightcards
//                    HStack(spacing: 0) {
//                        Spacer()
//                        Button(action: {
//
//                        }, label: {
//                            Text("Edit")
//                        })
//                        .padding(.trailing, 25)
//                    }
//                    .padding(.bottom, 0)
                    
                    List {
                        ForEach(weights, id: \.id) { weight in
                            VStack {
                                HStack {
                                    if(isMetric) {
                                        Text(weight.value.convertToMetric.stringFormat)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .padding(.trailing)
                                    } else {
                                        Text(weight.value.stringFormat)
                                            .font(.title)
                                            .fontWeight(.bold)
                                        //.padding(.trailing)
                                    }
                                    
                                    Text(weight.date!.formatted(date: .numeric, time: .omitted))
                                        .font(.title3)
                                    Spacer()
                                }
                                Text(weight.note ?? "")
                                    .font(.subheadline)
                            }
                        }.onDelete(perform: deleteValue)
                    }
                    .padding(.top, 0)
                }
              
//                .toolbar {
//                    EditButton()
//                }
                .frame(minWidth: 400, minHeight: 500)
            }
            }
            
        }
        
    private func deleteValue(at offsets: IndexSet) {
        offsets.forEach { offset in
            let weight = WeightVM.weights[offset]
            if type.type == "Body Weight" {
                HealthKitVM.deleteData(date: weight.date ?? Date.now, bodyMass: weight.value)
            }
            WeightVM.deleteWeight(weight: weight)
        }
        refresh.toggle()
        WeightVM.weights.removeAll()
        WeightVM.filteredWeights.removeAll()
        WeightVM.getWeightsByType(workoutModel: type)
        WeightVM.filterWeights(month: 0)
    }
    }
