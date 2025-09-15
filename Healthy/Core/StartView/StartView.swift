//
//  StartView.swift
//  Healthy
//
//  Created by Александра on 15.09.2025.
//

import SwiftUI

enum StepsInHealth {
    case startView
    case stepsView
    case pulsView
}

struct StartView: View {
    @StateObject var viewModel = HealthViewModel()
    
    var body: some View {
        NavigationStack {
            switch viewModel.currentStep {
            case .startView:
                importHealthData
                    .onAppear{
                        viewModel.getHealthAllow()
                    }
            case .stepsView:
                StepsView(viewModel: viewModel)
            case .pulsView:
                HeartRateView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    StartView()
}

extension StartView {
    private var importHealthData: some View {
        VStack {
            steps
            pulse
            Spacer()
        }
    }
    
    private var steps: some View {
        VStack {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(Color.orange)
                Text("Шаги")
                    .foregroundStyle(Color.orange)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.gray)
            }
            
            Spacer()
            
            HStack {
                Text("Сегодня:")
                    .foregroundStyle(Color.white)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(Int(viewModel.steps[Calendar.current.startOfDay(for: Date())] ?? 0)) шагов")
                    .foregroundStyle(Color.white)
                    .fontWeight(.semibold)
            }
        }
        .font(.headline)
        .fontWeight(.bold)
        .foregroundStyle(Color.blue.opacity(0.5))
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.5))
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .onTapGesture {
            viewModel.currentStep = .stepsView
        }
        .frame(height: 100)
        .padding(.horizontal)
        .padding(.vertical)
    }
    
    private var pulse: some View {
        VStack {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(Color.red)
                Text("Пульс")
                    .foregroundStyle(Color.red)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.gray)
            }
            
            Spacer()
            
            HStack {
                Text("Сегодня:")
                    .foregroundStyle(Color.white)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(Int(viewModel.heartRate.sorted { $0.key < $1.key }.last?.value ?? 0)) уд/мин")
                    .foregroundStyle(Color.white)
                    .fontWeight(.semibold)
            }
        }
        .font(.headline)
        .fontWeight(.bold)
        .foregroundStyle(Color.blue.opacity(0.5))
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.5))
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .onTapGesture {
            viewModel.currentStep = .pulsView
        }
        .frame(height: 100)
        .padding(.horizontal)
    }
}
