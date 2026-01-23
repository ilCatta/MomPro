
import SwiftUI
import RevenueCatUI // Serve per il Paywall

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    
    // Recuperiamo il LanguageService passato dall'ambiente in MomProApp
    @Environment(LanguageService.self) var languageService
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - SEZIONE ABBONAMENTO
                Section {
                    if viewModel.isPro {
                        // UTENTE PRO
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Sei un membro MumPro".localized)
                                    .font(.headline)
                                Text("Grazie per il tuo supporto!".localized)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        // UTENTE FREE
                        Button(action: {
                            viewModel.openPaywall()
                        }) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.pink)
                                        .frame(width: 34, height: 34)
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.white)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Diventa MumPro".localized)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text("Sblocca tutto e rimuovi i limiti".localized)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                } header: {
                    Text("Il tuo piano".localized)
                }
                
                // MARK: - SEZIONE ASPETTO
                Section("Aspetto".localized) {
                    
                    // TOGGLE DARK MODE
                    Toggle(isOn: $viewModel.isDarkMode) {
                        Label("Modalità Scura".localized, systemImage: "moon.fill")
                    }
                    
                    // PICKER CAMBIO LINGUA
                    Picker(selection: Binding(
                        get: { languageService.currentLanguage },
                        set: { languageService.setLanguage($0) }
                    )) {
                        Text("English").tag("en")
                        Text("Italiano").tag("it")
                    } label: {
                        Label("Lingua / Language".localized, systemImage: "globe")
                    }
                }
                
                // MARK: - SEZIONE SUPPORTO
                Section("Supporto".localized) {
                    // Tasto Ripristina (OBBLIGATORIO PER APPLE)
                    Button(action: {
                        viewModel.restorePurchases()
                    }) {
                        Label("Ripristina Acquisti".localized, systemImage: "arrow.clockwise")
                    }
                    
                    // Link contatti (Sostituisci con la tua mail vera)
                    Link(destination: URL(string: "mailto:support@mumpro.app")!) {
                        Label("Contattaci".localized, systemImage: "envelope")
                    }
                    
                    // Link termini (Sostituisci con il tuo sito vero)
                    Link(destination: URL(string: "https://mumpro.app/terms")!) {
                        Label("Termini e Privacy".localized, systemImage: "doc.text")
                    }
                }
                
                // MARK: - INFO VERSION
                Section {
                    HStack {
                        Text("Versione".localized)
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundStyle(.secondary)
                    }
                } footer: {
                    Text("Fatto con ❤️ per le mamme.".localized)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)
                }
            }
            .navigationTitle("Opzioni".localized)
            
            // --- MODALI ---
            
            // 1. Paywall Sheet
            .sheet(isPresented: $viewModel.showPaywall) {
                PaywallView(displayCloseButton: true)
            }
            
            // 2. Alert Risultato Ripristino
            .alert("Ripristino".localized, isPresented: $viewModel.showRestoreAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.restoreMessage)
            }
        }
    }
}

#Preview {
    // Per la preview dobbiamo iniettare il LanguageService mockato o reale
    SettingsView()
        .environment(LanguageService.shared)
}
