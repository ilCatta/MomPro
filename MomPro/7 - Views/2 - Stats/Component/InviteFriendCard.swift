//
//  InviteFriendCard.swift
//  MomPro
//
//  Created by Andrea Cataldo on 06/02/26.
//

import SwiftUI

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
