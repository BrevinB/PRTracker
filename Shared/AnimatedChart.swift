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
    let highestWeight = 300
    
    @State private var lineWidth = 2.0
    //@State private var interpolationMethod: ChartInterpolationMethod = .cardinal
    @State private var chartColor: Color = .green
    @State private var showSymbols = true
    //@State private var selectedElement: Sale? = SalesData.last30Days[10]
    @State private var showLollipop = true
    @State private var selectedWeight: WeightModel?

 
    
    
    var body: some View {
        VStack {
            if(WeightsVM.weights.isEmpty) {
                Text("No data for \(chartType.type ?? "")")
            } else {
                let _max = WeightsVM.filteredWeights.max { item1, item2 in
                    return item2.value > item1.value
                }?.value ?? 0.0
                
                let _min = WeightsVM.filteredWeights.min { item1, item2 in
                    return item1.value < item2.value
                }?.value ?? 0.0
                
                Chart(WeightsVM.filteredWeights, id: \.date) {
                    LineMark(x: .value("Date", $0.date ?? Date.now),
                             y: .value("Weight", $0.value)
                    )
                    .accessibilityLabel($0.date?.formatted() ?? Date.now.formatted())
                    .accessibilityValue("\($0.value) lbs")
                    //.interpolationMethod(.cardinal)
                    .lineStyle(.init(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(Gradient(colors: [.green]))
                    //.symbol(Circle().strokeBorder(lineWidth: 1))
                    .symbolSize(60)
                }
//                .chartOverlay { proxy in
//                    GeometryReader { geo in
//                        Rectangle().fill(.clear).contentShape(Rectangle())
//                            .gesture(
//                                SpatialTapGesture()
//                                    .onEnded { value in
//                                        let weightVal = findElement(location: value.location, proxy: proxy, geometry: geo)
//                                        if selectedWeight?.date == weightVal?.date {
//                                            //if tapping the same element, clear the selection
//                                            selectedWeight = nil
//                                        } else {
//                                            selectedWeight = weightVal
//                                        }
//                                    }
//                                    .exclusively(
//                                        before: DragGesture()
//                                            .onChanged { value in
//                                                selectedWeight = findElement(location: value.location, proxy: proxy, geometry: geo)
//                                            }
//                                    )
//                            )
//                    }
//                }
//                .chartBackground { proxy in
//                    ZStack(alignment: .topLeading) {
//                        GeometryReader { geo in
//                            if showLollipop,
//                               let selectedWeight {
//                                let dateInterval = Calendar.current.dateInterval(of: .day, for: selectedWeight.date ?? Date.now)!
//                                let startPositionX1 = proxy.position(forX: dateInterval.start) ?? 0
//
//                                let lineX = startPositionX1 + geo[proxy.plotAreaFrame].origin.x
//                                let lineHeight = geo[proxy.plotAreaFrame].maxY
//                                let boxWidth: CGFloat = 100
//                                let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2))
//
//                                Rectangle()
//                                    .fill(.red)
//                                    .frame(width: 2, height: lineHeight)
//                                    .position(x: lineX, y: lineHeight / 2)
//
//                                VStack(alignment: .center) {
//                                    Text("\(selectedWeight.date ?? Date.now, format: .dateTime.year().month().day())")
//                                        .font(.callout)
//                                        .foregroundStyle(.secondary)
//                                    Text("\(selectedWeight.value.stringFormat) lbs")
//                                        .font(.title2.bold())
//                                        .foregroundColor(.primary)
//                                }
//                                .accessibilityElement(children: .combine)
////                                .accessibilityHidden(isOverview)
//                                .frame(width: boxWidth, alignment: .leading)
//                                .background {
//                                    ZStack {
//                                        RoundedRectangle(cornerRadius: 8)
//                                            .fill(.background)
//                                        RoundedRectangle(cornerRadius: 8)
//                                            .fill(.quaternary.opacity(0.7))
//                                    }
//                                    .padding(.horizontal, -8)
//                                    .padding(.vertical, -4)
//                                }
//                                .offset(x: boxOffset)
//                            }
//                        }
//                    }
//                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month))
                }
                .chartYScale(domain: (_min - 5)...(_max + 5))
//                .chartYAxis {
//                    AxisMarks(values: .)
//                }
                .frame(height: 250)
                .onAppear {
                   //MARK: Add animation to line graph
                    WeightsVM.filterWeights(month: -3)
                }
            }
            
            // List {
            //                    ForEach(WeightsVM.weights) { weight in
            //                        Text(weight.date!.formatted())
            //                    }
            //                }
            
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
        
        AnimatedChart(chartType: .constant(workout), WeightsVM: WeightViewModel())
    }
}

