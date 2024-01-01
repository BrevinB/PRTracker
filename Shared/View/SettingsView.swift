//
//  SettingsView.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 10/26/22.
//

import SwiftUI
import RevenueCat
import StoreKit
import RevenueCatUI

struct SettingsView: View {
    @ObservedObject var WorkoutVM: WorkoutViewModel
    @ObservedObject var HealthVM: HealthKitViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.requestReview) var requestReview
    @ObservedObject var WeightVM: WeightViewModel
    @State private var workoutName = ""
    @AppStorage("isImperial") private var isImperial = true
    @Environment(\.dismiss) var dismiss
    @Binding var isMetric: Bool
    @State private var showPremium = false
    @State private var isImporting = false
    @State private var isPurchaseRestored = false
    
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
                        
                        Section("Leave a Review") {
                            Button("Leave a review") {
                                  requestReview()
                                }
                                .animation(.linear(duration: 1), value: 5)
                        }
                        
                        Section("Premium") {
                            Button("Restore Purchases") {
                                Purchases.shared.restorePurchases { (customerInfo, error) in
                                    //... check customerInfo to see if entitlement is now active
                                    if customerInfo?.entitlements.all["Premium"]?.isActive == true {
                                        // Unlock that great "pro" content
                                        userViewModel.isSubscriptionActive = true
                                        isPurchaseRestored = true
                                    }
                                }
                            }
                        }
                        
                        Section() {
                            Text("[Terms of Service](https://sites.google.com/view/pr-tracker-tos/home)")
                            Text("[Privacy Policy](https://sites.google.com/view/pr-tracker-privacy-policy/home)")
                            Text("[Terms of Use](http://www.apple.com/legal/itunes/appstore/dev/stdeula)")
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
                    PaywallView(displayCloseButton: true)
                })
                
                VStack {
                    if isImporting {
                        ProgressView("Importing Previous Body Weight Data")
                            .progressViewStyle(.circular)
                    }
                }
                .background(.black)
                .frame(width: 350, height: 100)
                .alert("Purchase Restored", isPresented: $isPurchaseRestored)  {
                    Button("Ok", role: .cancel) {
                        isPurchaseRestored = false
                    }
                }
            }
        }
       
    }
    
    private func deleteWorkout(at offsets: IndexSet) {
        offsets.forEach { offset in
            let workout = WorkoutVM.workouts[offset]
            WorkoutVM.deleteWorkout(workout: workout)
            WorkoutVM.getAllWorkouts()
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
