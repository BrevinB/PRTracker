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
    @ObservedObject var WeightVM: WeightViewModel
    @State private var workoutName = ""
    @AppStorage("isImperial") private var isImperial = true
    @Environment(\.dismiss) var dismiss
    @Binding var isMetric: Bool
    @State private var showPremium = false
    @State private var isImporting = false
    
    var body: some View {
        NavigationView {
            ZStack {
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
                               }).disabled(true)
                               
                               Button(action: {
                                   print("Previous 6 months")
                                   //HealthVM.readBodyWeight()
    //                               HealthVM.checkData()
                               }, label: {
                                   Text("Import Previous 6 Months")
                               }).disabled(true)
                               
                               Button(action: {
                                   print("Previous Year")
                                   //HealthVM.readBodyWeight()
                               }, label: {
                                   Text("Import Previous Year")
                               }).disabled(true)
                           } else {
                               Button(action: {
                                   showPremium = true
                               }, label: {
                                   Text("Import Previous 3 Months")
                               }).disabled(true)
                               
                               Button(action: {
                                   isImporting = true
                                   print("Previous 6 months")
                                   Task {
                                       if await HealthVM.fetchDataAndReport(workoutVM: WorkoutVM, weightVM: WeightVM) {
                                           isImporting = false
                                       } else {
                                           //display error?
                                           isImporting = false
                                       }
                                   }
                               }, label: {
                                   Text("Import Previous 6 Months")
                               }).disabled(true)
                               
                               Button(action: {
                                   showPremium = true
                                   
                               }, label: {
                                   Text("Import Previous Year")
                               }).disabled(true)
                           }
                        }
                        Section("Add Workouts") {
                            VStack {
                                TextField("Workout", text: $workoutName)//.disabled(true)
                                Button("Add") {
                                    if(workoutName != "") {
                                        if userViewModel.isSubscriptionActive {
                                            WorkoutVM.addNewWorkout(type: workoutName)
                                            workoutName = ""
                                            WorkoutVM.getAllWorkouts()
                                        } else {
                                            showPremium = true
                                        }
                                    }
                                }
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
                
                VStack {
                    if isImporting {
                        ProgressView("Importing Previous Body Weight Data")
                            .progressViewStyle(.circular)
                    }
                }
                .background(.black)
                .frame(width: 350, height: 100)
                    
                
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
    
    static let userViewModel = UserViewModel()
    
    static var previews: some View {
        SettingsView(WorkoutVM: WorkoutViewModel(), HealthVM: HealthKitViewModel(), WeightVM: WeightViewModel(), isMetric: .constant(false))
            .environmentObject(userViewModel)
    }
}
