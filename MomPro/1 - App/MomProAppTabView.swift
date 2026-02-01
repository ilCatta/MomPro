//
//  MainTabView.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import SwiftUI

// Enum globale
enum Tab: String {
    case home
    case stats
    case learn
    case settings
}

struct MomProAppTabView: View {
    
    @AppStorage("selectedTab") private var selectedTab: Tab = .home
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
            HomeView(currentTab: $selectedTab)
                .tabItem {
                Image(selectedTab == .home ? "calendar-03-duotone-rounded" : "calendar-03-stroke-rounded")
                Text("tab_today".localized)
            }
            .tag(Tab.home)
            
            StatsView()
                .tabItem {
                    Image(selectedTab == .stats ? "chart-01-duotone-rounded" : "chart-01-stroke-rounded")
                    Text("tab_progress".localized)
                }
                .tag(Tab.stats)
            
            LearnView()
                .tabItem {
                        Image(selectedTab == .learn ? "book-open-01-bulk-rounded" : "book-open-01-stroke-rounded")
                        Text("tab_learn".localized)
                    }
                    .tag(Tab.learn)
            
            SettingsView() 
                .tabItem {
                    Image(selectedTab == .settings ? "settings-03-duotone-rounded" : "settings-03-stroke-rounded")
                    Text("tab_options".localized)
                }
                .tag(Tab.settings)
        }
        .tint(.pink) // Colore principale dell'app
        .onChange(of: selectedTab) {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}
