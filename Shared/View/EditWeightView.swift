//
//  EditWeightView.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 10/29/23.
//

import SwiftUI

struct EditWeightView: View {
    @Environment(WeightViewModel.self) private var WeightVM
    @Environment(\.dismiss) private var dismiss
    var weight: WeightModel
    @State private var weightValue: Double = 0.0
    @State private var dateValue: Date? = nil
    @State private var noteValue: String = ""
    @Binding var isMetric: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Weight")
                .font(.headline)
            
            TextField("Weight", value: $weightValue, format: .number)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.primary.opacity(0.1).cornerRadius(10))
                .foregroundColor(.primary)
                .font(.headline)
                .padding(.horizontal)
            
            DatePicker(
                "Date and Time", selection: Binding<Date>(get: {self.dateValue ?? Date()}, set: {self.dateValue = $0})
            ).datePickerStyle(.compact)
            
            Text("Notes")
                .font(.headline)
            TextField("Notes", text: $noteValue)
                .padding()
                .background(Color.primary.opacity(0.1).cornerRadius(10))
                .foregroundColor(.primary)
                .font(.headline)
                .padding(.horizontal)
        }.padding()
        
        VStack() {
            Button {
                submitWeight(isMetric)
                dismiss()
            } label: {
                Text("Update")
                    .frame(width: 200)
            }.buttonStyle(.borderedProminent)
                .tint(Color("PrimaryAccent"))
                .buttonBorderShape(.roundedRectangle(radius: 12))
        }
        .padding(.vertical, 20)
        .onAppear {
            if isMetric {
                weightValue = weight.value.convertToMetric
            } else {
                weightValue = weight.value
            }
            dateValue = weight.date ?? Date.now
            noteValue = weight.note ?? ""
        }
    }
    
    private func submitWeight(_ isMetric: Bool) {
        
        if isMetric {
            let newVal = weightValue.convertToImperial
            WeightVM.updateWeight(weightId: weight.weightId, weight: newVal, note: noteValue, date: dateValue ?? Date.now)
        } else {
            WeightVM.updateWeight(weightId: weight.weightId, weight: weightValue, note: noteValue, date: dateValue ?? Date.now)
        }
    }
}
