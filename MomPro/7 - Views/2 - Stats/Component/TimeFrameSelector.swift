//
//  TimeFrameSelector.swift
//  MomPro
//
//  Created by Andrea Cataldo on 06/02/26.
//

import SwiftUI

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
                        
                        Text(timeframe.localizedKey.localized)
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
