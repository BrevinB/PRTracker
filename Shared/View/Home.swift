//
//  Home.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 8/12/22.
//

import SwiftUI
import CoreData
import RevenueCatUI
import ConfettiSwiftUI

struct Home: View {
    @AppStorage("initialWorkoutSet") private var initialWorkoutSet: Bool = true
    @StateObject var WorkoutVM = WorkoutViewModel()
    @StateObject var WeightVM = WeightViewModel()
    @StateObject var HealthKitVM = HealthKitViewModel()
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var currentChartTab: String = "3"
    @FetchRequest private var chartTypes: FetchedResults<Workout>
    @State private var currentChartTypeTab: WorkoutModel
    @State private var type = ""
    @State private var refresh: Bool = false
    @State private var isMetric: Bool = false
    @State private var showNewWeight: Bool = false
    @State private var showWeightList: Bool = false
    @State private var showSettings: Bool = false
    @State private var showAddGoal: Bool = false
    @State private var showPremium: Bool = false
    @State private var recentWeight: Double = 0.0
    @State private var firstWeight: Double = 0.0
    @State private var confettiCount: Int = 0
    @State private var showCongratsAlert: Bool = false
    @State private var isLoading: Bool = false
    
    init(moc: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.type, ascending: true)]
        fetchRequest.predicate = NSPredicate(value: true)
        self._chartTypes = FetchRequest(fetchRequest: fetchRequest)
        
        do {
            let firstType = try moc.fetch(fetchRequest)
            self._currentChartTypeTab = State(initialValue: WorkoutModel(workout: firstType[0]))
        } catch {
            fatalError("Uh, fetch problem....\(error)")
        }
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                HStack {
                    Menu {
                        Picker("", selection: $currentChartTypeTab) {
                            ForEach(WorkoutVM.workouts, id: \.typeId) { workout in
                                Text(workout.type ?? "")
                                    .tag(workout)
                            }
                        }
                    } label: {
                        withAnimation {
                            pickerLabelView
                        }
                    }
                    Spacer()
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Picker("", selection: $currentChartTab.animation(.spring(dampingFraction: 0.4))) {
                                Text("3 Months")
                                    .tag("3")
                                Text("6 Months")
                                    .tag("6")
                                Text("Year")
                                    .tag("Year")
                                Text("All Time")
                                    .tag("all")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .labelsHidden()
                        }
                        
                        HStack {
                            if(currentChartTypeTab.type != "Body Weight") {
                                let max = WeightVM.weights.max { item1, item2 in
                                    return item2.value > item1.value
                                }?.value ?? 0.0
                                
                                if checkInt(val: max) {
                                    Text("PR: \(max.intFormat)")
                                        .font(.largeTitle.bold())
                                    if(currentChartTypeTab.type == "Deadlift") {
                                        Image(systemName: "figure.strengthtraining.traditional")
                                    }
                                } else {
                                    Text("PR: \(max.doubleFormat)")
                                        .font(.largeTitle.bold())
                                    if(currentChartTypeTab.type == "Deadlift") {
                                        Image(systemName: "figure.strengthtraining.traditional")
                                    }
                                }
                                
                            }
                            
                            Spacer()
                            Button(action: {
                                getRecentWeight()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    if userViewModel.isSubscriptionActive {
                                        showAddGoal.toggle()
                                    } else {
                                        showPremium.toggle()
                                    }
                                }
                                //toggle show goal
                            }, label: {
                                if currentChartTypeTab.goal == 0.0 {
                                    Text("Add Goal")
                                        .fontWeight(.bold)
                                } else {
                                    Text("Edit Goal")
                                        .fontWeight(.bold)
                                }
                            })
                        }
                        
                        switch(currentChartTab) {
                        case "3":
                            AnimatedChart(chartType: $currentChartTypeTab, WeightsVM: WeightVM, weights: $WeightVM.threeMonthWeights, chartRange: $currentChartTab, isMetric: $isMetric)
                        case "6":
                            AnimatedChart(chartType: $currentChartTypeTab, WeightsVM: WeightVM, weights: $WeightVM.sixMonthWeights, chartRange: $currentChartTab, isMetric: $isMetric)
                        case "Year":
                            AnimatedChart(chartType: $currentChartTypeTab, WeightsVM: WeightVM, weights: $WeightVM.oneYearWeights, chartRange: $currentChartTab, isMetric: $isMetric)
                        case "all":
                            AnimatedChart(chartType: $currentChartTypeTab, WeightsVM: WeightVM, weights: $WeightVM.allTimeWeights, chartRange: $currentChartTab, isMetric: $isMetric)
                        default:
                            AnimatedChart(chartType: $currentChartTypeTab, WeightsVM: WeightVM, weights: $WeightVM.threeMonthWeights, chartRange: $currentChartTab, isMetric: $isMetric)
                            
                        }
                        
                        
                    }
                    .padding()
                    
                    //Spacer()
                    VStack {
                        switch(currentChartTab) {
                        case "3":
                            WeightsList(WeightVM: WeightVM, HealthKitVM: HealthKitVM, weights: $WeightVM.threeMonthWeights, type: $currentChartTypeTab, isMetric: $isMetric, refresh: $refresh)
                        case "6":
                            WeightsList(WeightVM: WeightVM, HealthKitVM: HealthKitVM, weights: $WeightVM.sixMonthWeights, type: $currentChartTypeTab, isMetric: $isMetric, refresh: $refresh)
                        case "Year":
                            WeightsList(WeightVM: WeightVM, HealthKitVM: HealthKitVM, weights: $WeightVM.oneYearWeights, type: $currentChartTypeTab, isMetric: $isMetric, refresh: $refresh)
                        case "all":
                            WeightsList(WeightVM: WeightVM, HealthKitVM: HealthKitVM, weights: $WeightVM.allTimeWeights, type: $currentChartTypeTab, isMetric: $isMetric, refresh: $refresh)
                        default:
                            Text("No Weights")
                        }
                        
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()
                .onChange(of: currentChartTypeTab) { tag in
                    refresh.toggle()
                }
                .onChange(of: refresh) { newValue in
                    if newValue {
                        //Get new weight
                        WeightVM.weights.removeAll()
                        WeightVM.filteredWeights.removeAll()
                        WeightVM.getWeightsByType(workoutModel: currentChartTypeTab)
                        getFilteredWeights()
                        getRecentWeight()
                        refresh.toggle()
                    }
                }
                .toolbar {
                    Button(action: {
                        showSettings.toggle()
                    }, label: {
                        Image(systemName: "gear")
                    })
                    Button(action: {
                        showNewWeight.toggle()
                    }, label: {
                        Image(systemName: "plus.circle")
                    })
                }
                .sheet(isPresented: $showNewWeight, onDismiss: {
                    isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        refresh.toggle()
                        WeightVM.filterAllTime()
                    }
                    Task  {
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        await checkGoal()
                        isLoading = false
                    }
                    
                }, content: {
                    AddWeightView(WorkoutVM: WorkoutVM, WeightVM: WeightVM, HealthKitVM: HealthKitVM, type: currentChartTypeTab)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.automatic)
                })
                .sheet(isPresented: $showSettings, onDismiss: {
                    refresh.toggle()
                }, content: {
                    SettingsView(WorkoutVM: WorkoutVM, HealthVM: HealthKitVM, WeightVM: WeightVM, isMetric: $isMetric)
                })
                .sheet(isPresented: $showPremium, onDismiss: {
                    
                }, content: {
                    PaywallView(displayCloseButton: true)
                })
                .sheet(isPresented: $showAddGoal, onDismiss: {
                    
                }, content: {
                    AddGoalCard(WorkoutVM: WorkoutVM, type: $currentChartTypeTab, refresh: $refresh, isMetric: $isMetric, startingValue: $firstWeight, targetValue: currentChartTypeTab.goal ?? 0.0, currentValue: $recentWeight)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.automatic)
                })
                .confettiCannon(counter: $confettiCount)
            }
            .onAppear {
                WorkoutVM.getAllWorkouts()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    currentChartTypeTab = WorkoutVM.workouts[0]
                }
                isMetric = UserDefaults.standard.bool(forKey: "isMetric")
            }
            .alert("Congrats on hitting your goal of \(currentChartTypeTab.goal?.doubleFormat ?? "0.0 lbs")! Consider setting a new goal!!", isPresented: $showCongratsAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Set new goal", role: .cancel) {
                    getRecentWeight()
                    showAddGoal.toggle()
                    showCongratsAlert = false
                }
            }
            
            if isLoading {
                ProgressView("Loading...").progressViewStyle(.circular).tint(.blue).foregroundStyle(.blue) // Display a loading spinner
            }
        }
        
    }
    
    private func getRecentWeight() {
        recentWeight = WeightVM.allTimeWeights.first?.value ?? 0.0
        firstWeight = WeightVM.allTimeWeights.last?.value ?? 0.0
    }
    
    private func deleteWorkout(at offsets: IndexSet) {
        offsets.forEach { offset in
            let workout = WorkoutVM.workouts[offset]
            WorkoutVM.deleteWorkout(workout: workout)
        }
        
        WorkoutVM.getAllWorkouts()
        getFilteredWeights()
    }
    
    private func getFilteredWeights() {
        switch(currentChartTab) {
        case "3":
            WeightVM.filterWeights(month: -3)
        case "6":
            WeightVM.filterWeights(month: -6)
        case "Year":
            WeightVM.filterWeights(month: -12)
        case "all":
            WeightVM.filterWeights(month: 0)
        default:
            WeightVM.filterWeights(month: -3)
            
        }
    }
    
    private func deleteValue(at offsets: IndexSet) {
        offsets.forEach { offset in
            let weight = WeightVM.weights[offset]
            if currentChartTypeTab.type == "Body Weight" {
                HealthKitVM.deleteData(date: weight.date ?? Date.now, bodyMass: weight.value)
            }
            WeightVM.deleteWeight(weight: weight)
        }
        WeightVM.weights.removeAll()
        WeightVM.filteredWeights.removeAll()
        WeightVM.getWeightsByType(workoutModel: currentChartTypeTab)
        getFilteredWeights()
    }
    
    func checkInt(val: Double) -> Bool {
        return floor(val) == val
    }
    
    var pickerLabelView: some View {
        HStack {
            Text(currentChartTypeTab.type ?? "Body Weight")
                .padding(.leading)
            Text("⌵")
                .offset(y: -4)
        }
        .frame(minWidth: currentChartTypeTab.type != "Body Weight" ? 150 : 250)
        .foregroundColor(.primary)
        .font(.title)
        .fontWeight(.bold)
        .padding(.leading)
    }
    
    private func checkGoalStatus(currWeight: Double, goalWeight: Double, type: String) -> Bool {
        if currWeight != 0.0 {
            if type == "Body Weight" {
                return currWeight <= goalWeight
            } else {
                if goalWeight != 0.0 {
                    return currWeight >= goalWeight
                } else {
                    return false
                }
            }
        } else {
            return false
        }
        
        
        
    }
    
    private func checkGoal() async {
        getRecentWeight()
        //Check if new weight meets the goal
        if userViewModel.isSubscriptionActive {
            if checkGoalStatus(currWeight: recentWeight, goalWeight: currentChartTypeTab.goal ?? 0.0, type: currentChartTypeTab.type ?? "Body Weight") {
                //GOAL HIT
                //show a congrats card
                showCongratsAlert = true
                confettiCount += 1
                //Prompt new goal
            } else {
                print("NO GOAL")
            }
        }
    }
}

// MARK: Extension to convert Double to String with lbs / kg
extension Double {
    var doubleFormat: String {
        let isMetric = UserDefaults.standard.bool(forKey: "isMetric")
        return String(format: "%.2f \(isMetric ? "kgs" : "lbs")", isMetric ? self.convertToMetric : self)
    }
    
    var intFormat: String {
        let isMetric = UserDefaults.standard.bool(forKey: "isMetric")
        return String(format: "%.0f \(isMetric ? "kgs" : "lbs")", isMetric ? self.convertToMetric : self)
    }
    
    var convertToMetric: Double {
        return self * 0.453592
    }
    
    var convertToImperial: Double {
        return self * 2.2046226218
    }
}

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
}
