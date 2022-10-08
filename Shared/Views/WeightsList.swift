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
    @Environment(\.dismiss) var dismiss
    var workoutType: String = ""
    
    let testValues = [
        testData(
            value: 450,
            date: Date.now,
            note: "Best PR ive gotten"
        ),
        testData(
            value: 425,
            date: Date.now.addingTimeInterval(-1000000),
            note: ""
        ),
        testData(
            value: 405,
            date: Date.now.addingTimeInterval(-2000000),
            note: "first time in the 400's!"
        ),
        testData(
            value: 395,
            date: Date.now.addingTimeInterval(-3000000),
            note: "felt great, 400 is soon"
        )
    ]
    
    var body: some View {
        NavigationView {
            if(testValues.isEmpty) {
                Text("No Entries")
            } else {
                List {
                    ForEach(WeightVM.weights, id: \.id) { weight in
                        VStack {
                            HStack {
                                Text(weight.value.stringFormat)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.trailing)
                                Text(weight.date!.formatted(date: .numeric, time: .omitted))
                                    .font(.title3)
                                
                            }
                            Text(weight.note ?? "")
                                .font(.subheadline)
                        }
                        
                        
                        //for testing
                        //                    ForEach(testValues, id: \.self) { weight in
                        //                        VStack {
                        //                            HStack {
                        //                                Text(weight.value.stringFormat)
                        //                                    .font(.title)
                        //                                    .fontWeight(.bold)
                        //                                    .padding(.trailing)
                        //                                Text(weight.date.formatted(date: .numeric, time: .omitted))
                        //                                    .font(.title3)
                        //
                        //                            }
                        //                            Text(weight.note)
                        //                                .font(.subheadline)
                        //                        }
                    }
                        .onDelete(perform: deleteValue)
                    }
                    .toolbar {
                        EditButton()
                    }
                    .navigationTitle("\(workoutType)")
                }
            }
            
        }
        
        private func deleteValue(at offsets: IndexSet) {
            offsets.forEach { offset in
                let weight = WeightVM.weights[offset]
                WeightVM.deleteWeight(weight: weight)
            }
        }
    }
    
    struct WeightsList_Previews: PreviewProvider {
        static var previews: some View {
            WeightsList(WeightVM: WeightViewModel(), workoutType: "Body Weight")
        }
    }
