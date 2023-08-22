//
//  AddGoalCard.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 7/20/23.
//

import SwiftUI

struct AddGoalCard: View {
    @ObservedObject var WorkoutVM: WorkoutViewModel
    @Binding var type: WorkoutModel
    @Environment(\.dismiss) var dismiss
    @Binding var refresh: Bool
    @State private var goal: Double?

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
                            //.frame(width: 100)
                            .background(
                                ZStack(alignment: .trailing) {
                                    if goal !=  nil {
                                        Text("lbs")
                                            .font(.system(size: 16, weight: .semibold))
                                            .padding(.leading, 50)
                                    }

                                }
                            )
                    } else {
                        TextField("Current Goal: \(type.goal!.formatted())", value: $goal, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.automatic)
                            //.frame(width: 100)
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
            }
            //.padding()
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
                        .frame(width: 400)
                        //.foregroundColor(.green)
                })
                .buttonStyle(.borderedProminent)
                .tint(Color(.systemGreen))
                .buttonBorderShape(.roundedRectangle(radius: 12))
                
                
            }.padding(.bottom)

        }
    }
}

struct AddGoalCard_Previews: PreviewProvider {
    static var previews: some View {
        let workout = WorkoutModel(workout: Workout(context: CoreDataManager.shared.viewContext))
        AddGoalCard(WorkoutVM: WorkoutViewModel(), type: .constant(workout), refresh: .constant(false))
    }
}
