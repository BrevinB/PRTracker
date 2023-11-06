//
//  OnboardingView.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 11/3/23.
//

import SwiftUI
import RevenueCatUI

//on close button set initialWorkoutSet = true

struct OnboardingView: View {
    @AppStorage("initialWorkoutSet") private var initialWorkoutSet: Bool = false
    @StateObject private var WorkoutVM = WorkoutViewModel()
    @State private var allowClose: Bool = false
    @State private var loadingData: Bool = false
    @State private var showPremium: Bool = false
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 40) {
                HStack {
                    VStack() {
                        Text("Welcome To")
                            .font(.title)
                            .foregroundStyle(.primary)
                            .bold()
                        Text("PR-Tracker")
                            .font(.title)
                            .foregroundStyle(.green)
                            .bold()
                    }.padding(.leading)
                    Spacer()
                }.padding()
                    
                //            Button("TEST") {
                //                initialWorkoutSet = true
                //                print("DOES DATA EXIST? \(CoreDataManager.shared.checkForExistingData())")
                
                
               
                VStack(alignment: .leading, spacing: 40) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add new records to your charts to track progress!")
                    }
                    
                    HStack {
                        Image(systemName: "gear")
                        Text("With premium, add additional workout variations to track like overhead press!")
                    }
                    
                    HStack {
                        Image(systemName: "star")
                        Text("With premium, add goals to help better track your progress!")
                    }
                    
                    HStack {
                        Image(systemName: "note.text")
                        Text("Add notes to your weights to remind yourself how you feel!")
                    }
                    
                }.padding(.trailing, 10).padding(.leading, 10)
                
                
                Button(action: {
                    showPremium.toggle()
                }, label: {
                    Text("Continue")
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.black)
                        .bold()
                })
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(.green)
                .controlSize(.large)
                .padding()
            }
            .sheet(isPresented: $showPremium, onDismiss: {
                loadingData = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    if CoreDataManager.shared.checkForExistingData() {
                        loadingData = false
                        initialWorkoutSet = true
                    } else {
                        WorkoutVM.addNewWorkout(type: "Body Weight")
                        WorkoutVM.addNewWorkout(type: "Squat")
                        WorkoutVM.addNewWorkout(type: "Bench")
                        WorkoutVM.addNewWorkout(type: "Deadlift")
                        
                        loadingData = false
                        initialWorkoutSet = true
                    }                    
                }
            }){
                PaywallView(displayCloseButton: true)
            }
            
            if loadingData {
                Blur(style: .systemThinMaterial)
            }
            
            VStack {
                if loadingData {
                    ProgressView {
                         Text("Loading Initial Data")
                             .foregroundColor(.green)
                             .bold()
                     }
                }
            }
            
            
        }.ignoresSafeArea(.all, edges: .all)
    }
}

#Preview {
    OnboardingView()
}
