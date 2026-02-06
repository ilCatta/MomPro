//
//  StatsCard.swift
//  MomPro
//
//  Created by Andrea Cataldo on 06/02/26.
//
import SwiftUI

struct StatsCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .top, spacing: 0) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(label)
                        .font(.system(.footnote, design: .rounded))
                        .fontWeight(.semibold)
                        //.foregroundStyle(.secondary)
                        .foregroundStyle(.tertiary)
                        .textCase(.uppercase)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        // TRUCCO: Riserva spazio per 2 righe (circa 34pt per footnote)
                        .frame(minHeight: 34, alignment: .topLeading)
                        .padding(.bottom, 8)
                    
                    Text(value)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(iconColor)
                    .padding(8)
                    .background(iconColor.opacity(0.15))
                    .clipShape(Circle())
                
            }
           
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)

    }
}
