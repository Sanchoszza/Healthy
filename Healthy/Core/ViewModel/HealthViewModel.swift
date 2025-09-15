//
//  HealthViewModel.swift
//  Healthy
//
//  Created by Александра on 15.09.2025.
//

import Foundation
import Charts

@MainActor
class HealthViewModel: ObservableObject {
    @Published var steps: [Date: Double] = [:]
    @Published var message: String = ""
    
    @Published var currentStep: StepsInHealth = .startView
    
    @Published var interval: HealthStore.StepsInterval = .day
    @Published var offset: Int = 0
    
    @Published var heartRate: [Date: Double] = [:]
    
    var xUnit: Calendar.Component {
        switch interval {
        case .hour: return .hour
        case .day: return .day
        case .week: return .day
        case .month: return .month
        }
    }

    var intervalWidth: MarkDimension {
        switch interval {
        case .hour: return .fixed(8)
        case .day: return .fixed(20)
        case .week: return .fixed(20)
        case .month: return .fixed(20)
        }
    }
    
    func getHealthAllow() {
        HealthStore.shared.requestAuthorization { success, error in
            if success {
                self.loadSteps()
                self.loadHeartRate()
            } else {
                self.message = "Нет доступа: \(error?.localizedDescription ?? "неизвестно")"
            }
        }
    }
    
    func loadSteps() {
        let (start, end) = calculateRange(for: interval, offset: offset)
        HealthStore.shared.fetchSteps(interval: interval, startDate: start, endDate: end) { data in
            self.steps = data
        }
    }
    
    func loadHeartRate() {
        let (start, end) = calculateRange(for: interval, offset: offset)
        HealthStore.shared.fetchHeartRate(interval: interval, startDate: start, endDate: end) { data in
            self.heartRate = data
        }
    }
}


extension HealthViewModel {
    func calculateRange(for interval: HealthStore.StepsInterval, offset: Int) -> (Date, Date) {
        let calendar = Calendar.current
        let now = Date()

        var start: Date
        var end: Date

        switch interval {
        case .hour:
            let baseDay = calendar.date(byAdding: .day, value: offset, to: now)!
            start = calendar.startOfDay(for: baseDay)
            end = calendar.date(byAdding: .day, value: 1, to: start)!

        case .day:
            let baseWeek = calendar.date(byAdding: .weekOfYear, value: offset, to: now)!
            start = calendar.dateInterval(of: .weekOfYear, for: baseWeek)!.start
            end = calendar.date(byAdding: .day, value: 7, to: start)!

        case .week:
            let baseMonth = calendar.date(byAdding: .month, value: offset, to: now)!
            start = calendar.dateInterval(of: .month, for: baseMonth)!.start
            end = calendar.date(byAdding: .month, value: 1, to: start)!

        case .month:
            let baseYear = calendar.date(byAdding: .year, value: offset, to: now)!
            start = calendar.dateInterval(of: .year, for: baseYear)!.start
            end = calendar.date(byAdding: .year, value: 1, to: start)!
        }

        return (start, end)
    }
}
