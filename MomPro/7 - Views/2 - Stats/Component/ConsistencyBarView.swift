//
//  ConsistencyBarView.swift
//  MomPro
//
//  Created by Andrea Cataldo on 06/02/26.
//

import SwiftUI

// MARK: - GRAFICO COSTANZA (Aggiornato con TimeFrame)
struct ConsistencyBarView: View {
    let data: [StatsViewModel.ChartDataPoint]
    let timeFrame: TimeFrame
    let maxGoal: Double        
    
    @State private var selectedID: UUID?
    
    let itemWidth: CGFloat = 60      // Spazio totale per ogni colonna
    let barVisualWidth: CGFloat = 45 // Larghezza effettiva della barra
    let barHeight: CGFloat = 100     // Altezza massima della barra
    let startSpacer: CGFloat = 8    // Padding iniziale
    let endSpacer: CGFloat = 8      // Padding finale
    
    var appLocale: Locale {
        return Locale(identifier: LanguageService.shared.currentLanguage)
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(alignment: .bottom, spacing: 0) {
                        
                        Spacer().frame(width: startSpacer)
                        
                        ForEach(data) { point in
                            
                            let isSelected = (selectedID == point.id)
                            
                            VStack(spacing: 12) {
                                // BARRA + VALORE
                                VStack(spacing: 6) {
                                    // Valore
                                    Text("\(point.completed)")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundStyle(isSelected ? .primary : .secondary)
                                        .scaleEffect(isSelected ? 1.1 : 1.0)
                                        .animation(.spring(), value: isSelected)
                                        .opacity((point.completed == 0 && !isSelected) ? 0 : 1)
                                    
                                    // Barra
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(isSelected ? Color.pink : Color.gray.opacity(0.15))
                                        .frame(width: barVisualWidth, height: heightFor(value: point.completed))
                                }
                                .frame(height: barHeight + 30, alignment: .bottom)
                                
                                // DATA (Logica Dinamica)
                                VStack(spacing: 2) {
                                    if timeFrame == .day {
                                        // DAY: "Lun" sopra, "12 Gen" sotto
                                        Text(point.date.formatted(.dateTime.weekday(.abbreviated).locale(appLocale)).capitalized)
                                            .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                        
                                        Text(point.date.formatted(.dateTime.day().month(.abbreviated).locale(appLocale)).capitalized)
                                            .font(.system(size: 10, weight: .regular))
                                            .fixedSize()
                                    }
                                    else if timeFrame == .month {
                                        // MONTH: "Gen" (Capitalized)
                                        Text(point.date.formatted(.dateTime.month(.abbreviated).locale(appLocale)).capitalized)
                                            .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                    }
                                    else {
                                        // YEAR: "2026"
                                        Text(point.date.formatted(.dateTime.year(.defaultDigits).locale(appLocale)))
                                            .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                    }
                                }
                                .foregroundStyle(isSelected ? .primary : .secondary)
                                .lineLimit(1)
                                
                            }
                            .frame(width: itemWidth)
                            .contentShape(Rectangle())
                            .id(point.id)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    selectedID = point.id
                                }
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                            }
                        }
                        
                        Spacer().frame(width: endSpacer).id("scrollEnd")
                    }
                }
                .onAppear {
                    // Selezione e Scroll automatico
                    if selectedID == nil { selectedID = data.last?.id }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation { proxy.scrollTo("scrollEnd", anchor: .trailing) }
                    }
                }
                // IMPORTANTE: Resetta lo scroll e la selezione quando cambiano i dati (cambio timeframe)
                .onChange(of: data) {
                     selectedID = data.last?.id
                     DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                         withAnimation { proxy.scrollTo("scrollEnd", anchor: .trailing) }
                     }
                }
            }
        }
        .padding(.vertical, 16)
        
    }
    
    func heightFor(value: Int) -> CGFloat {
        // Usiamo maxGoal passato dal VM
        let effectiveValue = max(CGFloat(value), 0.3)
        let ratio = effectiveValue / CGFloat(maxGoal)
        return barHeight * ratio
    }
}
