//
//  AddWeightView.swift
//  PRTracker
//
//  Created by Brevin Blalock on 6/1/22.
//

import SwiftUI
import CoreData
import Combine
struct AddWeightView: View {
    @Environment(WorkoutViewModel.self) private var WorkoutVM
    @Environment(WeightViewModel.self) private var WeightVM
    @Environment(HealthKitManager.self) private var HealthKitVM
    @Environment(UserManager.self) private var userViewModel
    @Environment(\.dismiss) var dismiss
    @State private var value: Double?
    @State private var weight = ""
    @State private var date = Date.now
    @State private var note = ""
    @State private var error = false
    @State private var result = ""
    @State private var isMetric = false
    @State private var promptPremium = false
    
    let dateFormatter = DateFormatter()
    
    let weightLimit = 4
    var type: WorkoutModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(type.type ?? "No Data")
                    .font(.title)
                    .fontWeight(.bold)
                .padding()
                
                Spacer()
            }
            VStack() {
                HStack(spacing: 40) {
                    HStack {
                        switch(type.type) {
                        case "Body Weight":
                            Image(systemName: "scalemass")
                                .accessibilityLabel("Weight icon")
                        case "Squat":
                            Image(systemName: "scalemass")
                                .accessibilityLabel("Weight icon")
                        case "Bench":
                            Image(systemName: "scalemass")
                                .accessibilityLabel("Weight icon")
                        case "Deadlift":
                            Image(systemName: "figure.strengthtraining.traditional")
                                .accessibilityLabel("Deadlift icon")
                        default:
                            Image(systemName: "scalemass")
                                .accessibilityLabel("Weight icon")
                        }
                        
                        HStack {
                            TextField("Weight", text: $weight)
                                .keyboardType(.decimalPad)
                                .frame(width: 150)
                                .padding(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.green, lineWidth: 1)
                                )
                                .tint(.green)
                            Text(isMetric ? "kg" : "lbs")
                                .padding(.leading, 5)
                        }
                        .padding(.horizontal)
                    }
                    }
            }
            .foregroundColor(.primary)
            .onTapGesture {
                self.hideKeyboard()
            }
            
            HStack {
                Spacer()
                DatePicker("Date", selection: $date, in: ...Date.now, displayedComponents: .date)
                    .datePickerStyle(.compact)
                Spacer()
            }
                
            TextField("Enter Note", text: $note)
                .padding(.leading)
            
            Button(action: {
                dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
                result = validate()
                if result == "Valid" {
                    if isMetric {
                        WeightVM.value = Double(weight)?.convertToImperial ?? 0.0
                    } else {
                        WeightVM.value = Double(weight) ?? 0.0
                    }
                    //match formatting in CloudKit and HealthKit
                    let formattedDate = dateFormatter.string(from: date)
                    WeightVM.date = dateFormatter.date(from: formattedDate) ?? Date.now
                    WeightVM.note = note
                    WeightVM.addWeightForWorkout(workoutModel: type)
                    if type.type == "Body Weight" && HealthKitVM.isAuthorized {
                        HealthKitVM.importIntoHealthKit(date: dateFormatter.string(from: date), bodyMass: Double(weight) ?? 0.0)
                    }
                    date = Date.now
                    self.note = ""
                    self.hideKeyboard()
                    self.value = nil
                    
                    WeightVM.getWeightsByType(workoutModel: type)
                    
                    dismiss()
                } else {
                    error = true
                }
            }, label: {
                Text("Submit")
                    .frame(width: 200)
            })
            .buttonStyle(.borderedProminent)
            .tint(Color(.systemGreen))
            .buttonBorderShape(.roundedRectangle(radius: 12))
            .alert(result, isPresented: $error) {
                Button("Ok", role: .cancel) { }
            }
            .sheet(isPresented: $promptPremium,  onDismiss: {
                promptPremium = false
            }, content: {
                Paywall(isPaywallPresented: $promptPremium)
            })
        }.onAppear {
            isMetric = UserDefaults.standard.bool(forKey: "isMetric")
        }
    }
    
    func validate() -> String {
        if weight == "" || weight == "0" {
           return "Please enter a weight"
        } else {
            if isSubscribed() {
                return "Valid"
            } else {
                if countEntries() < 10 {
                    return "Valid"
                } else {
                    promptPremium = true
                    return "\(type.type!) has 10 or more entries, please subscribe to premium or delete old entries"
                }
            }
        }
    }
    
    func isSubscribed() -> Bool {
        if userViewModel.isSubscriptionActive {
            return true
        } else {
            return false
        }
    }
    
    func countEntries() -> Int {
        return WeightVM.weights.count
    }
}

struct AddWeightView_Previews: PreviewProvider {
    
    static let userViewModel = UserManager()
    
    static var previews: some View {
        let workout = WorkoutModel(workout: Workout(context: CoreDataManager.shared.viewContext))
        AddWeightView(type: workout)
            .environment(userViewModel)
            
    }
}
