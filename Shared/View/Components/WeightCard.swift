//
//  WeightCard.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 7/19/23.
//

import SwiftUI

struct WeightCard: View {
    var body: some View {
        VStack {
            HStack {
                Text("285 lbs")
                Text("\(Date().formatted())")
            }
            HStack() {
                Text("Notes")
                    .padding(.leading)
                    .padding(.trailing)
            }
        }
    }
}

struct WeightCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeightCard()

            WeightCard()
                .preferredColorScheme(.dark)
        }
    }
}
