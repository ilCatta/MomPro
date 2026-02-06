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
        
        var partTasks = AttributedString("\(data.tasksCount) attività") // Uso "task" qui
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
