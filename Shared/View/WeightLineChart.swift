//
//  WeightLineChart.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 7/20/24.
//

import SwiftUI
import Charts

struct mocData: Identifiable {
    let id = UUID()
    let date: Date?
    let value: Double
}


struct WeightLineChart: View {
    @Environment(UserManager.self) private var userManager
    @State private var rawSelectedDate: Date?
    var chartData: [WeightModel]
    var workout: WorkoutModel
    var height: CGFloat = 150
    let testData: [mocData] = [mocData(date: Date.now, value: 285),
                               mocData(date: Calendar.current.date(byAdding: .day, value: -1, to: .now), value: 287),
                               mocData(date: Calendar.current.date(byAdding: .day, value: -2, to: .now), value: 288),
                               mocData(date: Calendar.current.date(byAdding: .day, value: -3, to: .now), value: 289),
                               mocData(date: Calendar.current.date(byAdding: .day, value: -4, to: .now), value: 290),
                               mocData(date: Calendar.current.date(byAdding: .day, value: -5, to: .now), value: 292),
                               mocData(date: Calendar.current.date(byAdding: .day, value: -6, to: .now), value: 297),
                               mocData(date: Calendar.current.date(byAdding: .day, value: -7, to: .now), value: 294),
                               mocData(date: Calendar.current.date(byAdding: .day, value: -8, to: .now), value: 297),
                               mocData(date: Calendar.current.date(byAdding: .day, value: -9, to: .now), value: 297),
                               mocData(date: Calendar.current.date(byAdding: .day, value: -10, to: .now), value: 298),
                               mocData(date: Calendar.current.date(byAdding: .day, value: -11, to: .now), value: 300),
                               mocData(date: Calendar.current.date(byAdding: .day, value: -12, to: .now), value: 300),]
    
    var selectedWeight: WeightModel? {
        guard let rawSelectedDate else { return nil }
        return chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date ?? Date())
        }
    }
    
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }
    
    var body: some View {
        if !chartData.isEmpty {
            VStack {
                Chart {
                    if let selectedWeight {
                        RuleMark(x: .value("Selected Weight", selectedWeight.date ?? .now, unit: .day))
                            .foregroundStyle( .secondary.opacity(0.3))
                            .offset(y: -10)
                            .annotation(position: .top,
                                        spacing: 0,
                                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) { annotationView }
                    }
                    
                    if userManager.isSubscriptionActive && workout.goal != 0.0 {
                        RuleMark(y: .value("Goal", workout.goal ?? 0.0))
                            .foregroundStyle(.green)
                            .lineStyle(.init(lineWidth: 1, dash: [5]))
                    }
                    
                    ForEach(chartData) { weight in
                        AreaMark(
                            x: .value("Day", weight.date ?? .now, unit: .day),
                            yStart: .value("Value", weight.value),
                            yEnd: .value("MinValue", minValue)
                        )
                        .foregroundStyle(Gradient(colors: [.green.opacity(0.5), .clear]))
                        .interpolationMethod(.catmullRom)
                        
                        LineMark(x: .value("Date", weight.date ?? Date.now, unit: .day),
                                 y: .value("Weight", weight.value))
                        .foregroundStyle(.green)
                        .interpolationMethod(.catmullRom)
                        .symbol(.circle)
                    }
                }
                .frame(height: height)
                .chartXSelection(value: $rawSelectedDate)
                .chartYScale(domain: .automatic(includesZero: false))
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(Color.secondary.opacity(0.3))
                        
                        AxisValueLabel()
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        }
    }
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedWeight?.date ?? .now, format:
                    .dateTime.day(.defaultDigits).month(.abbreviated))
            .font(.footnote.bold())
            .foregroundStyle(.secondary)
            
            Text(selectedWeight?.value ?? 0, format:
                    .number.precision(.fractionLength(1)))
            .fontWeight(.heavy)
            .foregroundStyle(.green)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )
    }
}

//#Preview {
//    WeightLineChart(chartData: [], workout: WorkoutModel(workout: nil))
//}
