//
//  AnimatedChart.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 8/12/22.
//

import SwiftUI
import Charts

struct AnimatedChart: View {
    @Binding var chartType: WorkoutModel
    @ObservedObject var WeightsVM: WeightViewModel
    @Binding var chartRange : String
    @Binding var isMetric: Bool
    let highestWeight = 300
    let goalWeight = 220.0
    
    @State private var lineWidth = 2.0
    //@State private var interpolationMethod: ChartInterpolationMethod = .cardinal
    @State private var chartColor: Color = .green
    @State private var showSymbols = true
    //@State private var selectedElement: Sale? = SalesData.last30Days[10]
    @State private var showLollipop = true
    @State private var selectedWeight: WeightModel?
    
    var body: some View {
        VStack {
            if(WeightsVM.filteredWeights.isEmpty) {
                Text("No data for \(chartType.type ?? "") in the past \(chartRange) Months")
            } else {
                let _max = WeightsVM.filteredWeights.max { item1, item2 in
                    return item2.value > item1.value
                }?.value ?? 0.0
                
                let _min = WeightsVM.filteredWeights.min { item1, item2 in
                    return item1.value < item2.value
                }?.value ?? 0.0
                //TODO: Fix below code for when selecting a date
//                HStack {
//                    Spacer()
//
//                    VStack(alignment: .trailing) {
//                        Text("\(selectedWeight?.date ?? Date.now, format: .dateTime.year().month().day())")
//                            .font(.callout)
//                            .foregroundStyle(.secondary)
//                        Text("\(selectedWeight?.value.stringFormat ?? "") lbs")
//                            .font(.title2.bold())
//                            .foregroundColor(.primary)
//                    }
//                    .accessibilityElement(children: .combine)
//                    .background {
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 8)
//                                .fill(.background)
//                            RoundedRectangle(cornerRadius: 8)
//                                .fill(.quaternary.opacity(0.7))
//                        }
//                        .padding(.horizontal, -8)
//                        .padding(.vertical, -4)
//                    }
//                }
                Chart {
                    ForEach(WeightsVM.filteredWeights) { weights in
                        LineMark(x: .value("Date", weights.date ?? Date.now),
                                 y: .value("Weight", isMetric ? weights.value.convertToMetric : weights.value)
                        )
                        .lineStyle(.init(lineWidth: 5, lineCap: .round, lineJoin: .round))
                        .foregroundStyle(Gradient(colors: [.green]))
                        .symbolSize(60)
                    }
                }
                .chartYScale(domain: (isMetric ? _min.convertToMetric : _min - 5)...(isMetric ? _max.convertToMetric : _max + 5))
                .frame(height: 250)
            }
        }.onAppear {
            print(isMetric)
        }
    }
    
    private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> WeightModel? {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            //Find the closest date element
            var minDistance: TimeInterval = .infinity
            var index: Int? = nil
            for weightIndex in WeightsVM.weights.indices {
                let nthWeightDataDistance = WeightsVM.weights[weightIndex].date!.distance(to: date)
                if abs(nthWeightDataDistance) < minDistance {
                    minDistance = abs(nthWeightDataDistance)
                    index = weightIndex
                }
            }
            if let index {
                return WeightsVM.weights[index]
            }
        }
        return nil
    }
    
}

struct AnimatedChart_Previews: PreviewProvider {
    static var previews: some View {
        
        let workout = WorkoutModel(workout: Workout(context: CoreDataManager.shared.viewContext))
        
        AnimatedChart(chartType: .constant(workout), WeightsVM: WeightViewModel(), chartRange: .constant("3 Months"), isMetric: .constant(false))
    }
}
