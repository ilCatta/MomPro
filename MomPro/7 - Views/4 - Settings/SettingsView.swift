import SwiftUI
import StoreKit
import RevenueCat
import RevenueCatUI
import Combine
import HugeiconsCore
import HugeiconsDuotoneRounded
import HugeiconsSolidRounded
import HugeiconsStrokeRounded


struct SettingsView: View {
        
    // VM
    @State private var viewModel = SettingsViewModel()
    
    // Language Service
    @Environment(LanguageService.self) var languageService

    // Sheet
    @State private var showLanguageSheet = false
    @State private var showDailyBoostSheet = false
    @State private var showUnlimitedLearningSheet = false
    @State private var showAdvancedStatisticsSheet = false
    
    @State private var showPaywall = false
    
    @Environment(\.openURL) private var openURL
    
    // ---- ---- ---- ---- ---- ---- ---- ---- ----
    //
    // MARK: Function
    //
    // ---- ---- ---- ---- ---- ---- ---- ---- ----
    
    private func _tapLanguage(){
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        showLanguageSheet = true
    }
    
    private func _tapDailyBoost(){
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        showDailyBoostSheet = true
    }
    
    private func _tapUnlimitedLearnin(){
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        showUnlimitedLearningSheet = true
    }
    
    private func _tapAdvancedStatistics(){
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        showAdvancedStatisticsSheet = true
    }
    
    private func _tapInviteFriend() {
        // Vibrazione
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        // Definisco i contenuti
        let appLink = "https://apps.apple.com/app/id6736994383" // link
        let rawMessage = NSLocalizedString("settings_view_invite_a_friend_message", comment: "") // messaggio
        let fullMessage = "\(rawMessage) \(appLink)"
        // Creiamo l'Activity Controller
        let activityVC = UIActivityViewController(
            activityItems: [fullMessage],
            applicationActivities: nil
        )
        // Recuperiamo la scena per presentare il controller
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            // Per iPad: lo Share Sheet deve apparire come un popover, altrimenti crasha
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = rootVC.view
                popoverController.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
    
    private func _tapAppReview() {
        /*
        let appID = "6736994383"
        
        // Recuperiamo la scena attiva (necessaria per mostrare il popup)
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            
            // Nuova sintassi iOS 18+
            if #available(iOS 18.0, *) {
                AppStore.requestReview(in: scene)
            } else {
                // Fallback per versioni precedenti (iOS 14.0 - 17.x)
                SKStoreReviewController.requestReview(in: scene)
            }
            
        } else {
            // Fallback se la scena non è disponibile
            _openAppStore(appID: appID)
        }*/
    }

    private func _openAppStore(appID: String) {
        // Il parametro "action=write-review" porta l'utente direttamente alla tastiera per scrivere
        let urlString = "https://apps.apple.com/app/id\(appID)?action=write-review"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func _tapSendFeedback() {
        // 1. Configurazione dati
        let email = "feedback@andreacataldo.com"
        let subject = "Feedback MomPro"
        let body = ""
        
        // 2. Encoding dei componenti (per gestire spazi e caratteri speciali)
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // 3. Creazione dell'URL
        let urlString = "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func _tapReportBug() {
        // 1. Configurazione dati
        let email = "feedback@andreacataldo.com"
        let subject = "Issue Found in the App - MomPro"
        let body = ""
        
        // 2. Encoding dei componenti (per gestire spazi e caratteri speciali)
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // 3. Creazione dell'URL
        let urlString = "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func _tapCheckOutMyOtherApps() {
        let urlString = "https://apps.apple.com/app/id6736994383"
        if let url = URL(string: urlString) {
            openURL(url)
        }
    }
    
    // ---- ---- ---- ---- ---- ---- ---- ---- ----
    //
    // MARK: Body
    //
    // ---- ---- ---- ---- ---- ---- ---- ---- ----
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                // Colore di sfondo
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        // --- PRO HEADER CARD ---
                        if !viewModel.isPro {
                            PurchaseComponent(showPaywall: $showPaywall)
                                .padding(.horizontal)
                                .padding(.top, 14)
                                .padding(.bottom, 46)
                        } else {
                            SubscribeActive()
                                //.padding(.top, 14)
                                .padding(.bottom, (46-32)) // 32 è lo spazio extra messo nel componente SubscribeActive
                        }
                        
                        // --- LISTA  ---
                        
                        VStack(alignment: .leading, spacing: 0) {
                            
                            //
                            //
                            //
                            // --- LISTA IMPOSTAZIONI ---
                            
                            VStack(alignment: .leading, spacing: 0){
                                
                                Text("settings_view_settings".localized)
                                    .font(.system(.title3, design: .default))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .padding(.bottom, 28)
                                
                                ListTileTheme(isDarkMode: $viewModel.isDarkMode)
                                    .padding(.bottom, 20)
                                
                                DottedLine()
                                    .padding(.bottom, 20)
                                
                                ListTile(
                                    iconName: "language-square",
                                    textKey: "settings_view_language",
                                    action: _tapLanguage
                                    
                                )
                                .padding(.bottom, 20)
                            }
                            .padding(.bottom, 40)
                            
                            
                            //
                            //
                            //
                            // --- PREAMIUM FEATURES ---
                            
                            VStack(alignment: .leading, spacing: 0){
                                
                                Text("settings_view_premium_features".localized)
                                    .font(.system(.title3, design: .default))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .padding(.bottom, 28)
                                
                                ListTilePro(
                                    iconName: "mortarboard-02",
                                    textKey: "settings_view_unlimited_learning",
                                    action: _tapUnlimitedLearnin
                                )
                                .padding(.bottom, 20)
                                
                                DottedLine()
                                    .padding(.bottom, 20)
                                
                                ListTilePro(
                                    iconName: "task-daily-01",
                                    textKey: "settings_view_daily_boost",
                                    action: _tapDailyBoost
                                )
                                .padding(.bottom, 20)
                                
                                DottedLine()
                                    .padding(.bottom, 20)
                                
                                ListTilePro(
                                    iconName: "activity-01",
                                    textKey: "settings_view_advanced_statistics",
                                    action: _tapAdvancedStatistics
                                )
                                .padding(.bottom, 20)
                                
                            }
                            .padding(.bottom, 40)
                            
                            
                            //
                            //
                            //
                            // --- GENERALE ---
                            
                            VStack(alignment: .leading, spacing: 0){
                                
                                Text("settings_view_general".localized)
                                    .font(.system(.title3, design: .default))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .padding(.bottom, 28)
                                
                                ListTile(
                                    iconName: "party",
                                    textKey: "settings_view_invite_a_friend",
                                    action: _tapInviteFriend
                                )
                                .padding(.bottom, 20)
                                
                                DottedLine()
                                    .padding(.bottom, 20)
                                
                                ListTile(
                                    iconName: "star-square",
                                    textKey: "settings_view_leave_a_review",
                                    action: _tapAppReview
                                )
                                .padding(.bottom, 20)
                                
                                DottedLine()
                                    .padding(.bottom, 20)
                                
                                ListTile(
                                    iconName: "mail-love-01",
                                    textKey: "settings_view_send_me_feedback",
                                    action: _tapSendFeedback
                                )
                                .padding(.bottom, 20)
                                
                                DottedLine()
                                    .padding(.bottom, 20)
                                
                                ListTile(
                                    iconName: "broken-bone",
                                    textKey: "settings_view_report_a_bug",
                                    action: _tapReportBug
                                )
                                .padding(.bottom, 20)
                                
                                DottedLine()
                                    .padding(.bottom, 20)
                                
                                ListTile(
                                    iconName: "pie",
                                    textKey: "settings_view_check_out_my_other_apps",
                                    action: _tapCheckOutMyOtherApps
                                )
                                .padding(.bottom, 20)
                                
                            }
                            .padding(.bottom, 40)
                            
                            
                            //
                            //
                            //
                            // --- LEGAL ---
                            
                            VStack(alignment: .leading, spacing: 0){
                                
                                Text("settings_view_legal".localized)
                                    .font(.system(.title3, design: .default))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .padding(.bottom, 28)
                                
                                ListTile(
                                    iconName: "link-square-01",
                                    textKey: "settings_view_terms_of_use",
                                    url: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/",
                                    action: {},
                                )
                                .padding(.bottom, 20)
                                
                                DottedLine()
                                    .padding(.bottom, 20)
                                
                                ListTile(
                                    iconName: "link-square-01",
                                    textKey: "settings_view_privacy_policy",
                                    url: "https://andreacataldo.com/blog/other/privacy-policy",
                                    action: {},
                                )
                                //.paddingVerticalBottom(small: 16, standard: 18,large: 20,ipadMini: 22,ipadStandard: 24, ipadHuge: 24)
                                
                            }
                            .padding(.bottom, 40)
                            
                        }
                        .padding(.horizontal)
                    }
                
                }
                
                
            }
            // --- TOOLBAR ---
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 0) {
                        Text("Mom")
                            .font(.system(.title ,design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text("Pro")
                            .font(.system(.title ,design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.pink)
                    }
                }
            }
            //
            //
            // PAYWALL
            .sheet(isPresented: $showPaywall) {
                PaywallView(displayCloseButton: false) // Questa è la vista nativa di RevenueCat
                    .onRestoreCompleted { info in
                         // Gestione opzionale se l'utente ripristina gli acquisti
                         if info.entitlements.active.isEmpty == false {
                             viewModel.showPaywall = false
                         }
                    }
            }
            // --- SHEET ---
            .sheet(isPresented: $showLanguageSheet) {
                LanguageSelectionSheet()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showUnlimitedLearningSheet) {
                PremiumFeaturesSheet(
                    iconName: "mortarboard-02",
                    title: "settings_view_unlimited_learning",
                    desc1: "settings_view_unlimited_learning_desc",
                    desc2: "",
                     isPro: viewModel.isPro,
                     onUpgradeTap: {
                         showUnlimitedLearningSheet = false
                         // Aspetta che si chiuda prima di aprire il paywall
                         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                             showPaywall = true
                         }
                     })
                    .presentationDetents([.fraction(0.50)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showDailyBoostSheet) {
                PremiumFeaturesSheet(
                    iconName: "task-daily-01",
                    title: "settings_view_daily_boost",
                    desc1: "settings_view_daily_boost_desc1",
                    desc2: "settings_view_daily_boost_desc2",
                    isPro: viewModel.isPro,
                    onUpgradeTap: {
                        showDailyBoostSheet = false
                        // Aspetta che si chiuda prima di aprire il paywall
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showPaywall = true
                        }
                    })
                    .presentationDetents([.fraction(0.50)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showAdvancedStatisticsSheet) {
                PremiumFeaturesSheet(
                    iconName: "activity-01",
                    title: "settings_view_advanced_statistics",
                    desc1: "settings_view_advanced_statistics_desc",
                    desc2: "",
                    isPro: viewModel.isPro,
                    onUpgradeTap: {
                        showAdvancedStatisticsSheet = false
                        // Aspetta che si chiuda prima di aprire il paywall
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showPaywall = true
                        }
                    })
                    .presentationDetents([.fraction(0.50)])
                    .presentationDragIndicator(.visible)
                   }
      
        }
    }
    
}

// ---- ---- ---- ---- ---- ---- ---- ---- ----
//
// MARK: Components Dot
//
// ---- ---- ---- ---- ---- ---- ---- ---- ----


struct DottedLine: View {
    var body: some View {
        Line()
            .stroke(style: StrokeStyle(
                lineWidth: 2,
                lineCap: .round,
                dash: [0.1, 7]
            ))
            .frame(height: 2)
            .foregroundColor(Color(uiColor: .separator))
    }
}
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

// ---- ---- ---- ---- ---- ---- ---- ---- ----
//
// MARK: Language Selection Sheet
//
// ---- ---- ---- ---- ---- ---- ---- ---- ----

struct LanguageSelectionSheet: View {
    
    @Environment(LanguageService.self) var languageService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            
            // TITOLO E HEADER
            HStack {
                Text("settings_view_language".localized) // "Language"
                    .font(.system(.title ,design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 30)
            .padding(.horizontal)
            .padding(.bottom, 40)
            
            
            // LISTA PULSANTI
            VStack(spacing: 16) {
                
                // 1. INGLESE
                LanguageButton(
                    title: "languages.english",
                    isSelected: languageService.currentLanguage == "en",
                    action: {
                        changeLanguage(to: "en")
                    }
                )
                
                // 2. ITALIANO
                LanguageButton(
                    title: "languages.italian",
                    isSelected: languageService.currentLanguage == "it",
                    action: {
                        changeLanguage(to: "it")
                    }
                )
                
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        
    }
    
    // Funzione helper per cambiare lingua
    private func changeLanguage(to code: String) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        // Imposta la lingua
        languageService.setLanguage(code)
        // Chiude lo sheet
        dismiss()
    }
}

// Sottocomponente per il bottone lingua (per evitare codice duplicato)
private struct LanguageButton: View {
    
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title.localized)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                
                if isSelected {
                    Spacer()
                    HugeiconsText(
                        "checkmark-circle-02",
                        font: HugeiconsSolidRounded.hugeiconsFont(size: 27),
                        color: .white
                    )
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Spacer()
                    HugeiconsText(
                        "checkmark-circle-02",
                        font: HugeiconsSolidRounded.hugeiconsFont(size: 27),
                        color: Color(uiColor: .tertiarySystemGroupedBackground)
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 26)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous) // 300 o 30 per pillola
                    .fill(isSelected ? Color.pink : Color(uiColor: .secondarySystemGroupedBackground))
            )
           
        }
        .buttonStyle(SquishyButtonEffect())
    }
}

// ---- ---- ---- ---- ---- ---- ---- ---- ----
//
// MARK: Premium Features Sheet
//
// ---- ---- ---- ---- ---- ---- ---- ---- ----

struct PremiumFeaturesSheet: View {
    
    let iconName: String
    let title: String
    let desc1: String
    let desc2: String
    
    let isPro: Bool
    var onUpgradeTap: () -> Void = {}
    
    @Environment(\.dismiss) private var dismiss

    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
            
            // ICONA DINAMICA
            HugeiconsText(
                iconName,
                font: HugeiconsStrokeRounded.hugeiconsFont(size: 50),
                color: Color(.pink)
            )
            .padding()
            .background(Color.pink.opacity(0.1))
            .clipShape(Circle())
            .padding(.top, 8)
            .padding(.bottom, 20)
            
            
            Text(title.localized)
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 16)
            
            Text(desc1.localized)
                .font(.system(.body, design: .rounded))
                .fontWeight(.regular)
                .foregroundColor(.primary)
                .padding(.bottom, 12)
            
            if (!desc2.isEmpty){
                Text(desc2.localized)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
                    .padding(.bottom, 12)
            }
                        
            Spacer()
            
            Button() {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                if (!isPro){
                    onUpgradeTap()
                } else {
                    dismiss()
                }
               
            } label: {
  
                HStack(spacing: 0) {
                    
                    if (!isPro){
                        
                        HugeiconsText(
                            "circle-arrow-up-02",
                            font:  HugeiconsSolidRounded.hugeiconsFont(size:23),
                            color: .white
                        )
                        .padding(.trailing, 4)

                        Text("settings_view_purchase_premium".localized)
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    
                    else {
                        
                        Text(LocalizedStringKey("actions_close".localized))
                            .font(.system(.body, design: .default))
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 300, style: .continuous)
                        .fill( !isPro ? Color(.pink) : Color(.secondarySystemGroupedBackground))
                )
            }
            .buttonStyle(SquishyButtonEffect())
            
        }
        .padding()
    }
}

private struct SquishyButtonEffect: ButtonStyle {

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
        .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
        .brightness(configuration.isPressed ? -0.0 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0), value: configuration.isPressed)
    }
}

// ---- ---- ---- ---- ---- ---- ---- ---- ----
//
// MARK: List Tile Theme
//
// ---- ---- ---- ---- ---- ---- ---- ---- ----

private struct ListTileTheme: View {
    
    @Binding var isDarkMode: Bool
    
    var body: some View {
        Button(action: {
            // 1. Attiva la vibrazione
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            // 2. Cambi il tema
            // Logica di switch: se è 2 (scuro) torna a 1 (chiaro), altrimenti vai a 2
            // (Ignoriamo lo 0 per il toggle rapido, o decidiamo come gestirlo)
            withAnimation(.snappy(duration: 0.2)) {
                isDarkMode.toggle()
            }
        }) {
            
            HStack(spacing: 0) {
                
                // ICON
                HugeiconsText(
                    isDarkMode ? "moon-fast-wind" : "sun-01",
                    font: HugeiconsSolidRounded.hugeiconsFont(size: 27),
                    color: (isDarkMode ? .indigo : .orange )
                )
                .padding(.trailing, 24)
                
                // TEXT
                Text("settings_view_appearance".localized)
                    .font(.system(.body, design: .default))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // TESTO STATO DINAMICO
                Text(!isDarkMode ? ("settings_view_light").localized : isDarkMode ? ("settings_view_dark").localized : ("settings_view_system").localized)
                    .font(.system(.callout, design: .default))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

}


// ---- ---- ---- ---- ---- ---- ---- ---- ----
//
// MARK: List Tile
//
// ---- ---- ---- ---- ---- ---- ---- ---- ----


private struct ListTile: View {

    let iconName: String
    let textKey: String
    let url: String?
    let action: () -> Void
    
    // Init
    init(
        iconName: String,
        textKey: String,
        url: String? = nil,
        action: @escaping () -> Void = {}
    ) {
        self.iconName = iconName
        self.textKey = textKey
        self.url = url
        self.action = action
    }
    
    // Serve per aprire i link esternamente
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Button(action: {
            if let urlString = url, let webURL = URL(string: urlString) {
                // Se c'è un URL valido, apri il browser
                openURL(webURL)
            } else {
                // Altrimenti esegui l'azione passata
                action()
            }
        }) {
            HStack(spacing: 0) {
                
                // ICONA DINAMICA
                HugeiconsText(
                    iconName,
                    font: HugeiconsStrokeRounded.hugeiconsFont(size: 27),
                    color: Color(.secondaryLabel)
                )
                .padding(.trailing, 24)

                // TEXT (Tradotto automaticamente)
                Text(textKey.localized)
                    .font(.system(.body, design: .default))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if (url != nil ) {
                    // ICONA URL
                    HugeiconsText(
                        "chart-breakout-square",
                        font:  HugeiconsSolidRounded.hugeiconsFont(size: 22),
                        color: Color(.tertiaryLabel)
                    )
                } else {
                    // ICONA CLASSICA
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, design: .rounded))
                        .fontWeight(.semibold) // Apple usa un peso deciso per il chevron
                        .foregroundColor(Color(.tertiaryLabel))
                }
                
                
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}



// ---- ---- ---- ---- ---- ---- ---- ---- ----
//
// MARK: List Tile Pro
//
// ---- ---- ---- ---- ---- ---- ---- ---- ----


private struct ListTilePro: View {

    let iconName: String
    let textKey: String
    let action: () -> Void
    
    // Init
    init(
        iconName: String,
        textKey: String,
        action: @escaping () -> Void = {}
    ) {
        self.iconName = iconName
        self.textKey = textKey
        self.action = action
    }
    
    private var _proSize: CGFloat {
        return 13
    }
    
    var body: some View {
        
        Button(action: {
              action()
        }) {
            HStack(spacing: 0) {
                
                // ICONA DINAMICA
                HugeiconsText(
                    iconName,
                    font: HugeiconsStrokeRounded.hugeiconsFont(size: 27),
                    color: Color(.secondaryLabel)
                )
                .padding(.trailing, 24)

                // TEXT (Tradotto automaticamente)
                Text(textKey.localized)
                    .font(.system(.body, design: .default))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.trailing, 8)

                Text("PRO")
                    .font(.system(.caption2 ,design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal,7)
                    .padding(.vertical,5)
                    .background(.pink)
                    .cornerRadius(10)
                
                Spacer()
                
                // ICONA CLASSICA
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, design: .rounded))
                    .fontWeight(.semibold) // Apple usa un peso deciso per il chevron
                    .foregroundColor(Color(.tertiaryLabel))
                
                
                
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}




// ---- ---- ---- ---- ---- ---- ---- ---- ----
//
// MARK: Subscribe Active
//
// ---- ---- ---- ---- ---- ---- ---- ---- ----


struct SubscribeActive: View {
    
    @State private var particles: [MagicParticlePro] = []
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // SFONDO
            //Color(UIColor.systemBackground).ignoresSafeArea()
            
            // PARTICELLE (Sullo sfondo)
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    updateParticles(context: context, size: size, date: timeline.date)
                }
            }
            .ignoresSafeArea()
            
            // CONTENUTO CENTRALE
            VStack(spacing: 0) {
                
                // SPAZIO SOPRA (Per far vedere le particelle sopra l'icona)
                Color.clear.frame(height: 24)
                
                // --- ICONA ---
                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(.pink),
                                    Color(red: 0.85, green: 0.0, blue: 0.45), // Magenta scuro
                                    //Color(red: 1.0, green: 0.4, blue: 0.7)    // Rosa acceso
                                ],
                                startPoint: .topTrailing,
                                endPoint: .bottomLeading
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(color: Color.pink.opacity(0.4), radius: 20, x: 0, y: 0)
                    
                    
                    HugeiconsText(
                        "rhombus-01",
                        font:  HugeiconsSolidRounded.hugeiconsFont(size: 33),
                        color: Color(.white.opacity(0.9))
                    )
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
                    .foregroundColor(.white.opacity(0.9))
                    /*
                    Image(systemName: "sparkle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                        .foregroundColor(.white.opacity(0.9))*/
                }
                .padding(.bottom, 20)
                
                // --- TITOLO ---
                Text("settings_view_purchase_you_are_a_legend".localized)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)
                
                // --- DESCRIZIONE ---
                Text("settings_view_purchase_you_are_a_legend_desc".localized)
                    .font(.system(.subheadline, design: .default))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(8)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                
                // SPAZIO SOTTO (Per far vedere le particelle sotto il testo)
                Color.clear.frame(height: 32)
            }
        }
    }
    
    // LOGICA PARTICELLE
    private func updateParticles(context: GraphicsContext, size: CGSize, date: Date) {
        // GENERAZIONE (BATCH)
        // Se siamo sotto il limite, ne aggiungiamo TANTE per frame, non una sola.
        if particles.count < 330 {
            
            var newParticles: [MagicParticlePro] = []
            
            // MODIFICA QUI: Aggiungiamo 15 particelle PER FRAME invece di 1
            // Questo riempirà lo schermo molto velocemente
            for _ in 0..<3 {
                
                let colors: [Color] = [
                    .pink,
                    .pink.opacity(0.8),
                    Color(red: 1, green: 0.4, blue: 0.7),
                    Color(red: 0.8, green: 0.2, blue: 0.5)
                ]
                let particleColor = colors.randomElement() ?? .pink
                
                let randomDuration = Double.random(in: 0.8...1.2)
                
                let p = MagicParticlePro(
                    x: Double.random(in: (size.width * 0.01)...(size.width * 0.99)), // Tutta la larghezza
                    y: Double.random(in: (0.04)...(size.height * 0.96)), // Dall'alto assoluto fino a sotto il testo
                    opacity: 1.0,
                    size: Double.random(in: 0.2...1.8), // Piccole
                    speed: Double.random(in: 0.1...0.5), // Lente
                    drift: Double.random(in: -0.2...0.2),
                    creationDate: date,
                    color: particleColor,
                    duration: randomDuration
                )
                newParticles.append(p)
            }
            
            DispatchQueue.main.async {
                particles.append(contentsOf: newParticles)
            }
        }
        
        // 2. DISEGNO
        for particle in particles {
            let elapsed = date.timeIntervalSince(particle.creationDate)
            //  Durata ridotta (Svaniscono prima, tra 0.8 e 1.2)
            let duration = particle.duration
            
            let progress = elapsed / duration
            
            if progress < 1.0 {
                let scale = sin(Double.pi * progress)
                let currentSize = particle.size * scale
                
                // Opacità alta per visibilità, ma svanisce con la scala
                let visibilityFactor = 0.9
                let currentOpacity = scale * visibilityFactor
                
                // UPDATE: Moltiplicatore ridotto a 15 (prima era 50).
                // Si spostano pochissimo verso l'alto.
                let currentY = particle.y - (particle.speed * elapsed * 15)
                let currentX = particle.x + (particle.drift * elapsed * 10)
                
                var innerContext = context
                innerContext.opacity = currentOpacity
                
                let rect = CGRect(
                    x: currentX - (currentSize / 2),
                    y: currentY - (currentSize / 2),
                    width: currentSize,
                    height: currentSize
                )
                
                innerContext.fill(Circle().path(in: rect), with: .color(particle.color))
            }
        }
        
        // 3. PULIZIA
        DispatchQueue.main.async {
            // Rimuoviamo più velocemente
            particles.removeAll { date.timeIntervalSince($0.creationDate) > 1.2 }
        }
    }
}

private struct MagicParticlePro {
    var x: Double
    var y: Double
    var opacity: Double
    let size: Double
    let speed: Double
    let drift: Double
    let creationDate: Date
    let color: Color
    let duration: Double
}




// ---- ---- ---- ---- ---- ---- ---- ---- ----
//
// MARK: Purcahse Component
//
// ---- ---- ---- ---- ---- ---- ---- ---- ----

private struct MagicParticle {
    var x: Double
    var y: Double
    var opacity: Double
    let size: Double
    let speed: Double
    let drift: Double
    let creationDate: Date
}

struct PurchaseComponent: View {
        
    @Binding var showPaywall: Bool
    
    @State private var particles: [MagicParticle] = []
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                showPaywall = true
                
            }) {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    updateParticles(context: context, size: size, date: timeline.date)
                }
            }
            .frame(minHeight: 110)
            .background(
                RoundedRectangle(cornerRadius: (24+2), style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.pink, Color.pink.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(cardContent)
        }
    .buttonStyle(SquishyButtonEffect())
    }
    
    private var cardContent: some View {
        
        HStack {
            
            HugeiconsText(
                "rhombus-01",
                font:  HugeiconsSolidRounded.hugeiconsFont(size: 27),
                color: Color(.white.opacity(0.8))
            )
            .padding(.trailing, 6)
            
            VStack(alignment: .leading, spacing: 2.5) {
                Text("settings_view_purchase_title".localized)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("settings_view_purchase_subtitle".localized)
                    .font(.system(.subheadline, design: .default))
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("settings_view_purchase_cta".localized)
                    .font(.system(.subheadline, design: .default))
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            upgradeButton
                .fixedSize(horizontal: true, vertical: true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 26)


    }
    
    private var upgradeButton: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            showPaywall = true
        }) {
            HStack(spacing: 0) {
                HugeiconsText(
                    "circle-arrow-up-02",
                    font:  HugeiconsSolidRounded.hugeiconsFont(size:20),
                    color: .white
                )
                .padding(.trailing, 4)

                Text("settings_view_purchase_premium".localized)
            }
            .font(.system(.subheadline, design: .default))
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 300, style: .continuous)
                    .fill(Color.white.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 300, style: .continuous)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            //.overlay(
            //    AnimatedBorder(cornerRadius: 300)
            //)
            
        }
        .buttonStyle(SquishyButtonEffect())
    }

    private func updateParticles(context: GraphicsContext, size: CGSize, date: Date) {
        // 1. GENERAZIONE
        if particles.count < 55 {
            let p = MagicParticle(
                x: Double.random(in: (size.width * 0.04)...(size.width * 0.96)),
                y: Double.random(in: (size.height * 0.10)...(size.height * 0.90)),
                opacity: 1.0,
                size: Double.random(in: 0.3...1.9), // ANCORA PIÙ PICCOLE (default in: 0.3...1.9))
                speed: Double.random(in: 0.3...0.7), // Velocità molto contenuta
                drift: Double.random(in: -0.3...0.3),
                creationDate: date
            )
            
            DispatchQueue.main.async {
                particles.append(p)
            }
        }
        
        // 2. DISEGNO CON EFFETTO CRESCITA/DECRESCITA
        for particle in particles {
            let elapsed = date.timeIntervalSince(particle.creationDate)
            let duration: Double = 1.0 // Durata totale della vita
            
            // Calcolo del progresso (da 0.0 a 1.0)
            let progress = elapsed / duration
            
            if progress < 1.0 {
                // Calcolo scala: sale da 0 a 1 e torna a 0 usando una funzione seno
                // Double.pi * progress crea una curva che a metà (0.5) è al valore massimo (1.0)
                let scale = sin(Double.pi * progress)
                
                // Applichiamo la scala alla dimensione e all'opacità
                let currentSize = particle.size * scale
                let currentOpacity = scale // Svanisce anche l'opacità insieme alla dimensione
                
                // Movimento lento verso l'alto
                let currentY = particle.y - (particle.speed * elapsed * 10)
                let currentX = particle.x + (particle.drift * elapsed * 10)
                
                var innerContext = context
                innerContext.opacity = currentOpacity
                
                // Centriamo il rettangolo per evitare che la particella "salti" mentre cresce
                let rect = CGRect(
                    x: currentX - (currentSize / 2),
                    y: currentY - (currentSize / 2),
                    width: currentSize,
                    height: currentSize
                )
                
                innerContext.fill(Circle().path(in: rect), with: .color(.white))
            }
        }
        
        // 3. PULIZIA
        DispatchQueue.main.async {
            particles.removeAll { date.timeIntervalSince($0.creationDate) > 1.0 }
        }
    }
}



struct AnimatedBorder: View {
    let cornerRadius: CGFloat
    
    @State private var progress: CGFloat = 0.0
    
    // Configurazione Tempi
    let animationDuration: Double = 2.3
    let pauseDuration: Double = 1.5
    let tailLength: CGFloat = 0.1 // Lunghezza della scia di luce
    
    var body: some View {
        ZStack {
            // LUCE SUPERIORE
            AnimatedShape(progress: progress, tailLength: tailLength)
            
            // LUCE INFERIORE (Specchiata)
            AnimatedShape(progress: progress, tailLength: tailLength)
                .scaleEffect(y: -1)
        }
        .onAppear {
            animateWithPause()
        }
    }
    
    private func animateWithPause() {
        progress = 0
        withAnimation(.linear(duration: animationDuration)) {
            // Arriva a 0.5 (fine destra) + tailLength per sparire completamente
            progress = 0.5 + tailLength
        }
        
        // Timer per la pausa tra un ciclo e l'altro
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + pauseDuration) {
            animateWithPause()
        }
    }
}

// Questa struttura definisce la forma animabile
struct AnimatedShape: View, Animatable {
    var progress: CGFloat
    var tailLength: CGFloat
    
    // Questo rende il valore 'progress' animabile da SwiftUI
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    var body: some View {
        Capsule()
            // Ora .trim funziona perché siamo su una Shape!
            .trim(from: max(progress - tailLength, 0), to: min(progress, 0.5))
            .stroke(
                LinearGradient(
                    colors: [
                        .white.opacity(0.6),
                        .white.opacity(1),
                        .white.opacity(0.6),
                        progress < 0.5 ? .white.opacity(0) : .white
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 1.05, lineCap: .round)
            )
            .rotationEffect(.degrees(180)) // Fa partire lo 0 da sinistra
            .shadow(color: .white.opacity(0.8), radius: 3)
    }
}

