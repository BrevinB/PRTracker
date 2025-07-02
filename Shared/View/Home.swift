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

enum DataDurationContext: CaseIterable, Identifiable {
    case three, six, year, alltime
    var id: Self { self }
    var title: String {
        switch self {
        case .three:
            return "3 Months"
        case .six:
            return "6 Months"
        case .year:
            return "Year"
        case .alltime:
            return "All"
        }
    }
}

struct Home: View {
    @AppStorage("initialWorkoutSet") private var initialWorkoutSet: Bool = true
    @Environment(WorkoutViewModel.self) private var WorkoutVM
    @Environment(WeightViewModel.self) private var WeightVM
    @Environment(HealthKitManager.self) private var HealthKitVM
    @Environment(UserManager.self) private var userViewModel
    
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
    @State private var selectedDuration: DataDurationContext = .three
    
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
                            Picker("", selection: $selectedDuration) {
                                ForEach(DataDurationContext.allCases) {
                                    Text($0.title)
                                }
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
                                            .accessibilityHidden(true)
                                    }
                                } else {
                                    Text("PR: \(max.doubleFormat)")
                                        .font(.largeTitle.bold())
                                    if(currentChartTypeTab.type == "Deadlift") {
                                        Image(systemName: "figure.strengthtraining.traditional")
                                            .accessibilityHidden(true)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    if userViewModel.isSubscriptionActive {
                                        showAddGoal.toggle()
                                    } else {
                                        showPremium.toggle()
                                    }
                                }
                            }, label: {
                                if currentChartTypeTab.goal == 0.0 {
                                    Text("Add Goal")
                                        .fontWeight(.bold)
                                        .tint(.green)
                                } else {
                                    Text("Edit Goal")
                                        .fontWeight(.bold)
                                        .tint(.green)
                                }
                            })
                        }
                        
                        switch selectedDuration {
                        case .three:
//                            AnimatedChart(chartType: $currentChartTypeTab, weights: WeightVM.threeMonthWeights, selectedDuration: selectedDuration, isMetric: $isMetric)
                            WeightLineChart(chartData: WeightVM.threeMonthWeights, workout: currentChartTypeTab)
                        case .six:
//                            AnimatedChart(chartType: $currentChartTypeTab, weights: WeightVM.sixMonthWeights, selectedDuration: selectedDuration, isMetric: $isMetric)
                            WeightLineChart(chartData: WeightVM.sixMonthWeights, workout: currentChartTypeTab)

                        case .year:
//                            AnimatedChart(chartType: $currentChartTypeTab, weights: WeightVM.oneYearWeights, selectedDuration: selectedDuration, isMetric: $isMetric)
                            WeightLineChart(chartData: WeightVM.oneYearWeights, workout: currentChartTypeTab)

                        case .alltime:
//                            AnimatedChart(chartType: $currentChartTypeTab, weights: WeightVM.allTimeWeights, selectedDuration: selectedDuration, isMetric: $isMetric)
                            WeightLineChart(chartData: WeightVM.allTimeWeights, workout: currentChartTypeTab)

                        }
                    }
                    .padding()
                    
                    VStack {
                        switch selectedDuration {
                        case .three:
                            WeightsList(weights: WeightVM.threeMonthWeights, type: $currentChartTypeTab, isMetric: $isMetric, refresh: $refresh)
                        case .six:
                            WeightsList(weights: WeightVM.sixMonthWeights, type: $currentChartTypeTab, isMetric: $isMetric, refresh: $refresh)
                        case .year:
                            WeightsList(weights: WeightVM.oneYearWeights, type: $currentChartTypeTab, isMetric: $isMetric, refresh: $refresh)
                        case .alltime:
                            WeightsList(weights: WeightVM.allTimeWeights, type: $currentChartTypeTab, isMetric: $isMetric, refresh: $refresh)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()
                .onChange(of: currentChartTypeTab) {
                    refresh.toggle()
                }
                .onChange(of: refresh) {
                    WeightVM.getWeightsByType(workoutModel: currentChartTypeTab)
                    getFilteredWeights()
                }
                .toolbar {
                    Button(action: {
                        showSettings.toggle()
                    }, label: {
                        Image(systemName: "gear")
                            .tint(.green)
                            .accessibilityLabel("Settings")
                    })
                    .accessibilityLabel("Settings")
                    Button(action: {
                        showNewWeight.toggle()
                    }, label: {
                        Image(systemName: "plus.circle")
                            .tint(.green)
                            .accessibilityLabel("Add weight")
                    })
                    .accessibilityLabel("Add weight")
                }
                .sheet(isPresented: $showNewWeight, onDismiss: {
                    isLoading = true
                    getFilteredWeights()
                    Task {
                        await checkGoal()
                    }
                }, content: {
                    AddWeightView(type: currentChartTypeTab)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.automatic)
                })
                .sheet(isPresented: $showSettings, onDismiss: {
                    refresh.toggle()
                }, content: {
                    SettingsView(isMetric: $isMetric)
                })
                .sheet(isPresented: $showPremium, onDismiss: {
                    
                }, content: {
                    PaywallView(displayCloseButton: true)
                })
                .sheet(isPresented: $showAddGoal, onDismiss: {
                    
                }, content: {
                    AddGoalCard(type: $currentChartTypeTab, refresh: $refresh, targetValue: currentChartTypeTab.goal ?? 0.0, isMetric: $isMetric)
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
                    showAddGoal.toggle()
                    showCongratsAlert = false
                }
            }
        }
        
    }
    
    private func getRecentWeight() async {
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
        switch selectedDuration {
        case .three:
            WeightVM.filterWeights(month: -3)
        case .six:
            WeightVM.filterWeights(month: -6)
        case .year:
            WeightVM.filterWeights(month: -12)
        case .alltime:
            WeightVM.filterWeights(month: 0)
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
        //Check if new weight meets the goal
        if userViewModel.isSubscriptionActive {
            if checkGoalStatus(currWeight: WeightVM.weights.first?.value ?? 0.0, goalWeight: currentChartTypeTab.goal ?? 0.0, type: currentChartTypeTab.type ?? "Body Weight") {
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
        return String(format: "%.1f \(isMetric ? "kgs" : "lbs")", isMetric ? self.convertToMetric : self)
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
