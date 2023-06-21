//
//  TestHealthKitStore.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 5/22/23.
//

import HealthKit
import SwiftUI


func fetchBodyMass() {
    let healthStore = HKHealthStore()
    
    // Check if body mass data is available
    guard HKHealthStore.isHealthDataAvailable() else {
        print("HealthKit data is not available")
        return
    }
    
    // Request authorization to read body mass data
    let typesToRead: Set<HKQuantityType> = [HKQuantityType.quantityType(forIdentifier: .bodyMass)!]
    healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
        if let error = error {
            print("Error requesting HealthKit authorization: \(error.localizedDescription)")
            return
        }
        
        if success {
            // Set the date range for the past three months
            let endDate = Date()
            let calendar = Calendar.current
            let startDate = calendar.date(byAdding: .month, value: -3, to: endDate)
            // Create the predicate for the query
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            
            // Create the query for body mass data
            let query = HKSampleQuery(
                sampleType: HKQuantityType.quantityType(forIdentifier: .bodyMass)!,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { query, results, error in
                if let error = error {
                    print("Error fetching body mass data: \(error.localizedDescription)")
                    return
                }
                
                if let bodyMassSamples = results as? [HKQuantitySample] {
                    let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .medium
                        dateFormatter.timeStyle = .short
                    
                    for sample in bodyMassSamples {
                        let bodyMass = sample.quantity.doubleValue(for: .pound())
                        let date = sample.endDate
                        let formattedDate = dateFormatter.string(from: date)
                        print("Body Mass: \(bodyMass) lbs")
                        print("\(formattedDate)")
                    }
                }
            }
            
            healthStore.execute(query)
        }
    }
}
