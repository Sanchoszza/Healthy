//
//  HeartRateView.swift
//  Healthy
//
//  Created by Александра on 15.09.2025.
//

import SwiftUI
import Charts

struct HeartRateView: View {
    @ObservedObject var viewModel: HealthViewModel
    @GestureState private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack {
            Picker("Период", selection: $viewModel.interval) {
                Text("День").tag(HealthStore.StepsInterval.hour)
                Text("Неделя").tag(HealthStore.StepsInterval.day)
                Text("Месяц").tag(HealthStore.StepsInterval.week)
                Text("Год").tag(HealthStore.StepsInterval.month)
            }
            .pickerStyle(.segmented)
            .padding()
            
            Chart {
                ForEach(viewModel.heartRate.keys.sorted(), id: \.self) { date in
                    AreaMark(
                        x: .value("Дата", date),
                        y: .value("Пульс", viewModel.heartRate[date] ?? 0)
                    )
                    .foregroundStyle(LinearGradient(
                        colors: [.red.opacity(0.3), .red.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ))

                    LineMark(
                        x: .value("Дата", date),
                        y: .value("Пульс", viewModel.heartRate[date] ?? 0)
                    )
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    PointMark(
                        x: .value("Дата", date),
                        y: .value("Пульс", viewModel.heartRate[date] ?? 0)
                    )
                    .foregroundStyle(.red)
                }
            }
            .frame(height: 250)
            .padding()
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        if value.translation.width < -50 {
                            if viewModel.offset < 0 {
                                viewModel.offset += 1
                                viewModel.loadHeartRate()
                            }
                        } else if value.translation.width > 50 {
                            viewModel.offset -= 1
                            viewModel.loadHeartRate()
                        }
                    }
            )

            Chart {
                ForEach(viewModel.heartRate.keys.sorted(), id: \.self) { date in
                    PointMark(
                        x: .value("Дата", date, unit: viewModel.xUnit),
                        y: .value("Пульс", viewModel.heartRate[date] ?? 0)
                    )
                    .foregroundStyle(Color.red.gradient)
                    .symbol(Circle())
                }
            }
            .frame(height: 250)
            .padding()
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        if value.translation.width < -50 {
                            if viewModel.offset < 0 {
                                viewModel.offset += 1
                                viewModel.loadHeartRate()
                            }
                        } else if value.translation.width > 50 {
                            viewModel.offset -= 1
                            viewModel.loadHeartRate()
                        }
                    }
            )

            Text("Средний пульс: \(Int(viewModel.heartRate.values.reduce(0,+) / Double(max(1, viewModel.heartRate.count)))) bpm")
                .font(.headline)

            Spacer()
        }
        .onAppear {
            viewModel.interval = .day
            viewModel.loadHeartRate()
        }
        .onChange(of: viewModel.interval) {
            viewModel.offset = 0
            viewModel.loadHeartRate()
        }
        .onDisappear{
            viewModel.interval = .day
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    withAnimation {
                        viewModel.currentStep = .startView
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.gray)
                    }
                    .padding()
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.clear)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Пульс")
                    .foregroundStyle(Color.white)
            }
        }
    }
}
