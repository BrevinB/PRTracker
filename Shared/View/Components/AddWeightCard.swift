//
//  AddWeightCard.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 7/21/22.
//

import SwiftUI

struct AddWeightCard: View {
    @ObservedObject var WorkoutVM: WorkoutViewModel
    @ObservedObject var WeightVM: WeightViewModel
    @Binding var type: WorkoutModel
    @Binding var refresh: Bool
    @State private var value: Double?
    @State private var date: Date = Date.now
    @State private var note: String = ""
    
    private let formatStyle = Measurement<UnitMass>.FormatStyle(
        width: .abbreviated,
        locale: Locale(identifier: "en-US"),
        numberFormatStyle: .number
       
     )
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Add Weight")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                    .padding(.leading)
                Spacer()
            }
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
                    TextField("Enter Weight", value: $value, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.automatic)
                        .frame(width: 100)
                        .background(
                            ZStack(alignment: .trailing) {
                                if value !=  nil {
                                    Text("lbs")
                                        .font(.system(size: 16, weight: .semibold))
                                        .padding(.leading, 50)
                                }

                            }
                        )
                }
                HStack(spacing: 10) {
                    Text("Date")
                        .font(.title3)
                        .fontWeight(.semibold)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }
            
            }
            //.padding()
            .background(Color(.secondarySystemBackground))
            .onTapGesture {
                self.hideKeyboard()
            }
            
            TextField("Enter Note", text: $note)
                .padding(.leading)
  
            HStack(spacing: 56) {
                Button(action: {
                    WeightVM.value = value ?? 0.0
                    WeightVM.date = date
                    WeightVM.note = note
                    WeightVM.addWeightForWorkout(workoutModel: type)
                    date = Date.now
                    self.note = ""
                    refresh.toggle()
                    self.hideKeyboard()
                    self.value = nil
                }, label: {
                    Text("Submit")
                        .frame(width: 200)
                        //.foregroundColor(.green)
                })
                .buttonStyle(.borderedProminent)
                .tint(Color(.systemGreen))
                .buttonBorderShape(.roundedRectangle(radius: 12))
                
                
            }.padding(.bottom)

        }
        //.frame(minWidth: 400, minHeight: 40)
//        .background {
//            RoundedRectangle(cornerRadius: 10, style: .continuous)
//                .fill(Color(.secondarySystemBackground).shadow(.drop(radius: 2)))
//        }
        
    }
}

struct AddWeightCard_Previews: PreviewProvider {
    static var previews: some View {
        let workout = WorkoutModel(workout: Workout(context: CoreDataManager.shared.viewContext))
        
        Group {
            AddWeightCard(WorkoutVM: WorkoutViewModel(), WeightVM: WeightViewModel(), type: .constant(workout), refresh: .constant(false))
                .preview(with: "Submit")
        }
    }
}
