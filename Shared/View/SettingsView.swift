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
import UniformTypeIdentifiers
import WishKit

struct SettingsView: View {
    @Environment(WorkoutViewModel.self) private var WorkoutVM
    @Environment(HealthKitManager.self) private var HealthVM
    @Environment(UserManager.self) private var userViewModel
    @Environment(WeightViewModel.self) private var WeightVM
    @Environment(\.requestReview) var requestReview
    @State private var workoutName = ""
    @AppStorage("isImperial") private var isImperial = true
    @Environment(\.dismiss) var dismiss
    @Binding var isMetric: Bool
    @State private var showPremium = false
    @State private var isImporting = false
    @State private var isPurchaseRestored = false
    @State private var draggedWorkout: WorkoutModel?
    @State private var showingSheet = false
    
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
                                    .onChange(of: isMetric) {
                                        UserDefaults.standard.set(isMetric, forKey: "isMetric")
                                    }
                                }
                            }
                        }
                        
                        //TODO: Upcoming Feature, removing from app for now
//                       Section("Import HealthKit Data") {
//                            Text("Feature Coming Soon:")
//                           if userViewModel.isSubscriptionActive {
//                               Button(action: {
//                                   HealthVM.importData()
//                               }, label: {
//                                   Text("Import Previous 3 Months")
//                               }).disabled(true)
//
//                               Button(action: {
//                                   print("Previous 6 months")
//                               }, label: {
//                                   Text("Import Previous 6 Months")
//                               }).disabled(true)
//
//                               Button(action: {
//                                   print("Previous Year")
//                                   //HealthVM.readBodyWeight()
//                               }, label: {
//                                   Text("Import Previous Year")
//                               }).disabled(true)
//                           } else {
//                               Button(action: {
//                                   showPremium = true
//                               }, label: {
//                                   Text("Import Previous 3 Months")
//                               }).disabled(true)
//
//                               Button(action: {
//                                   isImporting = true
//                                   print("Previous 6 months")
//                                   Task {
//                                       if await HealthVM.fetchDataAndReport(workoutVM: WorkoutVM, weightVM: WeightVM) {
//                                           isImporting = false
//                                       } else {
//                                           //display error?
//                                           isImporting = false
//                                       }
//                                   }
//                               }, label: {
//                                   Text("Import Previous 6 Months")
//                               }).disabled(true)
//
//                               Button(action: {
//                                   showPremium = true
//
//                               }, label: {
//                                   Text("Import Previous Year")
//                               }).disabled(true)
//                           }
//                        }
                        
                        Section("Add Workouts") {
                            VStack {
                                TextField("Workout", text: $workoutName)
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
                                }.tint(.green)
                            }
                        }
                        
                        Section("Workouts") {
                            ForEach(WorkoutVM.workouts, id: \.typeId) { workout in
                                Text(workout.type ?? "")
                            }
                            .onDelete(perform: deleteWorkout)
                            .onMove(perform: moveWorkout)
                        }
                        
                        
                        Section("Leave a Review") {
                            Button("Leave a review") {
                                  requestReview()
                                }.tint(.green)
                                .animation(.linear(duration: 1), value: 5)
                        }
                        
                        Section("Suggest Features") {
                            Button(action: { showingSheet = true}, label: { Text("Show Wishlist") })
                                .sheet(isPresented: $showingSheet) {
                                    WishKit.FeedbackListView().withNavigation()
                                }
                                .tint(.green)
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
                            }.tint(.green)
                        }
                        
                        Section() {
                            Text("[Terms of Service](https://sites.google.com/view/pr-tracker-tos/home)")
                            Text("[Privacy Policy](https://sites.google.com/view/pr-tracker-privacy-policy/home)")
                            Text("[Terms of Use](http://www.apple.com/legal/itunes/appstore/dev/stdeula)")
                        }.tint(.green)
                    }
                }
                .navigationTitle("Settings")
                .toolbar {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                    .accessibilityLabel("Close settings")
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
                .toolbar {
                    EditButton()
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

    private func moveWorkout(from source: IndexSet, to destination: Int) {
        WorkoutVM.workouts.move(fromOffsets: source, toOffset: destination)
        WorkoutVM.updateWorkoutOrder(with: WorkoutVM.workouts)
    }
    
//    private func moveWorkoutOrder(at sets: IndexSet, destination: Int) {
//        let itemToMove = sets.first!
//
//        if itemToMove < destination {
//            var startIndex = itemToMove + 1
//            let endIndex = destination + 1
//            var startOrder = WorkoutVM.workouts[itemToMove]
//        } else if destination < itemToMove {
//
//        }
//    }
}

struct SettingsView_Previews: PreviewProvider {
    
    static let userViewModel = UserManager()
    
    static var previews: some View {
        SettingsView(isMetric: .constant(false))
            .environment(userViewModel)
    }
}
