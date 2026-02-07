//
//  MilestoneCell.swift
//  MomPro
//
//  Created by Andrea Cataldo on 07/02/26.
//
import SwiftUI

struct MilestoneCell: View {
    let milestone: ProgressService.Milestone // Usa la struct vera
    let currentLevel: Int
    
    var isLocked: Bool {
        return currentLevel < milestone.thresholdLevel
    }
    
    var body: some View {
        VStack(spacing: 8) {
            
            ZStack {
                // 1. IMMAGINE (Con effetto B/N stile LearnView)
                Image(milestone.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .saturation(isLocked ? 0 : 1) // B/N se bloccato
                    .overlay {
                        // Velo nero se bloccato
                        if isLocked {
                            Circle().fill(Color.black.opacity(0.6))
                        }
                    }
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // 2. LUCCHETTO (Solo se bloccato)
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                // 3. CHECKMARK (Solo se sbloccato)
                if !isLocked {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.white, .green)
                                .font(.system(size: 20))
                                .background(Circle().fill(.white).padding(2))
                        }
                    }
                }
            }
            .frame(width: 80, height: 80)
            
            // TITOLO E INFO SBLOCCO
            VStack(spacing: 2) {
                Text(milestone.title.localized)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(isLocked ? .secondary : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 30, alignment: .top)
                
                if isLocked {
                    // "Liv. 50" (Usa la chiave che abbiamo creato prima)
                    Text(String(format: "stats_view_milestones_unlock_at".localized, milestone.thresholdLevel))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.gray))
                } else {
                    Text("Sbloccato") // O vuoto se preferisci
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                        .opacity(0.8)
                }
            }
        }
    }
}
