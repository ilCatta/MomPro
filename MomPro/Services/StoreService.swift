//
//  StoreService.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import Foundation
import RevenueCat
import RevenueCatUI // Importante per le feature UI

@Observable
class StoreService: NSObject, PurchasesDelegate {
    static let shared = StoreService()
    
    // Stato dell'abbonamento (La UI osserverà questa variabile)
    var isPro: Bool = false
    
    // Info complete sul cliente (utile per debug o info extra)
    var customerInfo: CustomerInfo?
    
    override private init() {
        super.init()
    }
    
    // 1. Configurazione all'avvio dell'app
    func configure() {
        // Prende la chiave dal file Configuration che abbiamo creato prima
        Purchases.configure(withAPIKey: StoreConfiguration.revenueCatAPIKey)
        
        // Imposta il delegate per ascoltare aggiornamenti in tempo reale
        Purchases.shared.delegate = self
        
        // Controlla subito lo stato
        fetchCustomerInfo()
    }
    
    // 2. Aggiorna lo stato Pro
    func fetchCustomerInfo() {
        Purchases.shared.getCustomerInfo { [weak self] (info, error) in
            guard let self = self, let info = info else { return }
            self.updateProStatus(with: info)
        }
    }
    
    // Logica centrale per decidere se è Pro
    private func updateProStatus(with info: CustomerInfo) {
        self.customerInfo = info
        // "pro" è l'Entitlement ID che devi creare sulla Dashboard di RevenueCat
        self.isPro = info.entitlements["pro"]?.isActive == true
        print("User is Pro: \(self.isPro)")
    }
    
    // MARK: - PurchasesDelegate Methods
    
    // Chiamato automaticamente quando RevenueCat rileva un cambiamento (es. rinnovo, scadenza, acquisto da altro device)
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        updateProStatus(with: customerInfo)
    }
    
    // MARK: - Helper Methods
    
    // Funzione per ripristinare acquisti (Obbligatorio per Apple Review)
    func restorePurchases() async {
        do {
            let info = try await Purchases.shared.restorePurchases()
            updateProStatus(with: info)
        } catch {
            print("Errore nel restore: \(error)")
        }
    }
}
