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
    @ObservedObject var WorkoutVM: WorkoutViewModel
    @ObservedObject var WeightVM: WeightViewModel
    @ObservedObject var HealthKitVM: HealthKitViewModel
    @EnvironmentObject var userViewModel: UserViewModel
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
                Text(type.type ?? "Test")
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
                        case "Squat":
                            Image(systemName: "scalemass")
                        case "Bench":
                            Image(systemName: "scalemass")
                        case "Deadlift":
                            Image(systemName: "figure.strengthtraining.traditional")
                        default:
                            Image(systemName: "scalemass")
                        }
                        
                        HStack {
                            TextField("Weight", text: $weight)
                                .keyboardType(.decimalPad)
                                .frame(width: 150)
                                .padding(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                                .onReceive(Just(weight)) { _ in limitText(weightLimit)}
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
                    dismiss()
                } else {
                    error = true
                }
                
            }, label: {
                Text("Submit")
                    .frame(width: 200)
                    //.foregroundColor(.green)
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
    
    func limitText(_ upper: Int) {
        if weight.count > upper {
            weight = String(weight.prefix(upper))
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
    
    static let userViewModel = UserViewModel()
    
    static var previews: some View {
        let workout = WorkoutModel(workout: Workout(context: CoreDataManager.shared.viewContext))
        AddWeightView(WorkoutVM: WorkoutViewModel(), WeightVM: WeightViewModel(), HealthKitVM: HealthKitViewModel(), type: workout)
            .environmentObject(userViewModel)
            
    }
}
