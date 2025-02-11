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
    @Environment(WeightViewModel.self) private var WeightsVM
    @Environment(UserManager.self) private var userViewModel
    var weights: [WeightModel]
    var selectedDuration: DataDurationContext
    @Binding var isMetric: Bool
    let highestWeight = 300
    let goalWeight = 220.0

    @State private var lineWidth = 2.0
    @State private var chartColor: Color = .green
    @State private var showSymbols = true
    @State private var showLollipop = true
    @State private var selectedWeight: WeightModel?
    
    var body: some View {
        let curColor = Color(.systemGreen)
        let curGradient = LinearGradient(
            gradient: Gradient(colors: [curColor, curColor.opacity(0.2)]),
            startPoint: .bottom,
            endPoint: .top
        )
        
        VStack {
            if(!weights.isEmpty) {
                let _max = weights.max { item1, item2 in
                    return item2.value > item1.value
                }?.value ?? 0.0
                
                let _min = weights.min { item1, item2 in
                    return item1.value < item2.value
                }?.value ?? 0.0
                
                Chart {
                    ForEach(weights) { weights in
                        LineMark(x: .value("Date", weights.date ?? Date.now),
                                 y: .value("Weight", isMetric ? weights.value.convertToMetric : weights.value)
                        )
                        .lineStyle(.init(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        .foregroundStyle(curColor)
                        .symbolSize(60)
                        .interpolationMethod(.linear)
                        
                        AreaMark(
                            x: .value("Date", weights.date ?? Date.now),
                            y: .value("Weight", isMetric ? weights.value.convertToMetric : weights.value)
                        )
                        .interpolationMethod(.linear)
                        .foregroundStyle(curGradient)
                        .opacity(0.5)
                        
                        
                        if userViewModel.isSubscriptionActive {
                            RuleMark(y: .value("Goal", chartType.goal ?? 0.0))
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            .annotation(position: .top, alignment: .leading){
                                Text("Goal \(chartType.goal!.formatted())")
                            }
                        }
                    }
                }
                .customYAxisScale(_min: _min, _max: _max, goal: chartType.goal ?? 0.0, isMetric: isMetric, isSubscribed: userViewModel.isSubscriptionActive, count: weights.count)
                .chartXScale(range: .plotDimension(padding: 20.0))
                .chartPlotStyle{plotArea in
                    plotArea
                        .frame(maxWidth: .infinity, minHeight: 250.0, maxHeight: 250.0)
                        .clipped()
                        
                }
                .chartYAxis{
                    AxisMarks(position: .leading)
                }

            } else {
                Spacer()
                Text("No data for \(selectedDuration.title) \(checkType(chartType: selectedDuration))")
                Spacer()
            }
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
    
    private func checkType(chartType: DataDurationContext) -> String {
        switch chartType {
        case .three:
            return "in the past 3 months"
        case .six:
            return "in the past 6 months"
        case .year:
            return "in the past year"
        case  .alltime:
            return "yet, add a beginning weight!"
        }
    }
}

extension View {
    func customYAxisScale(_min: Double, _max: Double, goal: Double, isMetric: Bool, isSubscribed: Bool, count: Int) -> some View {
        if isSubscribed {
            if goal != 0.0 {
                //if BodyWeight
                if goal <= _min {
                    return self.chartYScale(domain: (isMetric ? goal.convertToMetric : goal - 20)...(isMetric ? _max.convertToMetric : _max + 1))
                } else if goal >= _max {
                    return self.chartYScale(domain: (isMetric ? _min.convertToMetric : _min)...(isMetric ? goal.convertToMetric : goal + 20))
                } else {
                    return self.chartYScale(domain: (isMetric ? _min.convertToMetric : _min - 10)...(isMetric ? _max.convertToMetric : _max + 10))
                }
            } else {
                return self.chartYScale(domain: (isMetric ? _min.convertToMetric : _min - 10)...(isMetric ? _max.convertToMetric : _max + 10))
            }
        } else {
            return self.chartYScale(domain: (isMetric ? _min.convertToMetric : _min - 10)...(isMetric ? _max.convertToMetric : _max + 10))
        }
    }
}
