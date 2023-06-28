//
//  SettingsView.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 10/26/22.
//

import SwiftUI
import RevenueCat

struct SettingsView: View {
    @ObservedObject var WorkoutVM: WorkoutViewModel
    @ObservedObject var HealthVM: HealthKitViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var workoutName = ""
    @AppStorage("isImperial") private var isImperial = true
    @Environment(\.dismiss) var dismiss
    @Binding var isMetric: Bool
    @State private var showPremium = false
    
    var body: some View {
        NavigationView {
            VStack {
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
                       if userViewModel.isSubscriptionActive {
                           Button(action: {
                               HealthVM.importData()
                           }, label: {
                               Text("Import Previous 3 Months")
                           })//.disabled(true)
                           
                           Button(action: {
                               print("Previous 6 months")
                               //HealthVM.readBodyWeight()
                           }, label: {
                               Text("Import Previous 6 Months")
                           })//.disabled(true)
                           
                           Button(action: {
                               print("Previous Year")
                               //HealthVM.readBodyWeight()
                           }, label: {
                               Text("Import Previous Year")
                           })//.disabled(true)
                       } else {
                           Button(action: {
                               showPremium = true
                           }, label: {
                               Text("Import Previous 3 Months")
                           })
                           
                           Button(action: {
                               print("Previous 6 months")
                               showPremium = true
                           }, label: {
                               Text("Import Previous 6 Months")
                           })
                           
                           Button(action: {
                               showPremium = true
                               
                           }, label: {
                               Text("Import Previous Year")
                           })
                       }
                          
                             
                        //}
                    }
                    Section("Add Workouts") {
                        VStack {
                            Text("Feature Coming Soon:")
                            TextField("Workout", text: $workoutName)//.disabled(true)
                            Button("Add") {
                                if(workoutName != "") {
                                    if userViewModel.isSubscriptionActive {
                                        // Unlock that great "pro" content
                                        WorkoutVM.addNewWorkout(type: workoutName)
                                        WorkoutVM.getAllWorkouts()
                                        
                                    } else {
                                        showPremium = true
                                    }
                                   
                                }
                            }//.disabled(true)
                        }
                    }
                    

                    Section("Workouts") {
                        ForEach(WorkoutVM.workouts, id: \.typeId) { workout in
                            Text(workout.type ?? "")
                        }
                        .onDelete(perform: deleteWorkout)
                    }
                    
                    Section("Premium") {
                        Button("Restore Purchases") {
                            Purchases.shared.restorePurchases { (customerInfo, error) in
                                //... check customerInfo to see if entitlement is now active
                                if customerInfo?.entitlements.all["Premium"]?.isActive == true {
                                    // Unlock that great "pro" content
                                    userViewModel.isSubscriptionActive = true
                                    
                                }
                            }
                        }
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
            .sheet(isPresented: $showPremium, onDismiss: {
                
            }, content: {
                Paywall(isPaywallPresented: $showPremium)
            })
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
    
    static let userViewModel = UserViewModel()
    
    static var previews: some View {
        SettingsView(WorkoutVM: WorkoutViewModel(), HealthVM: HealthKitViewModel(), isMetric: .constant(false))
            .environmentObject(userViewModel)
    }
}
