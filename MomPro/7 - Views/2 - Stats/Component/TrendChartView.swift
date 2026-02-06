//
//  TrendChartView.swift
//  MomPro
//
//  Created by Andrea Cataldo on 06/02/26.
//

import SwiftUI


// MARK: - GRAFICO TREND (Refattorizzato per evitare timeout del compilatore)
struct TrendChartView: View {
    let fullData: [StatsViewModel.ChartDataPoint]
    let timeFrame: TimeFrame
    let maxGoal: Double
    
    @State private var selectedID: UUID?
    
    // Configurazione Layout
    let itemWidth: CGFloat = 60
    let barVisualWidth: CGFloat = 45
    let chartHeight: CGFloat = 130
    
    let startSpacer: CGFloat = 8
    let endSpacer: CGFloat = 8
    
    var appLocale: Locale {
        return Locale(identifier: LanguageService.shared.currentLanguage)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    
                    // 1. LE BARRE (Estratte in una variabile)
                    barsLayer
                    
                    // 2. LA LINEA (Estratta in una variabile)
                    lineLayer
                    
                }
                .padding(.vertical, 12)
            }
            .fixedSize(horizontal: false, vertical: true)
            .onAppear {
                if selectedID == nil { selectedID = fullData.last?.id }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation { proxy.scrollTo("scrollEndTrend", anchor: .trailing) }
                }
            }
            .onChange(of: fullData) {
                 selectedID = fullData.last?.id
                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                     withAnimation { proxy.scrollTo("scrollEndTrend", anchor: .trailing) }
                 }
            }
        }
    }
    
    // MARK: - Sotto-componenti (Spezzati per aiutare il compilatore)
    
    private var barsLayer: some View {
        HStack(spacing: 0) {
            Spacer().frame(width: startSpacer)
            
            ForEach(fullData) { point in
                TrendBarItem(
                    point: point,
                    isSelected: selectedID == point.id,
                    isCurrentTimeFrame: checkIsCurrent(point),
                    maxGoal: maxGoal,
                    chartHeight: chartHeight,
                    barVisualWidth: barVisualWidth,
                    itemWidth: itemWidth,
                    timeFrame: timeFrame,
                    appLocale: appLocale,
                    onTap: {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedID = point.id
                        }
                    }
                )
            }
            
            Spacer().frame(width: endSpacer).id("scrollEndTrend")
        }
    }
    
    private var lineLayer: some View {
        TrendLinePath(
            data: fullData,
            itemWidth: itemWidth,
            barVisualWidth: barVisualWidth,
            chartHeight: chartHeight,
            maxGoal: CGFloat(maxGoal),
            startOffset: startSpacer
        )
        .frame(width: (CGFloat(fullData.count) * itemWidth) + startSpacer + endSpacer, height: chartHeight)
        .padding(.top, 30) // Offset per allinearla sotto le percentuali
        .allowsHitTesting(false)
    }
    
    // Funzione helper per pulire il codice dentro il ForEach
    private func checkIsCurrent(_ point: StatsViewModel.ChartDataPoint) -> Bool {
        if timeFrame == .day {
            return Calendar.current.isDateInToday(point.date)
        } else {
            return point == fullData.last
        }
    }
}

// MARK: - SOTTO-COMPONENTE SINGOLA BARRA (Estratto)
// MARK: - SOTTO-COMPONENTE SINGOLA BARRA (Corretto con data completa)
struct TrendBarItem: View {
    let point: StatsViewModel.ChartDataPoint
    let isSelected: Bool
    let isCurrentTimeFrame: Bool
    let maxGoal: Double
    let chartHeight: CGFloat
    let barVisualWidth: CGFloat
    let itemWidth: CGFloat
    let timeFrame: TimeFrame
    let appLocale: Locale
    let onTap: () -> Void
    
    var body: some View {
        let percentage = Int((Double(point.completed) / maxGoal) * 100)
        let blueHeight = calculateHeight(value: point.completed)
        let pinkHeight = chartHeight - blueHeight
        
        VStack(spacing: 8) {
            
            // A. PERCENTUALE
            Text("\(percentage)%")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .frame(height: 20)
                .opacity(isSelected ? 1 : 0)
                .scaleEffect(isSelected ? 1.0 : 0.8)
                .animation(.spring(), value: isSelected)
            
            // B. BARRA STACK
            VStack(spacing: 0) {
                // BLU (Fatti)
                Rectangle()
                    .fill(Color.indigo)
                    .opacity(isSelected ? 1.0 : (isCurrentTimeFrame ? 0.9 : 0.5))
                    .frame(width: barVisualWidth, height: blueHeight)
                
                // ROSSO (Mancati)
                Rectangle()
                    .fill(Color.pink)
                    .opacity(isSelected ? 0.8 : (isCurrentTimeFrame ? 0.6 : 0.3))
                    .frame(width: barVisualWidth, height: pinkHeight)
            }
            .frame(height: chartHeight)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // C. DATA (Aggiornata: ora mostra Giorno E Data)
            VStack(spacing: 2) {
                if timeFrame == .day {
                    // 1. Giorno Settimana (es. "Gio")
                    Text(point.date.formatted(.dateTime.weekday(.abbreviated).locale(appLocale)).capitalized)
                        .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                    
                    // 2. Giorno e Mese (es. "5 Feb") - AGGIUNTO QUI
                    Text(point.date.formatted(.dateTime.day().month(.abbreviated).locale(appLocale)).capitalized)
                        .font(.system(size: 10, weight: .regular))
                        .fixedSize()
                }
                else if timeFrame == .month {
                    // Mese (es. "Feb")
                    Text(point.date.formatted(.dateTime.month(.abbreviated).locale(appLocale)).capitalized)
                        .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                }
                else {
                    // Anno (es. "2026")
                    Text(point.date.formatted(.dateTime.year(.defaultDigits).locale(appLocale)))
                        .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                }
            }
            .foregroundStyle(isSelected ? .primary : .secondary)
            .frame(height: 30, alignment: .top)
        }
        .frame(width: itemWidth)
        .contentShape(Rectangle())
        .id(point.id)
        .onTapGesture { onTap() }
    }
    
    private func calculateHeight(value: Int) -> CGFloat {
        let ratio = CGFloat(value) / maxGoal
        let safeRatio = min(max(ratio, 0.0), 1.0)
        return chartHeight * safeRatio
    }
}





// MARK: - COMPONENTE LINEA (Mancava questo pezzo)
struct TrendLinePath: Shape {
    let data: [StatsViewModel.ChartDataPoint]
    let itemWidth: CGFloat
    let barVisualWidth: CGFloat
    let chartHeight: CGFloat
    let maxGoal: CGFloat
    let startOffset: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard data.count > 1 else { return path }
        
        var points: [CGPoint] = []
        
        for (index, point) in data.enumerated() {
            let x = startOffset + (CGFloat(index) * itemWidth) + (itemWidth / 2)
            
            // Y: 0 è Top (Max Goal)
            let ratio = CGFloat(point.completed) / maxGoal
            let safeRatio = min(max(ratio, 0.0), 1.0)
            let y = chartHeight - (chartHeight * safeRatio)
            
            points.append(CGPoint(x: x, y: y))
        }
        
        if let first = points.first {
            // FIX: Inizia esattamente dove inizia la barra visiva (Centro - metà larghezza visiva)
            path.move(to: CGPoint(x: first.x - (barVisualWidth / 2), y: first.y))
            path.addLine(to: first)
            
            for i in 1..<points.count {
                let current = points[i]
                let previous = points[i-1]
                let control1 = CGPoint(x: previous.x + (itemWidth / 2), y: previous.y)
                let control2 = CGPoint(x: current.x - (itemWidth / 2), y: current.y)
                path.addCurve(to: current, control1: control1, control2: control2)
            }
            
            if let last = points.last {
                // FIX: Finisce esattamente dove finisce la barra visiva (Centro + metà larghezza visiva)
                path.addLine(to: CGPoint(x: last.x + (barVisualWidth / 2), y: last.y))
            }
        }
        
        return path.strokedPath(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
    }
     
}
