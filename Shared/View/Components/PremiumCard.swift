//
//  PremiumCard.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 6/14/23.
//

import SwiftUI

struct PremiumCard: View {
    
    let cardWidth: CGFloat = 250
    let cardHeight: CGFloat = 55
    var cardTitle: String
    var cardDescription: String
    var secondCardDescription: String
    
    var body: some View {
        VStack {
            ZStack {
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black)
                    //.frame(width: cardWidth, height: cardHeight)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(cardTitle)
                            .font(.title3)
                        Spacer()
                    }
                    
                    HStack {
                        Text(cardDescription)
                            .font(.title2)
                            .bold()
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text(secondCardDescription)
                            .font(.subheadline)
                    }
                }
                .padding()
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .foregroundColor(.white)
    }
}

struct PremiumCard_Previews: PreviewProvider {
    static var previews: some View {
        PremiumCard(cardTitle: "Monthly Plan", cardDescription: "$0.99 / month", secondCardDescription: "Billed monthly")
    }
}
