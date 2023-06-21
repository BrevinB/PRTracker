//
//  Home.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 8/12/22.
//

import SwiftUI
import CoreData

struct Home: View {
    @AppStorage("initialWorkoutSet") private var initialWorkoutSet: Bool = true
    @StateObject var WorkoutVM = WorkoutViewModel()
    @StateObject var WeightVM = WeightViewModel()
    @StateObject var HealthKitVM = HealthKitViewModel()
    @State private var currentChartTab: String = "3"
    @FetchRequest private var chartTypes: FetchedResults<Workout>
    @State private var currentChartTypeTab: WorkoutModel
    @State private var type = ""
    @State private var refresh: Bool = false
    @State private var isMetric: Bool = false
    @State private var showNewWeight: Bool = false
    @State private var showWeightList: Bool = false
    @State private var showSettings: Bool = false
   
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
        NavigationStack {
            HStack {
                Text("")
                    .padding(.leading)
                Menu {
                    Picker("", selection: $currentChartTypeTab) {
                        ForEach(WorkoutVM.workouts, id: \.typeId) { workout in
                            Text(workout.type ?? "")
                                .tag(workout)
                        }
                    }
//                    .onChange(of: currentChartTypeTab) { tag in
//                        print(tag.workout)
//                        print("TESTING")
//                        refresh.toggle()
////                        if(!WeightVM.weights.isEmpty) {
////                            WeightVM.weights.removeAll()
////                            WeightVM.filteredWeights.removeAll()
////                        }
////                        WeightVM.getWeightsByType(workoutModel: tag)
////                        getFilteredWeights()
//                    }
                } label: {
                    pickerLabelView
                }
                .padding(.trailing, 50)
                Spacer()
            }


            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Picker("", selection: $currentChartTab) {
                            Text("3 Months")
                                .tag("3")
                            Text("6 Months")
                                .tag("6")
                            Text("Year")
                                .tag("Year")
                            Text("All Time")
                                .tag("all")
                        }
                        .pickerStyle(.segmented)
                    }
                    .onChange(of: currentChartTab) { tab in
                        WeightVM.filteredWeights.removeAll()
                        getFilteredWeights()
                    }
                    if(currentChartTypeTab.type != "Body Weight") {
                        let max = WeightVM.weights.max { item1, item2 in
                            return item2.value > item1.value
                        }?.value ?? 0.0
                        Text("PR: \(max.stringFormat)")
                            .font(.largeTitle.bold())
                        if(currentChartTypeTab.type == "Deadlift") {
                            Image(systemName: "figure.strengthtraining.traditional")
                        }
                    }
                    
                    AnimatedChart(chartType: $currentChartTypeTab, WeightsVM: WeightVM, chartRange: $currentChartTab, isMetric: $isMetric)

                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.secondarySystemBackground).shadow(.drop(radius: 2)))
                }
                
                
                VStack {
                    if WeightVM.filteredWeights.isEmpty {
                        Text("No Weights")
                    } else {
                        List {
                            ForEach(WeightVM.filteredWeights, id: \.id) { weight in
                                VStack {
                                    HStack {
                                        if(isMetric) {
                                            Text(weight.value.convertToMetric.stringFormat)
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .padding(.trailing)
                                        } else {
                                            Text(weight.value.stringFormat)
                                                .font(.title)
                                                .fontWeight(.bold)
                                                //.padding(.trailing)
                                        }
                                       
                                        Text(weight.date!.formatted(date: .numeric, time: .omitted))
                                            .font(.title3)
                                        Spacer()
                                    }
                                    Text(weight.note ?? "")
                                        .font(.subheadline)
                                } 
                            }.onDelete(perform: deleteValue)
                        }
                        .frame(minWidth: 400, minHeight: 500)
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
                    WeightVM.weights.removeAll()
                    WeightVM.filteredWeights.removeAll()
                    WeightVM.getWeightsByType(workoutModel: currentChartTypeTab)
                    getFilteredWeights()
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
                refresh.toggle()
            }, content: {
                AddWeightView(WorkoutVM: WorkoutVM, WeightVM: WeightVM, HealthKitVM: HealthKitVM, type: currentChartTypeTab)
            })
            .sheet(isPresented: $showSettings, onDismiss: {
                refresh.toggle()
            }, content: {
                SettingsView(WorkoutVM: WorkoutVM, HealthVM: HealthKitVM, isMetric: $isMetric)
            })
        }
        .onAppear {
            WorkoutVM.getAllWorkouts()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                currentChartTypeTab = WorkoutVM.workouts[0]
            }
            isMetric = UserDefaults.standard.bool(forKey: "isMetric")
        }
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
//        refresh.toggle()
        WeightVM.weights.removeAll()
        WeightVM.filteredWeights.removeAll()
        WeightVM.getWeightsByType(workoutModel: currentChartTypeTab)
        getFilteredWeights()
    }
    
    
    var pickerLabelView: some View {
            HStack {
                Text(currentChartTypeTab.type ?? "Body Weight")
                    
                    Text("⌵")
                        .offset(y: -4)
                }
                .foregroundColor(.white)
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: 250)
                .padding(5)
                .background(Color.green)
                .cornerRadius(16)
                
                
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Home(moc: CoreDataManager.shared.viewContext)
            
        }
    }
}

// MARK: Extension to convert Double to String with lbs / kg
//TODO: Implement option for kg vs lbs
extension Double {
    var stringFormat: String {
        let isMetric = UserDefaults.standard.bool(forKey: "isMetric")
        return String(format: "%.0f \(isMetric ? "kg" : "lbs")", self)
    }
    
    var convertToMetric: Double {
        return self * 0.45359237
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
