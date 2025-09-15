//
//  HealthStore.swift
//  Healthy
//
//  Created by Александра on 15.09.2025.
//

import Foundation
import HealthKit

final class HealthStore {
    static let shared = HealthStore()
    private let store = HKHealthStore()
    private let healthStore = HKHealthStore()

    let readTypes: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.workoutType()
    ]

    let writeTypes: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!
    ]

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        store.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            completion(success, error)
        }
    }
    
    func fetchSteps(completion: @escaping ([Date: Double]) -> Void) {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion([:]); return
        }

        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())

        var interval = DateComponents()
        interval.day = 1
        let anchorDate = Calendar.current.startOfDay(for: Date())

        let query = HKStatisticsCollectionQuery(quantityType: stepsType,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)

        query.initialResultsHandler = { _, results, error in
            var out: [Date: Double] = [:]
            results?.enumerateStatistics(from: startDate, to: Date()) { stats, _ in
                let value = stats.sumQuantity()?.doubleValue(for: .count()) ?? 0
                out[stats.startDate] = value
            }
            DispatchQueue.main.async { completion(out) }
        }

        store.execute(query)
    }
}

extension HealthStore {
    enum StepsInterval {
        case hour, day, week, month
    }

    func fetchSteps(interval: StepsInterval,
                    startDate: Date,
                    endDate: Date,
                    completion: @escaping ([Date: Double]) -> Void) {

        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion([:]); return
        }

        var dateComponents = DateComponents()
        switch interval {
        case .hour: dateComponents.hour = 1
        case .day: dateComponents.day = 1
        case .week: dateComponents.weekOfYear = 1
        case .month: dateComponents.month = 1
        }

        let anchorDate = Calendar.current.startOfDay(for: startDate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)

        let query = HKStatisticsCollectionQuery(
            quantityType: stepsType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: dateComponents
        )

        query.initialResultsHandler = { _, results, error in
            var out: [Date: Double] = [:]
            results?.enumerateStatistics(from: startDate, to: endDate) { stats, _ in
                let value = stats.sumQuantity()?.doubleValue(for: .count()) ?? 0
                out[stats.startDate] = value
            }
            DispatchQueue.main.async { completion(out) }
        }

        store.execute(query)
    }
    
    func fetchHeartRate(
        interval: StepsInterval,
        startDate: Date,
        endDate: Date,
        completion: @escaping ([Date: Double]) -> Void
    ) {
        guard let type = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion([:])
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let unit = HKUnit.count().unitDivided(by: .minute())

        var intervalComponent: DateComponents
        switch interval {
        case .hour:
            intervalComponent = DateComponents(minute: 10)
        case .day:
            intervalComponent = DateComponents(hour: 1)
        case .week:
            intervalComponent = DateComponents(day: 1)
        case .month:
            intervalComponent = DateComponents(day: 7)
        }

        let query = HKStatisticsCollectionQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .discreteAverage,
            anchorDate: startDate,
            intervalComponents: intervalComponent
        )

        query.initialResultsHandler = { _, results, _ in
            var data: [Date: Double] = [:]
            results?.enumerateStatistics(from: startDate, to: endDate) { stats, _ in
                if let value = stats.averageQuantity()?.doubleValue(for: unit) {
                    data[stats.startDate] = value
                }
            }
            DispatchQueue.main.async {
                completion(data)
            }
        }

        healthStore.execute(query)
    }

}
