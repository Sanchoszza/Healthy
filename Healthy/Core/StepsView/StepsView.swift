//
//  StepsView.swift
//  Healthy
//
//  Created by Александра on 15.09.2025.
//

import SwiftUI
import Charts

struct StepsView: View {
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
                ForEach(viewModel.steps.keys.sorted(), id: \.self) { date in
                    AreaMark(
                        x: .value("Дата", date),
                        y: .value("Шаги", viewModel.steps[date] ?? 0)
                    )
                    .foregroundStyle(LinearGradient(
                        colors: [.red.opacity(0.3), .red.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ))

                    LineMark(
                        x: .value("Дата", date),
                        y: .value("Шаги", viewModel.steps[date] ?? 0)
                    )
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    PointMark(
                        x: .value("Дата", date),
                        y: .value("Шаги", viewModel.steps[date] ?? 0)
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
                                viewModel.loadSteps()
                            }
                        } else if value.translation.width > 50 {
                            viewModel.offset -= 1
                            viewModel.loadSteps()
                        }
                    }
            )

            Chart {
                ForEach(viewModel.steps.keys.sorted(), id: \.self) { date in
                    BarMark(
                        x: .value("Дата", date, unit: viewModel.xUnit),
                        y: .value("Шаги", viewModel.steps[date] ?? 0),
                        width: viewModel.intervalWidth
                    )
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
                                viewModel.loadSteps()
                            }
                        } else if value.translation.width > 50 {
                            viewModel.offset -= 1
                            viewModel.loadSteps()
                        }
                    }
            )

            Text("Всего шагов: \(Int(viewModel.steps.values.reduce(0,+)))")
                .font(.headline)
            
            Spacer()
        }
        .onAppear {
            viewModel.interval = .day
            viewModel.loadSteps()
        }
        .onChange(of: viewModel.interval) {
            viewModel.offset = 0
            viewModel.loadSteps()
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
                Text("Шаги")
                    .foregroundStyle(Color.white)
            }
        }
    }

    
}

