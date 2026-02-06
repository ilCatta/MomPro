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
                    gridSection
                    
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
            
            Image(viewModel.milestoneImage)
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
            
            Text(viewModel.milestoneTitle)
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
    

    
    // 4. SEZIONE GRAFICI (Con Blur e Demo Logic)
        private var graphsSection: some View {
            
            // Logica Visibilità:
            // Mostriamo i contenuti (chiari) se:
            // 1. L'utente è PRO (StoreService.shared.isPro)
            // 2. OPPURE siamo in modalità DEMO (viewModel.isDemoMode)
            let isContentVisible = StoreService.shared.isPro || viewModel.isDemoMode
            
            return VStack(spacing: 0) {
                
                // SELETTORE (Sempre visibile e cliccabile)
                TimeFrameSelector(selected: $viewModel.selectedTimeFrame)
                    .padding(.bottom, 24)
                
                // CONTENUTO SFOCABILE
                ZStack {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // PUNTEGGIO
                        SummaryInsightCard(data: viewModel.currentSummary)
                            .padding(.horizontal)
                            .padding(.bottom, 24)
                        
                        //
                        //
                        // COSTANZA TITLE
                        HStack(spacing: 0) {
                            Text("stats_view_consistency_title".localized)
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Text("stats_view_consistency_subtitle".localized)
                                .font(.system(.caption2, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        //
                        //
                        // COSTANZA chart
                        ConsistencyBarView(
                            data: viewModel.chartData,
                            timeFrame: viewModel.selectedTimeFrame,
                            maxGoal: viewModel.currentMaxGoal
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                        
                        //
                        //
                        // TREND TITLE
                        HStack(spacing: 0) {
                            Text("stats_view_trend_title".localized)
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            Spacer()
                            HStack(spacing: 6) {
                                Circle().fill(Color.indigo).frame(width: 6, height: 6)
                                Text("stats_view_trend_done".localized)
                                    .font(.system(.caption2, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .padding(.trailing, 4)
                                
                                Circle().fill(Color.pink).frame(width: 6, height: 6)
                                Text("stats_view_trend_missed".localized)
                                    .font(.system(.caption2, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)

                        //
                        //
                        // TREND CHART
                        VStack(alignment: .leading, spacing: 0) {
                            TrendChartView(
                                fullData: viewModel.chartData,
                                timeFrame: viewModel.selectedTimeFrame,
                                maxGoal: viewModel.currentMaxGoal
                            )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                        .padding(.horizontal)
                    }
                    .blur(radius: isContentVisible ? 0 : 8) // SFOCATURA
                    
                    
                    //
                    //
                    // OVERLAY LUCCHETTO (Se sfocato)
                    if !isContentVisible {
                        VStack(spacing: 16) {
                            Image(systemName: "lock.circle.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.pink)
                                .padding(20)
                                .background(Circle().fill(Color.white).shadow(radius: 10))
                            
                            Text("Sblocca le Statistiche Pro")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            Text("Passa a Premium per vedere i tuoi progressi nel tempo.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    }
                }
                .allowsHitTesting(isContentVisible) // Blocca i tocchi se sfocato
            }
        }
    
    
    // ---- ---- ---- ---- ---- ---- ---- ---- ----
    //
    // MARK: Card Grid Section
    //
    // ---- ---- ---- ---- ---- ---- ---- ---- ----
    
    // 5. GRIGLIA CARD (Attività, Guide, Streak, Record)
    private var gridSection: some View {
        
        VStack(alignment: .leading, spacing: 0){
            
            Text("stats_view_journey_title".localized)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .padding(.bottom, 20)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                
                // CARD 1: Attività Completate (Totale storico)
                StatsCard(
                    icon: "checkmark.circle.fill",
                    iconColor: Color(.green), // Verde successo
                    value: "\(viewModel.totalTasksCompleted)",
                    label: "stats_view_total_activities".localized
                )
                
                // CARD 2: Guide Lette (Totale)
                StatsCard(
                    icon: "book.fill",
                    iconColor: Color(.blue), // Blu conoscenza
                    value: "\(viewModel.articlesRead)",
                    label: "stats_view_total_reads".localized
                )
                
                // CARD 3: Giorni di Fila (Streak Corrente)
                StatsCard(
                    icon: "flame.fill",
                    iconColor: Color(.orange), // Arancione
                    value: "\(viewModel.currentStreak)",
                    label: "stats_view_current_streak".localized
                )
                
                // CARD 4: Record Personale (Best Streak)
                StatsCard(
                    icon: "trophy.fill",
                    iconColor: Color(.yellow), // Oro per il record
                    value: "\(viewModel.bestStreak)",
                    label: "stats_view_best_streak".localized
                )
            }
        }
        .padding(.horizontal)
       
    }
    
}


