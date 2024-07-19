//
//  WeightRowView.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 1/31/24.
//

import SwiftUI

struct WeightRowView: View {
    let weight = 285.0
    let date = Date()
    let note = "Test note"
    let isMetric = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if checkInt(val: weight) {
                    if(isMetric) {
                        Text(weight.convertToMetric.intFormat)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.trailing)
                    } else {
                        Text(weight.intFormat)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                } else {
                    if(isMetric) {
                        Text(weight.convertToMetric.doubleFormat)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.trailing)
                    } else {
                        Text(weight.doubleFormat)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
                
                Text(date.formatted(date: .numeric, time: .shortened))
                    .font(.title3)
                
                Spacer()
            }.padding([.horizontal])
        }
        Text(note)
            .font(.subheadline)
            .lineLimit(1)
    }
    
    var rowFooter: some View {
        VStack(alignment: .leading) {
            Text(note)
                .font(.subheadline)
                .lineLimit(1)
        }
    }
    
    func checkInt(val: Double) -> Bool {
        return floor(val) == val
    }
}

#Preview {
    WeightRowView()
    
}
