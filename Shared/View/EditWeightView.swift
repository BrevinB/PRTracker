//
//  EditWeightView.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 10/29/23.
//

import SwiftUI

struct EditWeightView: View {
    @ObservedObject var WeightVM: WeightViewModel
    @Environment(\.dismiss) private var dismiss
    var weight: WeightModel
    @State private var weightValue: Double = 0.0
    @State private var dateValue: Date? = nil
    @State private var noteValue: String = ""
  
//    init(weight: WeightModel) {
//        self.weight = weight
//        self.weightValue = weight.value
//        self.dateValue = weight.date ?? Date.now
//        self.noteValue = weight.note ?? ""
//    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Weight")
                .font(.headline)
            TextField("Weight", value: $weightValue, format: .number)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.primary.opacity(0.3).cornerRadius(10))
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
                .background(Color.primary.opacity(0.3).cornerRadius(10))
                .foregroundColor(.primary)
                .font(.headline)
                .padding(.horizontal)
        }
        
        VStack() {
            Button {
                submitWeight()
                dismiss()
            } label: {
                Text("Update")
            }.buttonStyle(.borderedProminent).buttonBorderShape(.capsule)
        }
        .padding(.vertical, 20)
        .onAppear {
            weightValue = weight.value
            dateValue = weight.date ?? Date.now
            noteValue = weight.note ?? ""
        }
       
    }
    
    private func submitWeight() {
        WeightVM.updateWeight(weightId: weight.weightId, weight: weightValue, note: noteValue, date: dateValue ?? Date.now)
    }
}


