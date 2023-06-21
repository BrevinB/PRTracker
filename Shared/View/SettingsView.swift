//
//  SettingsView.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 10/26/22.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var WorkoutVM: WorkoutViewModel
    @ObservedObject var HealthVM: HealthKitViewModel
    @State private var workoutName = ""
    @AppStorage("isImperial") private var isImperial = true
    @Environment(\.dismiss) var dismiss
    @Binding var isMetric: Bool
    @State private var showPremium = false
    var body: some View {
        NavigationView {
            VStack {
//                Button(action: {
//                    showPremium.toggle()
//                }, label: {
//                    Text("Test Premium")
//                        .foregroundColor(.black)
//                })
//                .sheet(isPresented: $showPremium, content: {
//                    Paywall(isPaywallPresented: .constant(true))
//                })
                List {
                    Section("Unit System") {
                        HStack {
                            VStack {
                                Toggle(isOn: $isMetric) {
                                    Text("Use Metric Units")
                                }
                                .onChange(of: isMetric) { _ in
                                    UserDefaults.standard.set(isMetric, forKey: "isMetric")
                                }
                            }
                      
                            
                        }
                    }
                   Section("Import HealthKit Data") {
                       // HStack {
                        Text("Feature Coming Soon:")
                            Button(action: {
                                HealthVM.importData()
                            }, label: {
                                Text("Import Previous 3 Months")
                            }).disabled(true)
                            
                            Button(action: {
                                print("Previous 6 months")
                                //HealthVM.readBodyWeight()
                            }, label: {
                                Text("Import Previous 6 Months")
                            }).disabled(true)
                            
                            Button(action: {
                                print("Previous Year")
                                //HealthVM.readBodyWeight()
                            }, label: {
                                Text("Import Previous Year")
                            }).disabled(true)
                             
                        //}
                    }
                    Section("Add Workouts") {
                        VStack {
                            Text("Feature Coming Soon:")
                            TextField("Workout", text: $workoutName).disabled(true)
                            Button("Add") {
                                if(workoutName != "") {
                                    WorkoutVM.addNewWorkout(type: workoutName)
                                    WorkoutVM.getAllWorkouts() 
                                }
                            }.disabled(true)
                        }
                    }
                    

                    Section("Workouts") {
                        ForEach(WorkoutVM.workouts, id: \.typeId) { workout in
                            Text(workout.type ?? "")
                        }
                        .onDelete(perform: deleteWorkout)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "xmark")
                })
            }
        }
       
    }
    
    private func deleteWorkout(at offsets: IndexSet) {
        offsets.forEach { offset in
            let workout = WorkoutVM.workouts[offset]
            WorkoutVM.deleteWorkout(workout: workout)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(WorkoutVM: WorkoutViewModel(), HealthVM: HealthKitViewModel(), isMetric: .constant(false))
    }
}
