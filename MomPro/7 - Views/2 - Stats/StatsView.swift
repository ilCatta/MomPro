//
//  StatsView.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import SwiftUI
import Charts

// ---- ---- ---- ---- ---- ---- ---- ---- ----
//
// MARK: Stats
//
// ---- ---- ---- ---- ---- ---- ---- ---- ----

struct StatsView: View {
    @State private var viewModel = StatsViewModel()
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // 1. HEADER
                    headerSection(geo: geo)
                        .padding(.bottom, 24)
                                        
                    // 2. LIVELLO
                    levelSection
                        .padding(.bottom, 20)
                    
                    // 3. CONDIVISIONE
                    if !viewModel.hasUsedBoost {
                        InviteFriendCard(viewModel: viewModel)
                            .padding(.bottom, 20)
                    }
                    
                    Rectangle()
                        .fill(Color(uiColor: .separator))
                        .frame(height: 1)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                  
                    
                    // 4. GRAFICI
                    graphsSection
                        .padding(.bottom, 20)
                    
                    Rectangle()
                        .fill(Color(uiColor: .separator))
                        .frame(height: 1)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                                        
                    // 5. GRIGLIA CARD (Timeframe, Costanza, Trend - Estratti insieme)
                    bentoGridSection
                    
                    // 6. EXTRA SPACE
                    Spacer(minLength: 30)
                   
                }
            }
            .ignoresSafeArea(edges: .top)
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}




extension StatsView {
    
    
    // ---- ---- ---- ---- ---- ---- ---- ---- ----
    //
    // MARK: Header Image
    //
    // ---- ---- ---- ---- ---- ---- ---- ---- ----
    
    private func headerSection(geo: GeometryProxy) -> some View {
        let headerHeight = geo.size.height * 0.38
        return GeometryReader { scrollGeo in
            let minY = scrollGeo.frame(in: .global).minY
            
            Image(viewModel.dailyMascotImageName)
                .resizable()
                .scaledToFill()
                .overlay(
                    LinearGradient(colors: [.clear, .black.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: geo.size.width, height: headerHeight + (minY > 0 ? minY : 0), alignment: .top)
                .clipped()
                .offset(y: minY > 0 ? -minY : 0)
        }
        .frame(height: headerHeight)
    }
    
    // ---- ---- ---- ---- ---- ---- ---- ---- ----
    //
    // MARK: Level
    //
    // ---- ---- ---- ---- ---- ---- ---- ---- ----
    
    private var levelSection: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text("Livello \(viewModel.currentLevel)")
                .font(.system(.footnote, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.pink)
                .textCase(.uppercase)
                .padding(.bottom, 2)
            
            Text(viewModel.levelTitle)
                .font(.system(.title, design: .default))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.bottom, 12)
              
            GeometryReader { barGeo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    Capsule()
                        .fill(LinearGradient(colors: [.pink.opacity(0.7), .pink.opacity(0.9)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: barGeo.size.width * viewModel.levelProgress, height: 12)
                }
            }
            .frame(height: 12)
            .padding(.bottom, 12)
            
            Text("Ancora \(viewModel.tasksToNextLevel) task al prossimo livello!")
                .font(.system(.caption, design: .default))
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }
    
    // ---- ---- ---- ---- ---- ---- ---- ---- ----
    //
    // MARK: Share with friend
    //
    // ---- ---- ---- ---- ---- ---- ---- ---- ----
    
    struct InviteFriendCard: View {
        var viewModel: StatsViewModel
        
        var body: some View {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(.yellow)
                        .font(.largeTitle)
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Boost Amica")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("Ottieni +5 Task completati subito!")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    Spacer()
                }
                
                Button(action: {
                    withAnimation {
                        viewModel.applyBoost()
                    }
                }) {
                    HStack {
                        Text("Invita e Sali di Livello")
                        Image(systemName: "arrow.up.forward.circle.fill")
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(.indigo)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(
                LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(20)
            .padding(.horizontal)
        }
        
    }
    
    // ---- ---- ---- ---- ---- ---- ---- ---- ----
    //
    // MARK: Card Grid Section
    //
    // ---- ---- ---- ---- ---- ---- ---- ---- ----
    
    
    // 3. SEZIONE BENTO GRID
    private var bentoGridSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            BentoCard(icon: "checkmark.circle.fill", iconColor: .green, value: "\(viewModel.totalTasksCompleted)", label: "Task Completati")
            BentoCard(icon: "hourglass", iconColor: .orange, value: viewModel.timeInvestedString, label: "Tempo Investito")
            BentoCard(icon: "book.fill", iconColor: .blue, value: "\(viewModel.articlesRead)", label: "Guide Lette")
            BentoCard(icon: "flame.fill", iconColor: .pink, value: "\(viewModel.currentStreak)", label: "Giorni di Fila", subLabel: "Record: \(viewModel.bestStreak)")
        }
        .padding(.horizontal)
    }
    
    
    
    
    
    // 4. SEZIONE GRAFICI (Qui c'era l'errore di complessità)
    private var graphsSection: some View {
        VStack(spacing: 24) {
            // SELETTORE
            TimeFrameSelector(selected: $viewModel.selectedTimeFrame)
                .padding(.top, 10)
            
            // --- POSIZIONE NUOVA: RIASSUNTO NARRATIVO ---
            // Ora sta subito sotto il selettore, coerente con il periodo scelto
            SummaryInsightCard(data: viewModel.currentSummary)
                .padding(.horizontal)
            
            // COSTANZA
            ConsistencyBarView(
                data: viewModel.chartData,
                timeFrame: viewModel.selectedTimeFrame,
                maxGoal: viewModel.currentMaxGoal
            )
            .padding(.horizontal)
            
            // TREND
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Trend")
                        .font(.headline)
                    Spacer()
                    HStack(spacing: 12) {
                        Circle().fill(Color.indigo).frame(width: 6, height: 6)
                        Text("Fatti").font(.caption2).foregroundStyle(.secondary)
                        Circle().fill(Color.pink.opacity(0.5)).frame(width: 6, height: 6)
                        Text("Mancati").font(.caption2).foregroundStyle(.secondary)
                    }
                }
                
                ChartRedBlueView(
                    fullData: viewModel.chartData,
                    timeFrame: viewModel.selectedTimeFrame,
                    maxGoal: viewModel.currentMaxGoal
                )
                .frame(height: 180)
            }
            .padding(20)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(24)
            .padding(.horizontal)
        }
    }
    
  
}

// MARK: - COMPONENTI UI (Bento, Selector, Invite...)

struct BentoCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    var subLabel: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .padding(8)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                if let subLabel = subLabel {
                    Text(subLabel)
                        .font(.caption2)
                        .foregroundStyle(Color.gray.opacity(0.8))
                        .padding(.top, 2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}


// MARK: - CARD RIASSUNTO (Stile Alloro & Punteggio)
// MARK: - CARD RIASSUNTO (Tempo Investito & Task vs Attività)
struct SummaryInsightCard: View {
    let data: StatsViewModel.SummaryData
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. HEADER
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "laurel.leading")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(Color(uiColor: .systemGray4))
                
                VStack(spacing: 0) {
                    Text("\(data.score)")
                        .font(.system(size: 54, weight: .black, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .contentTransition(.numericText())
                        .animation(.snappy(duration: 0.5), value: data.score)
                    
                    Text("PUNTEGGIO")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(Color(uiColor: .systemGray4))
                }
                .frame(width: 100)
                
                Image(systemName: "laurel.trailing")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(Color(uiColor: .systemGray4))
            }
            .padding(.top, 24)
            .padding(.bottom, 24)
            
            Divider().padding(.horizontal, 40).padding(.bottom, 24)
            
            // 2. TESTO NARRATIVO
            Text(buildAttributedText())
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .contentTransition(.numericText())
                .animation(.snappy(duration: 0.4), value: data.totalCompleted)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // Costruzione della frase
    private func buildAttributedText() -> AttributedString {
        let baseFont = Font.system(.title3, design: .rounded)
        var text = AttributedString("")
        
        // RIGA 1: "[Context] include [X] task e [Y] letture."
        
        var partContext = AttributedString("\(data.contextName) ")
        partContext.foregroundColor = Color.primary
        partContext.font = baseFont.weight(.bold)
        text.append(partContext)
        
        var partInclude = AttributedString("include ")
        partInclude.foregroundColor = Color.secondary
        partInclude.font = baseFont
        text.append(partInclude)
        
        var partTasks = AttributedString("\(data.tasksCount) task") // Uso "task" qui
        partTasks.foregroundColor = Color.primary
        partTasks.font = baseFont.weight(.bold)
        text.append(partTasks)
        
        var partAnd = AttributedString(" e ")
        partAnd.foregroundColor = Color.secondary
        partAnd.font = baseFont
        text.append(partAnd)
        
        var partReads = AttributedString("\(data.readsCount) letture.\n")
        partReads.foregroundColor = Color.primary
        partReads.font = baseFont.weight(.bold)
        text.append(partReads)
        
        // RIGA 2: "In totale hai investito [Tempo] su te stessa e concluso [Tot] attività."
        
        var partTotalPrefix = AttributedString("In totale hai investito ")
        partTotalPrefix.foregroundColor = Color.secondary
        partTotalPrefix.font = baseFont
        text.append(partTotalPrefix)
        
        var partTime = AttributedString("\(data.timeFormatted)")
        partTime.foregroundColor = Color.primary
        partTime.font = baseFont.weight(.bold)
        text.append(partTime)
        
        var partOnYourself = AttributedString(" su te stessa e concluso ")
        partOnYourself.foregroundColor = Color.secondary
        partOnYourself.font = baseFont
        text.append(partOnYourself)
        
        var partTotalVal = AttributedString("\(data.totalCompleted) attività.\n") // Uso "attività" qui
        partTotalVal.foregroundColor = Color.primary
        partTotalVal.font = baseFont.weight(.bold)
        text.append(partTotalVal)
        
        // RIGA 3: Frase Conclusiva (PINK)
        
        var partConclusion = AttributedString(data.conclusion)
        partConclusion.foregroundColor = Color.pink
        partConclusion.font = baseFont.weight(.semibold)
        text.append(partConclusion)
        
        return text
    }
}







struct TimeFrameSelector: View {
    @Binding var selected: TimeFrame
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selected = timeframe
                    }
                }) {
                    ZStack {
                        if selected == timeframe {
                            RoundedRectangle(cornerRadius: 100)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                .matchedGeometryEffect(id: "TF_Tab", in: animation)
                        }
                        
                        Text(timeframe.rawValue.localized)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(selected == timeframe ? .black : .gray)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(4)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .clipShape(Capsule())
        .frame(maxWidth: 300)
    }
}


// MARK: - GRAFICI (ConsistencyBarView e ChartRedBlueView)
// Incolla qui sotto i componenti grafici (ConsistencyBarView e ChartRedBlueView)
// che ti ho fornito nei passaggi precedenti.
// Assicurati di usare le versioni aggiornate con "timeFrame" e "maxGoal".


// MARK: - GRAFICO COSTANZA (Aggiornato con TimeFrame)
struct ConsistencyBarView: View {
    let data: [StatsViewModel.ChartDataPoint]
    let timeFrame: TimeFrame    // NUOVO
    let maxGoal: Double         // NUOVO: Passato dal VM
    
    @State private var selectedID: UUID?
    let barHeight: CGFloat = 100
    
    var appLocale: Locale {
        return Locale(identifier: LanguageService.shared.currentLanguage)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Costanza".localized)
                .font(.headline)
                .padding(.horizontal, 20)
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 12) {
                        
                        Spacer().frame(width: 8)
                        
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
                                        .frame(height: heightFor(value: point.completed))
                                }
                                .frame(height: barHeight + 30, alignment: .bottom)
                                
                                // DATA (Logica Dinamica)
                                VStack(spacing: 2) {
                                    if timeFrame == .day {
                                        // DAY: "Lun" sopra, "12 Gen" sotto
                                        Text(point.date.formatted(.dateTime.weekday(.abbreviated).locale(appLocale)).capitalized)
                                            .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                        
                                        Text(point.date.formatted(.dateTime.day().month(.abbreviated).locale(appLocale)))
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
                            .frame(width: 45)
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
                        
                        Spacer().frame(width: 20).id("scrollEnd")
                    }
                    .padding(.horizontal, 10)
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
        .padding(.vertical, 24)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(24)
    }
    
    func heightFor(value: Int) -> CGFloat {
        // Usiamo maxGoal passato dal VM
        let effectiveValue = max(CGFloat(value), 0.3)
        let ratio = effectiveValue / CGFloat(maxGoal)
        return barHeight * ratio
    }
}

// MARK: - GRAFICO TREND (Refattorizzato per evitare timeout del compilatore)
struct ChartRedBlueView: View {
    let fullData: [StatsViewModel.ChartDataPoint]
    let timeFrame: TimeFrame
    let maxGoal: Double
    
    @State private var selectedID: UUID?
    
    // Configurazione Layout
    let itemWidth: CGFloat = 60
    let barVisualWidth: CGFloat = 40
    let chartHeight: CGFloat = 130
    
    let startSpacer: CGFloat = 20
    let endSpacer: CGFloat = 20
    
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
            }
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
                    Text(point.date.formatted(.dateTime.day().month(.abbreviated).locale(appLocale)))
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




















/*

struct StatsView: View {
    @State private var viewModel = StatsViewModel()
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // 1. STRETCHY HEADER
                    let headerHeight = geo.size.height * 0.38
                    GeometryReader { scrollGeo in
                        let minY = scrollGeo.frame(in: .global).minY
                        
                        Image(viewModel.dailyMascotImageName)
                            .resizable()
                            .scaledToFill()
                            .overlay(
                                LinearGradient(colors: [.clear, .black.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: geo.size.width, height: headerHeight + (minY > 0 ? minY : 0), alignment: .top)
                            .clipped()
                            .offset(y: minY > 0 ? -minY : 0)
                    }
                    .frame(height: headerHeight)
                    
                    
                    // 2. LIVELLO
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Livello \(viewModel.currentLevel)")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.pink)
                                    .textCase(.uppercase)
                                
                                Text(viewModel.levelTitle)
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundStyle(.primary)
                            }
                            Spacer()
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(.yellow)
                                .shadow(color: .orange.opacity(0.5), radius: 5)
                        }
                        
                        GeometryReader { barGeo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 12)
                                
                                Capsule()
                                    .fill(LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: barGeo.size.width * viewModel.levelProgress, height: 12)
                            }
                        }
                        .frame(height: 12)
                        
                        Text("Ancora \(viewModel.tasksToNextLevel) task al prossimo livello!")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    
                    
                    // 3. BENTO GRID
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        BentoCard(icon: "checkmark.circle.fill", iconColor: .green, value: "\(viewModel.totalTasksCompleted)", label: "Task Completati")
                        BentoCard(icon: "hourglass", iconColor: .orange, value: viewModel.timeInvestedString, label: "Tempo Investito")
                        BentoCard(icon: "book.fill", iconColor: .blue, value: "\(viewModel.articlesRead)", label: "Guide Lette")
                        BentoCard(icon: "flame.fill", iconColor: .pink, value: "\(viewModel.currentStreak)", label: "Giorni di Fila", subLabel: "Record: \(viewModel.bestStreak)")
                    }
                    .padding(.horizontal)
                    

                    // --- SELETTORE TIMEFRAME ---
                    TimeFrameSelector(selected: $viewModel.selectedTimeFrame)
                        .padding(.top, 10)
                        .padding(.bottom, 0)

                    
                    // GRAFICO COSTANZA
                    ConsistencyBarView(
                        data: viewModel.chartData,
                        timeFrame: viewModel.selectedTimeFrame,
                        maxGoal: viewModel.currentMaxGoal
                    )
                    .padding(.horizontal)
                    
                    
                    // 4. GRAFICO TREND
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Trend")
                                .font(.headline)
                            Spacer()
                            // Legenda
                            HStack(spacing: 12) {
                                Circle().fill(Color.indigo).frame(width: 6, height: 6)
                                Text("Fatti").font(.caption2).foregroundStyle(.secondary)
                                Circle().fill(Color.pink.opacity(0.5)).frame(width: 6, height: 6)
                                Text("Mancati").font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                        
                        ChartRedBlueView(
                            fullData: viewModel.chartData,
                            timeFrame: viewModel.selectedTimeFrame,
                            maxGoal: viewModel.currentMaxGoal
                        )
                        .frame(height: 180)
                    }
                    .padding(20) // Più padding interno
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(24)
                    .padding(.horizontal)
                    
                    
                    // 5. INVITA AMICO
                    if !viewModel.hasUsedBoost {
                        InviteFriendCard(viewModel: viewModel)
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                    } else {
                        Spacer(minLength: 40)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}

// MARK: - COMPONENTI UI

struct BentoCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    var subLabel: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .padding(8)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                if let subLabel = subLabel {
                    Text(subLabel)
                        .font(.caption2)
                        .foregroundStyle(Color.gray.opacity(0.8))
                        .padding(.top, 2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}







struct TimeFrameSelector: View {
    @Binding var selected: TimeFrame
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selected = timeframe
                    }
                }) {
                    ZStack {
                        if selected == timeframe {
                            RoundedRectangle(cornerRadius: 100)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                .matchedGeometryEffect(id: "TF_Tab", in: animation)
                        }
                        
                        Text(timeframe.rawValue.localized) // Usa .localized se hai le chiavi
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(selected == timeframe ? .black : .gray)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(4)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .clipShape(Capsule())
        .frame(maxWidth: 300) // Non troppo largo
    }
}






// MARK: - GRAFICO AGGIORNATO (Stile Reference Image)
// MARK: - GRAFICO TREND (Separato e Linea Curva Adattata)
// MARK: - GRAFICO TREND (Fix Colori Puri & Date)
// MARK: - GRAFICO TREND (Fix: Linea in Primo Piano & Limiti Esatti)

struct ChartRedBlueView: View {
    let fullData: [StatsViewModel.DailyStat]
    
    // Stato Selezione
    @State private var selectedID: UUID?
    
    // Configurazione Layout
    let itemWidth: CGFloat = 60       // Larghezza totale slot
    let barVisualWidth: CGFloat = 40  // Larghezza visiva della pillola
    let chartHeight: CGFloat = 130    // Altezza fissa area barre
    let maxGoal: CGFloat = 7          // Scala 0-7
    
    // Spaziatori
    let startSpacer: CGFloat = 20
    let endSpacer: CGFloat = 20
    
    // Helper Locale
    var appLocale: Locale {
        return Locale(identifier: LanguageService.shared.currentLanguage)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    
                    // 1. LE BARRE (Ora sono PRIMA nel codice, quindi SOTTO visivamente)
                    HStack(spacing: 0) {
                        
                        Spacer().frame(width: startSpacer)
                        
                        ForEach(fullData) { day in
                            
                            let isSelected = (selectedID == day.id)
                            let isToday = Calendar.current.isDateInToday(day.date)
                            
                            // Percentuale
                            let percentage = Int((Double(day.completed) / maxGoal) * 100)
                            
                            // Calcolo altezze
                            let blueHeight = heightFor(value: day.completed)
                            let pinkHeight = chartHeight - blueHeight
                            
                            VStack(spacing: 8) {
                                
                                // A. TESTO PERCENTUALE
                                Text("\(percentage)%")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(isSelected ? .primary : .secondary)
                                    .frame(height: 20)
                                    .opacity(isSelected ? 1 : 0)
                                    .scaleEffect(isSelected ? 1.0 : 0.8)
                                    .animation(.spring(), value: isSelected)
                                
                                // B. BARRA
                                VStack(spacing: 0) {
                                    // BLU (Fatti)
                                    Rectangle()
                                        .fill(Color.indigo)
                                        .opacity(isSelected ? 1.0 : (isToday ? 0.9 : 0.5))
                                        .frame(width: barVisualWidth, height: blueHeight)
                                    
                                    // ROSSO (Mancati)
                                    Rectangle()
                                        .fill(Color.pink)
                                        .opacity(isSelected ? 0.8 : (isToday ? 0.6 : 0.3))
                                        .frame(width: barVisualWidth, height: pinkHeight)
                                }
                                .frame(height: chartHeight)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                // C. DATA
                                VStack(spacing: 2) {
                                    Text(day.date.formatted(.dateTime.weekday(.abbreviated).locale(appLocale)).capitalized)
                                        .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                        .foregroundStyle(isSelected ? .primary : .secondary)
                                    
                                    Text(day.date.formatted(.dateTime.day().month(.abbreviated).locale(appLocale)))
                                        .font(.system(size: 10, weight: .regular))
                                        .foregroundStyle(isSelected ? .primary : .secondary)
                                        .lineLimit(1)
                                        .fixedSize()
                                }
                                .frame(height: 30, alignment: .top)
                                
                            }
                            .frame(width: itemWidth)
                            .contentShape(Rectangle())
                            .id(day.id)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedID = day.id
                                }
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                            }
                        }
                        
                        Spacer()
                            .frame(width: endSpacer)
                            .id("scrollEndTrend")
                    }
                    
                    // 2. LA LINEA (Ora è DOPO nel codice, quindi SOPRA visivamente)
                    TrendLinePath(
                        data: fullData,
                        itemWidth: itemWidth,
                        barVisualWidth: barVisualWidth, // Passiamo la larghezza esatta della barra
                        chartHeight: chartHeight,
                        maxGoal: maxGoal,
                        startOffset: startSpacer
                    )
                    .frame(width: (CGFloat(fullData.count) * itemWidth) + startSpacer + endSpacer, height: chartHeight)
                    .padding(.top, 30) // Offset per allinearla visivamente sotto il testo percentuale
                    .allowsHitTesting(false) // IMPORTANTE: Permette di cliccare le barre attraverso la linea
                    
                }
            }
            .onAppear {
                if selectedID == nil { selectedID = fullData.last?.id }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        proxy.scrollTo("scrollEndTrend", anchor: .trailing)
                    }
                }
            }
        }
    }
    
    func heightFor(value: Int) -> CGFloat {
        let ratio = CGFloat(value) / maxGoal
        let safeRatio = min(max(ratio, 0.0), 1.0)
        return chartHeight * safeRatio
    }
}

// Shape Linea (Aggiornata per usare barVisualWidth)
struct TrendLinePath: Shape {
    let data: [StatsViewModel.DailyStat]
    let itemWidth: CGFloat
    let barVisualWidth: CGFloat // NUOVO PARAMETRO
    let chartHeight: CGFloat
    let maxGoal: CGFloat
    let startOffset: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard data.count > 1 else { return path }
        
        var points: [CGPoint] = []
        
        for (index, day) in data.enumerated() {
            let x = startOffset + (CGFloat(index) * itemWidth) + (itemWidth / 2)
            
            // Y: 0 è Top (Max Goal)
            let ratio = CGFloat(day.completed) / maxGoal
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






// MARK: - GRAFICO COSTANZA (Nuovo Stile Interattivo)
// MARK: - GRAFICO COSTANZA (Scrollable & Auto-Scroll to Today)
// MARK: - GRAFICO COSTANZA (Scrollable & Spaced)

struct ConsistencyBarView: View {
    let data: [StatsViewModel.DailyStat]
    
    @State private var selectedID: UUID?
    
    // Configurazione
    let maxTasks: Int = 7
    let barHeight: CGFloat = 100
    
    var appLocale: Locale {
        return Locale(identifier: LanguageService.shared.currentLanguage)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Costanza".localized)
                .font(.headline)
                .padding(.horizontal, 20)
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 12) {
                        
                        // Spazio iniziale per estetica
                        Spacer().frame(width: 8)
                        
                        ForEach(data) { day in
                            
                            let isSelected = (selectedID == day.id)
                            
                            VStack(spacing: 12) {
                                // GRUPPO BARRA + TESTO
                                VStack(spacing: 6) {
                                    // Valore
                                    Text("\(day.completed)")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundStyle(isSelected ? .primary : .secondary)
                                        .scaleEffect(isSelected ? 1.1 : 1.0)
                                        .animation(.spring(), value: isSelected)
                                        .opacity((day.completed == 0 && !isSelected) ? 0 : 1)
                                    
                                    // Barra
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(isSelected ? Color.pink : Color.gray.opacity(0.15))
                                        .frame(height: heightFor(value: day.completed))
                                }
                                .frame(height: barHeight + 30, alignment: .bottom)
                                
                                // Data
                                VStack(spacing: 2) {
                                    Text(day.date.formatted(.dateTime.weekday(.abbreviated).locale(appLocale)).capitalized)
                                        .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                        .foregroundStyle(isSelected ? .primary : .secondary)
                                    
                                    Text(day.date.formatted(.dateTime.day().month(.abbreviated).locale(appLocale)))
                                        .font(.system(size: 10, weight: .regular))
                                        .foregroundStyle(isSelected ? .primary : .secondary)
                                        .lineLimit(1)
                                        .fixedSize()
                                }
                            }
                            .frame(width: 45)
                            .contentShape(Rectangle())
                            .id(day.id)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    selectedID = day.id
                                }
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                            }
                        }
                        
                        // TRUCCO: Spacer finale invisibile per dare "aria" allo scroll
                        Spacer()
                            .frame(width: 20)
                            .id("scrollEnd") // ID speciale per lo scroll
                    }
                    .padding(.horizontal, 10) // Padding del container
                }
                .onAppear {
                    if selectedID == nil { selectedID = data.last?.id }
                    
                    // Scrolla fino allo SPACER finale, così l'ultimo elemento non è attaccato al bordo
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo("scrollEnd", anchor: .trailing)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 24)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(24)
    }
    
    func heightFor(value: Int) -> CGFloat {
        let effectiveValue = max(CGFloat(value), 0.3)
        let ratio = effectiveValue / CGFloat(maxTasks)
        return barHeight * ratio
    }
}




struct InviteFriendCard: View {
    var viewModel: StatsViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.yellow)
                    .font(.largeTitle)
                    .padding(10)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Boost Amica")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Ottieni +5 Task completati subito!")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
            }
            
            Button(action: {
                withAnimation {
                    viewModel.applyBoost()
                }
            }) {
                HStack {
                    Text("Invita e Sali di Livello")
                    Image(systemName: "arrow.up.forward.circle.fill")
                }
                .fontWeight(.bold)
                .foregroundStyle(.indigo)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(
            LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
    }
}
*/
