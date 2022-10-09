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
    @State private var currentChartTab: String = "3"
    @FetchRequest private var chartTypes: FetchedResults<Workout>
    @State private var currentChartTypeTab: WorkoutModel
    @State private var showNewWeight: Bool = false
    @State private var showWeightList: Bool = false
    @State private var type = ""
    @State private var refresh: Bool = false
   
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
            ScrollView {
                Picker("", selection: $currentChartTypeTab) {
                    ForEach(WorkoutVM.workouts, id: \.typeId) { workout in
                        Text(workout.type ?? "")
                            .tag(workout)
                    }
                }
                .onChange(of: currentChartTypeTab) { tag in
                    if(!WeightVM.weights.isEmpty) {
                        WeightVM.weights.removeAll()
                        WeightVM.filteredWeights.removeAll()
                    }
                    WeightVM.getWeightsByType(workoutModel: tag)
                    WeightVM.filterWeights(month: -3)
                }
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.systemGreen).shadow(.drop(radius: 5)))
                }
                .pickerStyle(.segmented)
                .padding()
                
                //MARK: Uncomment for testing
//                if(!WorkoutVM.workouts.isEmpty) {
//                    List {
//                        ForEach(WorkoutVM.workouts, id: \.typeId) { workout in
//                            Text(workout.type ?? "")
//                        }
//                        .onDelete(perform: deleteWorkout)
//                    }
//                }
//                TextField("Enter Workout", text: $WorkoutVM.type)
//                Button("save") {
//                    WorkoutVM.save()
//                    WorkoutVM.getAllWorkouts()  
//                }
                
                AddWeightCard(WorkoutVM: WorkoutVM, WeightVM: WeightVM, type: $currentChartTypeTab, refresh: $refresh)
                    .padding(.top)
                    .padding(.bottom)
                
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
                        //.padding(.leading, 40)
                        
                        Button("Edit") {
                            showWeightList.toggle()
                        }
                        .sheet(isPresented: $showWeightList, onDismiss: {
                            WeightVM.getWeightsByType(workoutModel: currentChartTypeTab)
                            WeightVM.filteredWeights.removeAll()
                            getFilteredWeights()

                        }) {
                            WeightsList(WeightVM: WeightVM, workoutType: currentChartTypeTab.type ?? "")
                        }
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
                    
                    AnimatedChart(chartType: $currentChartTypeTab, WeightsVM: WeightVM)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.secondarySystemBackground).shadow(.drop(radius: 2)))
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationTitle(currentChartTypeTab.type ?? "")
            .onAppear {
                WorkoutVM.getAllWorkouts()
                WeightVM.getWeightsByType(workoutModel: currentChartTypeTab)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
                        currentChartTypeTab = WorkoutVM.workouts[0]
                    
                }
            }
            .onChange(of: refresh) { newValue in
                if newValue {
                    WeightVM.getWeightsByType(workoutModel: currentChartTypeTab)
                    getFilteredWeights()
                    refresh.toggle()
                }
            }
        }
    }
    
    private func deleteWorkout(at offsets: IndexSet) {
        offsets.forEach { offset in
            let workout = WorkoutVM.workouts[offset]
            WorkoutVM.deleteWorkout(workout: workout)
            WorkoutVM.getAllWorkouts()
        }
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
        return String(format: "%.0f lbs", self)
    }
}
