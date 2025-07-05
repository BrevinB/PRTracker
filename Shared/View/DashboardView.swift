import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(WorkoutViewModel.self) private var workoutVM
    @State private var chartData: [NSManagedObjectID: [WeightModel]] = [:]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(workoutVM.workouts, id: \.typeId) { workout in
                        if let data = chartData[workout.typeId], !data.isEmpty {
                            WeightLineChart(chartData: data, workout: workout, height: 120)
                        } else {
                            Text(workout.type ?? "")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
        .onAppear {
            workoutVM.getAllWorkouts()
            loadData()
        }
    }

    private func loadData() {
        var dict: [NSManagedObjectID: [WeightModel]] = [:]
        for workout in workoutVM.workouts {
            dict[workout.typeId] = fetchWeights(for: workout)
        }
        chartData = dict
    }

    private func fetchWeights(for workout: WorkoutModel) -> [WeightModel] {
        guard let type = CoreDataManager.shared.getWorkoutById(id: workout.typeId) else { return [] }
        let weights = (type.weight?.allObjects as? [Weight])?.map(WeightModel.init) ?? []
        return weights.sorted { $0.date!.compare($1.date!) == .orderedDescending }
    }
}
