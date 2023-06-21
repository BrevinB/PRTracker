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
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            Text("PR-Tracker Premium")
                .bold()
                .font(Font.largeTitle)
            
            Text("Unlock all features.")
            
            Spacer()
            
            VStack(spacing: 40) {
                HStack {
                    Image(systemName: "brain.head.profile")
                    Text("Testing Image       a")
                }
                
                HStack {
                    Image(systemName: "checkmark.icloud")
                    Text("Download for ofline")
                }
                
                HStack {
                    Image(systemName: "shareplay")
                    Text("Destress              a")
                }
            }
            
            Spacer()
            
            if currentOffering != nil {
                
                ForEach(currentOffering!.availablePackages) { pkg in
                    VStack(spacing: 50) {
                        Button  {
                            //BUY
                        } label: {
                            
                            PremiumCard(cardTitle: pkg.storeProduct.subscriptionPeriod!.periodTitle, cardDescription: pkg.storeProduct.localizedPriceString, secondCardDescription: pkg.storeProduct.localizedDescription)
                            
    //                        ZStack {
    //                            Rectangle()
    //                                .frame(height: 55)
    //                                .foregroundColor(.blue)
    //                                .cornerRadius(10)
    //
    //                            Text("\(pkg.storeProduct.subscriptionPeriod!.periodTitle) \(pkg.storeProduct.localizedPriceString)")
    //                                .foregroundColor(.white)
    //                        }
                        }
                        Spacer()
                    }
                }
            

            }
                
            Spacer()
            
            Text("Lourum Ipsum")
        }
        .padding(50)
        .onAppear {
            Purchases.shared.getOfferings { offerings, error in
                if let offer = offerings?.current, error == nil {
                    
                    currentOffering = offer
                }
            }
        }
    }
}

struct Paywall_Previews: PreviewProvider {
    static var previews: some View {
        Paywall(isPaywallPresented: .constant(true))
    }
}
