//
//  MainTabView.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import SwiftUI

struct MomProAppTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Oggi", systemImage: "house.fill")
                }
            
            StatsView()
            .tabItem {
                Label("Progressi", systemImage: "chart.bar.fill")
            }
            
            GuidesView()
            .tabItem {
                Label("Guide", systemImage: "book.fill")
            }
            
            SettingsView() 
                            .tabItem {
                                Label("Opzioni", systemImage: "gearshape.fill")
                            }
        }
        .tint(.pink) // Colore principale dell'app
    }
}
