//
//  HealthKitViewModel.swift
//  PRTracker
//
//  Created by Brevin Blalock on 3/24/23.
//

import Foundation
import HealthKit

class HealthKitViewModel : ObservableObject {
    private var healthStore = HKHealthStore()
    private var healthKitManager = HealthKitStore()
    @Published var userBodyMass = "Empty"
    @Published var isAuthorized = false
    
    func healthRequest() {
        healthKitManager.setUpHealthRequest(healthStore: healthStore) {
            self.changeAuthorizationStatus()
        }
    }
    
    
    func changeAuthorizationStatus() {
        guard let weightQtyType = HKObjectType.quantityType(forIdentifier: .bodyMass) else { return }
        let status = self.healthStore.authorizationStatus(for: weightQtyType)
        
        switch status {
        case .notDetermined:
            isAuthorized = false
        case .sharingDenied:
            isAuthorized = false
        case .sharingAuthorized:
            isAuthorized = true
        @unknown default:
            isAuthorized = false
        }
    }
    
    func importData() {
        healthKitManager.importOldData(healthStore: healthStore)
    }
    
    func importIntoHealthKit(date: String, bodyMass: Double) {
        print(date)
        healthKitManager.importBodyMassData(date: date, bodyMass: bodyMass)
    }
    
    func deleteData(date: Date, bodyMass: Double) {
        print("DATE IS \(date)")
        print("BODY MASS IS \(bodyMass)")
        healthKitManager.deleteBodyMassData(dateDelete: date, bodyMassDelete: bodyMass)
    }
}
