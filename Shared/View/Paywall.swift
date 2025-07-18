//
//  Paywall.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 6/14/23.
//

import SwiftUI
import RevenueCat

struct Paywall: View {
    
    @Binding var isPaywallPresented: Bool
    
    @State var currentOffering: Offering?
    @State private var isPurchasing = false
    @State private var isLoading = false
    @State private var showAlert = false
    @Environment(UserManager.self) private var userViewModel
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack(alignment: .leading, spacing: 20) {
                    Text("PR-Tracker Premium")
                        .bold()
                        .font(Font.largeTitle)
                    
                    Text("Unlock all features.")
                    
                    Spacer()
                    
                    VStack(spacing: 40) {
                        HStack {
                            Image(systemName: "dumbbell")
                                .accessibilityHidden(true)
                            Text("Unlimited entries for any workout")
                        }
                        
                        HStack {
                            Image(systemName: "plus.circle")
                                .accessibilityHidden(true)
                            Text("Add additional workout options to track")
                        }
                        
                        HStack {
                            Image(systemName: "paintpalette")
                                .accessibilityHidden(true)
                            Text("Customize chart colors and more")
                        }
                        
                        HStack {
                            Image(systemName: "arrow.up.heart")
                                .accessibilityHidden(true)
                            Text("Import old data from HealthKit")
                        }
                    }
                    
                    Spacer()
                    
                    if currentOffering != nil {
                        
                        ForEach(currentOffering!.availablePackages) { pkg in
                            VStack {
                                Button  {
                                    Purchases.shared.purchase(package: pkg) { (transaction, customerInfo, error, userCancelled) in
                                        isPurchasing = true
                                        if customerInfo?.entitlements.all["Premium"]?.isActive == true {
                                            // Unlock that great "pro" content
                                            userViewModel.isSubscriptionActive = true
                                            isPaywallPresented = false
                                        }
                                    }
                                    isPurchasing = false
                                } label: {
                                    
                                    PremiumCard(cardTitle: pkg.storeProduct.subscriptionPeriod!.periodTitle, cardDescription: pkg.storeProduct.localizedPriceString, secondCardDescription: pkg.storeProduct.localizedDescription)
                                }
                                .padding(30)
                            }
                        }
                        Spacer()
                    }
                }
                .padding(50)
                .onAppear {
                    Purchases.shared.getOfferings { offerings, error in
                        if let offer = offerings?.current, error == nil {
                            currentOffering = offer
                        } else {
                            showAlert = true
                        }
                    }
                   
                }
                .alert("Error getting payment options, please check internet connection", isPresented: $showAlert) {
                            Button("OK", role: .cancel) { }
                        }
            }
            
            if isLoading {
                ProgressView("Getting payment options")
                    .progressViewStyle(.circular)
            }
            
            /// - Display an overlay during a purchase
            Rectangle()
                .foregroundColor(Color.black)
                .opacity(isPurchasing ? 0.5: 0.0)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
