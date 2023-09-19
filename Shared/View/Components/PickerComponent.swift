//
//  Picker.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 10/30/22.
//

import SwiftUI

struct PickerComponent: View {
    @State private var currentChartTypeTab: String = "Body Weight"
    let types = ["Body Weight", "Squat", "Bench", "Deadlift"]
    var body: some View {
        Menu {
            Picker("", selection: $currentChartTypeTab) {
                ForEach (types, id: \.self) { type in
                    Text("\(type)")
                }
            }
        } label: {
            pickerLabelView
        }
    }
    
    var pickerLabelView: some View {
            HStack {
                    Text(currentChartTypeTab)
                    .padding()
                    Text("⌵")
                        .offset(y: -4)
                }
                .foregroundColor(.black)
                .font(.title)
                .fontWeight(.bold)
                .frame(width: 250, height: 32)
                .padding()
                .background(Color.green)
                .cornerRadius(16)
    }
}

struct PickerComponent_Previews: PreviewProvider {
    static var previews: some View {
        PickerComponent()
    }
}
