//
//  UserViewModel.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 6/23/23.
//

import Foundation
import RevenueCat

@Observable class UserManager {
    
    var isSubscriptionActive = false
    
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_yhjPcPtPaIzsgSrkfvGGkjBTfmT")
        
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements.all["Premium"]?.isActive == true {
                // User is "premium"
                self.isSubscriptionActive = true
            }
        }
    }
}
