//
//  AddWeightView.swift
//  PRTracker
//
//  Created by Brevin Blalock on 6/1/22.
//

import SwiftUI
import CoreData
struct AddWeightView: View {
    @ObservedObject var WorkoutVM: WorkoutViewModel
    @ObservedObject var WeightVM: WeightViewModel
    @Environment(\.dismiss) var dismiss
    @State private var weight: Double = 0
    @State private var date = Date()
    var type: WorkoutModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(type.type ?? "Test")
                    .font(.title)
                    .fontWeight(.bold)
                .padding()
                
                Spacer()
            }
            VStack() {
                HStack() {
                    Text("Enter Weight")
                    Spacer()
                }
                .padding()
                HStack {
                    TextField("Enter Weight", value: $WeightVM.value, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: 300, minHeight: 44)
                        .padding(.leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(.secondary)
                        )
                       
                        
                    Spacer()
                }
                .padding()
            }
            .foregroundColor(.primary)
            
//            HStack {
//                Toggle("LBS", isOn: $isLBS)
//                Toggle("KG", isOn: $isKG)
//            }
//            .toggleStyle(.button)
            
            
            DatePicker("Date", selection: $WeightVM.date, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .frame(maxHeight: 400)
            
            Button(action: {
                WeightVM.addWeightForWorkout(workoutModel: type)
                dismiss()
            }, label: {
                Text("Submit")
                    .foregroundColor(.blue)
            })
        }
        
       
    }
}

struct AddWeightView_Previews: PreviewProvider {
    static var previews: some View {
        let workout = WorkoutModel(workout: Workout(context: CoreDataManager.shared.viewContext))
        AddWeightView(WorkoutVM: WorkoutViewModel(), WeightVM: WeightViewModel(), type: workout)
            
    }
}
