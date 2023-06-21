//
//  KeyboardDismiss.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 9/25/22.
//
import Foundation
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
