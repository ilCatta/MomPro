//
//  SummaryInsightCard.swift
//  MomPro
//
//  Created by Andrea Cataldo on 06/02/26.
//

import SwiftUI

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
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    
                    Text("stats_view_summary_score".localized)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(Color(uiColor: .systemGray4))
                        .textCase(.uppercase)
                }
                .frame(width: 105)
                
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
    
    // Costruzione della frase DINAMICA
        private func buildAttributedText() -> AttributedString {
            let baseFont = Font.system(.title3, design: .rounded)
            var text = AttributedString("")
            
            // --- RIGA 1 ---
            // IT: "Oggi include 5 attività e 2 letture."
            
            // 1. Contesto (Oggi / Gennaio)
            var partContext = AttributedString("\(data.contextName) ")
            partContext.foregroundColor = Color.primary
            partContext.font = baseFont.weight(.bold)
            text.append(partContext)
            
            // 2. "include" (stats_view_summary_includes)
            var partInclude = AttributedString("stats_view_summary_includes".localized + " ")
            partInclude.foregroundColor = Color.secondary
            partInclude.font = baseFont
            text.append(partInclude)
            
            // 3. "5 attività" (stats_view_summary_activities)
            var partTasks = AttributedString("\(data.tasksCount) \("stats_view_summary_activities".localized)")
            partTasks.foregroundColor = Color.primary
            partTasks.font = baseFont.weight(.bold)
            text.append(partTasks)
            
            // 4. " e " (stats_view_summary_and)
            var partAnd = AttributedString(" \("stats_view_summary_and".localized) ")
            partAnd.foregroundColor = Color.secondary
            partAnd.font = baseFont
            text.append(partAnd)
            
            // 5. "2 letture." (stats_view_summary_reads)
            var partReads = AttributedString("\(data.readsCount) \("stats_view_summary_reads".localized).\n")
            partReads.foregroundColor = Color.primary
            partReads.font = baseFont.weight(.bold)
            text.append(partReads)
            
            // --- RIGA 2 ---
            // IT: "In totale hai investito 45 min su te stessa e concluso 7 attività."
            
            // 6. "In totale hai investito " (stats_view_summary_invested_prefix)
            var partTotalPrefix = AttributedString("stats_view_summary_invested_prefix".localized + " ")
            partTotalPrefix.foregroundColor = Color.secondary
            partTotalPrefix.font = baseFont
            text.append(partTotalPrefix)
            
            // 7. "[Tempo]"
            var partTime = AttributedString("\(data.timeFormatted)")
            partTime.foregroundColor = Color.primary
            partTime.font = baseFont.weight(.bold)
            text.append(partTime)
            
            // 8. " su te stessa e concluso " (stats_view_summary_invested_suffix)
            var partOnYourself = AttributedString(" " + "stats_view_summary_invested_suffix".localized + " ")
            partOnYourself.foregroundColor = Color.secondary
            partOnYourself.font = baseFont
            text.append(partOnYourself)
            
            // 9. "[Tot] attività." (stats_view_summary_activities)
            var partTotalVal = AttributedString("\(data.totalCompleted) \("stats_view_summary_activities".localized).\n")
            partTotalVal.foregroundColor = Color.primary
            partTotalVal.font = baseFont.weight(.bold)
            text.append(partTotalVal)
            
            // --- RIGA 3 ---
            // Frase Conclusiva (Già localizzata nel VM)
            var partConclusion = AttributedString(data.conclusion)
            partConclusion.foregroundColor = Color.pink
            partConclusion.font = baseFont.weight(.semibold)
            text.append(partConclusion)
            
            return text
        }
}
