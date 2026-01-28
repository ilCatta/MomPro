//
//  ContentService.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import Foundation

class ContentService {
    static let shared = ContentService()
    
    
    //
    //
    //
    //
    // MARK: - Task Fisso
    // Usiamo un UUID fisso per poterlo salvare e ricaricare senza perderlo
    let educationTask = TaskItem(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        title: "Leggi un articolo",
        description: "Dedica 5 minuti alla tua educazione finanziaria.",
        category: .education,
        isPro: false
    )
    //
    //
    //
    //
    // MARK: - Database Obbiettivi/Task
    //
    //
    private let rawTasks: [TaskItem] = [
        //
        //
        //
        // MARK: - SHOPPING
        // MARK: - Smart Swaps (Free: 8, Pro: 4)
            TaskItem(
                title: "shopping_01_title",
                description: "shopping_01_desc",
                category: .shopping,
                type: .counter,
                targetCount: 2,
                isPro: false // Fondamentale
            ),
            TaskItem(
                title: "shopping_02_title",
                description: "shopping_02_desc",
                category: .shopping,
                type: .counter,
                targetCount: 3,
                isPro: false // Fondamentale
            ),
            TaskItem(
                title: "shopping_03_title",
                description: "shopping_03_desc",
                category: .shopping,
                type: .counter,
                targetCount: 1,
                isPro: false
            ),
            TaskItem(
                title: "shopping_04_title",
                description: "shopping_04_desc",
                category: .shopping,
                isPro: false
            ),
            TaskItem(
                title: "shopping_05_title",
                description: "shopping_05_desc",
                category: .shopping,
                isPro: false
            ),
            TaskItem(
                title: "shopping_06_title",
                description: "shopping_06_desc",
                category: .shopping,
                isPro: true // Swap avanzato (dieta + risparmio)
            ),
            TaskItem(
                title: "shopping_07_title",
                description: "shopping_07_desc",
                category: .shopping,
                isPro: false
            ),
            TaskItem(
                title: "shopping_08_title",
                description: "shopping_08_desc",
                category: .shopping,
                isPro: false
            ),
            TaskItem(
                title: "shopping_09_title",
                description: "shopping_09_desc",
                category: .shopping,
                isPro: false
            ),
            TaskItem(
                title: "shopping_10_title",
                description: "shopping_10_desc",
                category: .shopping,
                type: .counter,
                targetCount: 3,
                isPro: true // Caccia attiva richiede impegno
            ),
            TaskItem(
                title: "shopping_11_title",
                description: "shopping_11_desc",
                category: .shopping,
                isPro: true // Risparmio "bulk"
            ),
            TaskItem(
                title: "shopping_12_title",
                description: "shopping_12_desc",
                category: .shopping,
                isPro: true // Strategia ad alto rendimento
            ),

            // MARK: - Pianificazione (Free: 6, Pro: 4)
            TaskItem(
                title: "shopping_13_title",
                description: "shopping_13_desc",
                category: .shopping,
                isPro: false // Base
            ),
            TaskItem(
                title: "shopping_14_title",
                description: "shopping_14_desc",
                category: .shopping,
                isPro: false
            ),
            TaskItem(
                title: "shopping_15_title",
                description: "shopping_15_desc",
                category: .shopping,
                isPro: true // Metodo avanzato (Cash stuffing)
            ),
            TaskItem(
                title: "shopping_16_title",
                description: "shopping_16_desc",
                category: .shopping,
                isPro: true // Richiede tempo e strategia
            ),
            TaskItem(
                title: "shopping_17_title",
                description: "shopping_17_desc",
                category: .shopping,
                isPro: false
            ),
            TaskItem(
                title: "shopping_18_title",
                description: "shopping_18_desc",
                category: .shopping,
                isPro: true // Hack psicologico
            ),
            TaskItem(
                title: "shopping_19_title",
                description: "shopping_19_desc",
                category: .shopping,
                isPro: true // Challenge difficile
            ),
            TaskItem(
                title: "shopping_20_title",
                description: "shopping_20_desc",
                category: .shopping,
                isPro: false
            ),
            TaskItem(
                title: "shopping_21_title",
                description: "shopping_21_desc",
                category: .shopping,
                isPro: false // Azione semplice
            ),
            TaskItem(
                title: "shopping_22_title",
                description: "shopping_22_desc",
                category: .shopping,
                isPro: false
            ),

            // MARK: - Batch Cooking (Free: 6, Pro: 6)
            TaskItem(
                title: "shopping_23_title",
                description: "shopping_23_desc",
                category: .shopping,
                type: .counter,
                targetCount: 1,
                isPro: false // Entry level
            ),
            TaskItem(
                title: "shopping_24_title",
                description: "shopping_24_desc",
                category: .shopping,
                type: .counter,
                targetCount: 2,
                isPro: false
            ),
            TaskItem(
                title: "shopping_25_title",
                description: "shopping_25_desc",
                category: .shopping,
                type: .counter,
                targetCount: 3,
                isPro: true // Ottimizzazione avanzata
            ),
            TaskItem(
                title: "shopping_26_title",
                description: "shopping_26_desc",
                category: .shopping,
                type: .counter,
                targetCount: 4,
                isPro: true // Salute + Risparmio
            ),
            TaskItem(
                title: "shopping_27_title",
                description: "shopping_27_desc",
                category: .shopping,
                isPro: true // Prep ingredienti
            ),
            TaskItem(
                title: "shopping_28_title",
                description: "shopping_28_desc",
                category: .shopping,
                isPro: true // Risparmio elevato
            ),
            TaskItem(
                title: "shopping_29_title",
                description: "shopping_29_desc",
                category: .shopping,
                isPro: false // Abitudine base
            ),
            TaskItem(
                title: "shopping_30_title",
                description: "shopping_30_desc",
                category: .shopping,
                isPro: true // Zero waste pro
            ),
            TaskItem(
                title: "shopping_31_title",
                description: "shopping_31_desc",
                category: .shopping,
                isPro: false
            ),
            TaskItem(
                title: "shopping_32_title",
                description: "shopping_32_desc",
                category: .shopping,
                isPro: false
            ),
            TaskItem(
                title: "shopping_33_title",
                description: "shopping_33_desc",
                category: .shopping,
                isPro: true // Time saving estremo
            ),
            TaskItem(
                title: "shopping_34_title",
                description: "shopping_34_desc",
                category: .shopping,
                isPro: false
            ),

            // MARK: - No-Waste (Free: 6, Pro: 3)
            TaskItem(
                title: "shopping_35_title",
                description: "shopping_35_desc",
                category: .shopping,
                isPro: false
            ),
            TaskItem(
                title: "shopping_36_title",
                description: "shopping_36_desc",
                category: .shopping,
                type: .counter,
                targetCount: 2,
                isPro: false
            ),
            TaskItem(
                title: "shopping_37_title",
                description: "shopping_37_desc",
                category: .shopping,
                isPro: false
            ),
            TaskItem(
                title: "shopping_38_title",
                description: "shopping_38_desc",
                category: .shopping,
                isPro: false
            ),
            TaskItem(
                title: "shopping_39_title",
                description: "shopping_39_desc",
                category: .shopping,
                isPro: false
            ),
            TaskItem(
                title: "shopping_40_title",
                description: "shopping_40_desc",
                category: .shopping,
                isPro: false
            ),
            TaskItem(
                title: "shopping_41_title",
                description: "shopping_41_desc",
                category: .shopping,
                isPro: true // Challenge dispensa
            ),
            TaskItem(
                title: "shopping_42_title",
                description: "shopping_42_desc",
                category: .shopping,
                isPro: true // Education
            ),
            TaskItem(
                title: "shopping_43_title",
                description: "shopping_43_desc",
                category: .shopping,
                isPro: true // Integrazione esterna
            ),

            // MARK: - Psicologia (Free: 4, Pro: 3)
            TaskItem(
                title: "shopping_44_title",
                description: "shopping_44_desc",
                category: .shopping,
                isPro: false // Mindset base
            ),
            TaskItem(
                title: "shopping_45_title",
                description: "shopping_45_desc",
                category: .shopping,
                type: .counter,
                targetCount: 2,
                isPro: true // Digital declutter
            ),
            TaskItem(
                title: "shopping_46_title",
                description: "shopping_46_desc",
                category: .shopping,
                isPro: true // Mindset avanzato
            ),
            TaskItem(
                title: "shopping_47_title",
                description: "shopping_47_desc",
                category: .shopping,
                isPro: true // Social detox
            ),
            TaskItem(
                title: "shopping_48_title",
                description: "shopping_48_desc",
                category: .shopping,
                isPro: false
            ),
            TaskItem(
                title: "shopping_49_title",
                description: "shopping_49_desc",
                category: .shopping,
                isPro: false // Challenge accessibile
            ),
            TaskItem(
                title: "shopping_50_title",
                description: "shopping_50_desc",
                category: .shopping,
                isPro: false
            ),
            //
            //
            //
            // MARK: - FINANZA
            TaskItem(
                    title: "finance_01_title",
                    description: "finance_01_desc",
                    category: .finance,
                    isPro: false // Fondamentale per tutti
                ),
                TaskItem(
                    title: "finance_02_title",
                    description: "finance_02_desc",
                    category: .finance,
                    isPro: false // Quick win
                ),
                TaskItem(
                    title: "finance_03_title",
                    description: "finance_03_desc",
                    category: .finance,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_04_title",
                    description: "finance_04_desc",
                    category: .finance,
                    type: .counter,
                    targetCount: 3,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_05_title",
                    description: "finance_05_desc",
                    category: .finance,
                    isPro: true // Tracking avanzato nel tempo
                ),
                TaskItem(
                    title: "finance_06_title",
                    description: "finance_06_desc",
                    category: .finance,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_07_title",
                    description: "finance_07_desc",
                    category: .finance,
                    isPro: true // Analisi di nicchia
                ),
                TaskItem(
                    title: "finance_08_title",
                    description: "finance_08_desc",
                    category: .finance,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_09_title",
                    description: "finance_09_desc",
                    category: .finance,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_10_title",
                    description: "finance_10_desc",
                    category: .finance,
                    isPro: true // Richiede analisi approfondita
                ),
                TaskItem(
                    title: "finance_11_title",
                    description: "finance_11_desc",
                    category: .finance,
                    isPro: false // Sicurezza base
                ),
                TaskItem(
                    title: "finance_12_title",
                    description: "finance_12_desc",
                    category: .finance,
                    isPro: false // Azione ad alto impatto free
                ),

                // MARK: - Investing Basics (Free: 5, Pro: 8)
                // Qui spingiamo l'upgrade per imparare a investire seriamente
                TaskItem(
                    title: "finance_13_title",
                    description: "finance_13_desc",
                    category: .finance,
                    isPro: false // Teoria base (Paura)
                ),
                TaskItem(
                    title: "finance_14_title",
                    description: "finance_14_desc",
                    category: .finance,
                    isPro: false // Definizione base
                ),
                TaskItem(
                    title: "finance_15_title",
                    description: "finance_15_desc",
                    category: .finance,
                    isPro: true // Strumento specifico
                ),
                TaskItem(
                    title: "finance_16_title",
                    description: "finance_16_desc",
                    category: .finance,
                    isPro: false // Motivazionale
                ),
                TaskItem(
                    title: "finance_17_title",
                    description: "finance_17_desc",
                    category: .finance,
                    isPro: false // Regola d'oro
                ),
                TaskItem(
                    title: "finance_18_title",
                    description: "finance_18_desc",
                    category: .finance,
                    isPro: true // Psicologia investitore
                ),
                TaskItem(
                    title: "finance_19_title",
                    description: "finance_19_desc",
                    category: .finance,
                    isPro: true // Strategia Portfolio
                ),
                TaskItem(
                    title: "finance_20_title",
                    description: "finance_20_desc",
                    category: .finance,
                    isPro: true // Core Content (ETF)
                ),
                TaskItem(
                    title: "finance_21_title",
                    description: "finance_21_desc",
                    category: .finance,
                    isPro: true // Planning lungo termine
                ),
                TaskItem(
                    title: "finance_22_title",
                    description: "finance_22_desc",
                    category: .finance,
                    isPro: true // Strategia PAC
                ),
                TaskItem(
                    title: "finance_23_title",
                    description: "finance_23_desc",
                    category: .finance,
                    isPro: true // Tasse (Argomento complesso)
                ),
                TaskItem(
                    title: "finance_24_title",
                    description: "finance_24_desc",
                    category: .finance,
                    isPro: false // Simulazione divertente
                ),
                TaskItem(
                    title: "finance_25_title",
                    description: "finance_25_desc",
                    category: .finance,
                    isPro: true // Risorse extra
                ),

                // MARK: - Micro-Savings (Free: 10, Pro: 3)
                TaskItem(
                    title: "finance_26_title",
                    description: "finance_26_desc",
                    category: .finance,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_27_title",
                    description: "finance_27_desc",
                    category: .finance,
                    isPro: true // Challenge estrema
                ),
                TaskItem(
                    title: "finance_28_title",
                    description: "finance_28_desc",
                    category: .finance,
                    type: .counter,
                    targetCount: 1,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_29_title",
                    description: "finance_29_desc",
                    category: .finance,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_30_title",
                    description: "finance_30_desc",
                    category: .finance,
                    type: .counter,
                    targetCount: 3,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_31_title",
                    description: "finance_31_desc",
                    category: .finance,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_32_title",
                    description: "finance_32_desc",
                    category: .finance,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_33_title",
                    description: "finance_33_desc",
                    category: .finance,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_34_title",
                    description: "finance_34_desc",
                    category: .finance,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_35_title",
                    description: "finance_35_desc",
                    category: .finance,
                    isPro: true // Tech feature
                ),
                TaskItem(
                    title: "finance_36_title",
                    description: "finance_36_desc",
                    category: .finance,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_37_title",
                    description: "finance_37_desc",
                    category: .finance,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_38_title",
                    description: "finance_38_desc",
                    category: .finance,
                    isPro: true // Lifestyle
                ),

                // MARK: - Future & Mindset (Free: 6, Pro: 6)
                TaskItem(
                    title: "finance_39_title",
                    description: "finance_39_desc",
                    category: .finance,
                    isPro: false // Visualizzazione base
                ),
                TaskItem(
                    title: "finance_40_title",
                    description: "finance_40_desc",
                    category: .finance,
                    isPro: true // Strumento potente (Pensione)
                ),
                TaskItem(
                    title: "finance_41_title",
                    description: "finance_41_desc",
                    category: .finance,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_42_title",
                    description: "finance_42_desc",
                    category: .finance,
                    isPro: true // Crescita personale pro
                ),
                TaskItem(
                    title: "finance_43_title",
                    description: "finance_43_desc",
                    category: .finance,
                    type: .counter,
                    targetCount: 3,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_44_title",
                    description: "finance_44_desc",
                    category: .finance,
                    isPro: true // Automazione (Livello alto)
                ),
                TaskItem(
                    title: "finance_45_title",
                    description: "finance_45_desc",
                    category: .finance,
                    isPro: true // Protezione asset
                ),
                TaskItem(
                    title: "finance_46_title",
                    description: "finance_46_desc",
                    category: .finance,
                    isPro: true // Gestione avanzata
                ),
                TaskItem(
                    title: "finance_47_title",
                    description: "finance_47_desc",
                    category: .finance,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_48_title",
                    description: "finance_48_desc",
                    category: .finance,
                    isPro: true // Family planning pro
                ),
                TaskItem(
                    title: "finance_49_title",
                    description: "finance_49_desc",
                    category: .finance,
                    isPro: false
                ),
                TaskItem(
                    title: "finance_50_title",
                    description: "finance_50_desc",
                    category: .finance,
                    type: .counter,
                    targetCount: 3,
                    isPro: false // Gratitude journal
                ),
            //
            //
            //
            //
            // MARK: - HOME
            // MARK: - Bollette & Efficienza (Free: 8, Pro: 4)
                TaskItem(
                    title: "home_01_title",
                    description: "home_01_desc",
                    category: .home,
                    type: .counter,
                    targetCount: 3,
                    isPro: false // Fondamentale
                ),
                TaskItem(
                    title: "home_02_title",
                    description: "home_02_desc",
                    category: .home,
                    isPro: false // Risparmio immediato
                ),
                TaskItem(
                    title: "home_03_title",
                    description: "home_03_desc",
                    category: .home,
                    isPro: true // Richiede acquisto/azione specifica
                ),
                TaskItem(
                    title: "home_04_title",
                    description: "home_04_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_05_title",
                    description: "home_05_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_06_title",
                    description: "home_06_desc",
                    category: .home,
                    isPro: true // Ottimizzazione termica
                ),
                TaskItem(
                    title: "home_07_title",
                    description: "home_07_desc",
                    category: .home,
                    isPro: true // Manutenzione elettrodomestico
                ),
                TaskItem(
                    title: "home_08_title",
                    description: "home_08_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_09_title",
                    description: "home_09_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_10_title",
                    description: "home_10_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_11_title",
                    description: "home_11_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_12_title",
                    description: "home_12_desc",
                    category: .home,
                    isPro: true // Analisi dati
                ),

                // MARK: - Manutenzione (Free: 5, Pro: 7)
                // Qui spingiamo il Pro: prevenire costa meno che riparare.
                TaskItem(
                    title: "home_13_title",
                    description: "home_13_desc",
                    category: .home,
                    isPro: true // Salute + Efficienza
                ),
                TaskItem(
                    title: "home_14_title",
                    description: "home_14_desc",
                    category: .home,
                    isPro: true // Salva-lavatrice (Alto valore)
                ),
                TaskItem(
                    title: "home_15_title",
                    description: "home_15_desc",
                    category: .home,
                    isPro: false // Rimedio naturale base
                ),
                TaskItem(
                    title: "home_16_title",
                    description: "home_16_desc",
                    category: .home,
                    type: .counter,
                    targetCount: 2,
                    isPro: true // Prevenzione danni gravi
                ),
                TaskItem(
                    title: "home_17_title",
                    description: "home_17_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_18_title",
                    description: "home_18_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_19_title",
                    description: "home_19_desc",
                    category: .home,
                    isPro: true // Efficienza nascosta
                ),
                TaskItem(
                    title: "home_20_title",
                    description: "home_20_desc",
                    category: .home,
                    type: .counter,
                    targetCount: 2,
                    isPro: true // Sicurezza
                ),
                TaskItem(
                    title: "home_21_title",
                    description: "home_21_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_22_title",
                    description: "home_22_desc",
                    category: .home,
                    isPro: true // Igiene profonda
                ),
                TaskItem(
                    title: "home_23_title",
                    description: "home_23_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_24_title",
                    description: "home_24_desc",
                    category: .home,
                    isPro: true // Sicurezza elettrica
                ),

                // MARK: - Home Reno/Refresh (Free: 7, Pro: 5)
                TaskItem(
                    title: "home_25_title",
                    description: "home_25_desc",
                    category: .home,
                    isPro: false // Design democratico
                ),
                TaskItem(
                    title: "home_26_title",
                    description: "home_26_desc",
                    category: .home,
                    type: .counter,
                    targetCount: 3,
                    isPro: false
                ),
                TaskItem(
                    title: "home_27_title",
                    description: "home_27_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_28_title",
                    description: "home_28_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_29_title",
                    description: "home_29_desc",
                    category: .home,
                    isPro: true // Cura del dettaglio
                ),
                TaskItem(
                    title: "home_30_title",
                    description: "home_30_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_31_title",
                    description: "home_31_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_32_title",
                    description: "home_32_desc",
                    category: .home,
                    isPro: true // Feeling lusso
                ),
                TaskItem(
                    title: "home_33_title",
                    description: "home_33_desc",
                    category: .home,
                    isPro: true // Manutenzione estetica
                ),
                TaskItem(
                    title: "home_34_title",
                    description: "home_34_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_35_title",
                    description: "home_35_desc",
                    category: .home,
                    isPro: true // DIY avanzato
                ),
                TaskItem(
                    title: "home_36_title",
                    description: "home_36_desc",
                    category: .home,
                    isPro: true // Alternative naturali
                ),

                // MARK: - Organizzazione (Free: 10, Pro: 4)
                TaskItem(
                    title: "home_37_title",
                    description: "home_37_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_38_title",
                    description: "home_38_desc",
                    category: .home,
                    type: .counter,
                    targetCount: 2,
                    isPro: true // Guadagno diretto (Vinted)
                ),
                TaskItem(
                    title: "home_39_title",
                    description: "home_39_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_40_title",
                    description: "home_40_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_41_title",
                    description: "home_41_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_42_title",
                    description: "home_42_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_43_title",
                    description: "home_43_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_44_title",
                    description: "home_44_desc",
                    category: .home,
                    isPro: true // Strategia risparmio giocattoli
                ),
                TaskItem(
                    title: "home_45_title",
                    description: "home_45_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_46_title",
                    description: "home_46_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_47_title",
                    description: "home_47_desc",
                    category: .home,
                    isPro: true // Kit emergenza (Proattivo)
                ),
                TaskItem(
                    title: "home_48_title",
                    description: "home_48_desc",
                    category: .home,
                    isPro: false
                ),
                TaskItem(
                    title: "home_49_title",
                    description: "home_49_desc",
                    category: .home,
                    isPro: true // Igiene cosmetica
                ),
                TaskItem(
                    title: "home_50_title",
                    description: "home_50_desc",
                    category: .home,
                    isPro: false // Decorazione gratis
                ),
            //
            //
            //
            //
            // MARK: - FAMILY
            TaskItem(
                   title: "family_01_title",
                   description: "family_01_desc",
                   category: .family,
                   isPro: false // Fondamentale
               ),
               TaskItem(
                   title: "family_02_title",
                   description: "family_02_desc",
                   category: .family,
                   type: .counter,
                   targetCount: 3,
                   isPro: false // Gioco semplice
               ),
               TaskItem(
                   title: "family_03_title",
                   description: "family_03_desc",
                   category: .family,
                   isPro: true // Regola avanzata
               ),
               TaskItem(
                   title: "family_04_title",
                   description: "family_04_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_05_title",
                   description: "family_05_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_06_title",
                   description: "family_06_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_07_title",
                   description: "family_07_desc",
                   category: .family,
                   isPro: true // Strumento educativo pro
               ),
               TaskItem(
                   title: "family_08_title",
                   description: "family_08_desc",
                   category: .family,
                   isPro: true // Psicologia infantile
               ),
               TaskItem(
                   title: "family_09_title",
                   description: "family_09_desc",
                   category: .family,
                   type: .counter,
                   targetCount: 2,
                   isPro: false
               ),
               TaskItem(
                   title: "family_10_title",
                   description: "family_10_desc",
                   category: .family,
                   isPro: true // Educazione mediatica
               ),
               TaskItem(
                   title: "family_11_title",
                   description: "family_11_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_12_title",
                   description: "family_12_desc",
                   category: .family,
                   isPro: true // Investimenti per bambini
               ),

               // MARK: - Divertimento Low Cost (Free: 8, Pro: 5)
               TaskItem(
                   title: "family_13_title",
                   description: "family_13_desc",
                   category: .family,
                   isPro: false // Risparmio immediato
               ),
               TaskItem(
                   title: "family_14_title",
                   description: "family_14_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_15_title",
                   description: "family_15_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_16_title",
                   description: "family_16_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_17_title",
                   description: "family_17_desc",
                   category: .family,
                   isPro: true // Attività strutturata
               ),
               TaskItem(
                   title: "family_18_title",
                   description: "family_18_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_19_title",
                   description: "family_19_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_20_title",
                   description: "family_20_desc",
                   category: .family,
                   isPro: true // Creatività
               ),
               TaskItem(
                   title: "family_21_title",
                   description: "family_21_desc",
                   category: .family,
                   isPro: true // Networking mamme
               ),
               TaskItem(
                   title: "family_22_title",
                   description: "family_22_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_23_title",
                   description: "family_23_desc",
                   category: .family,
                   isPro: true // Experience design
               ),
               TaskItem(
                   title: "family_24_title",
                   description: "family_24_desc",
                   category: .family,
                   isPro: true // Esplorazione locale
               ),
               TaskItem(
                   title: "family_25_title",
                   description: "family_25_desc",
                   category: .family,
                   isPro: false
               ),

               // MARK: - Gestione & Partner (Free: 7, Pro: 5)
               TaskItem(
                   title: "family_26_title",
                   description: "family_26_desc",
                   category: .family,
                   isPro: true // Relazione + Finanza
               ),
               TaskItem(
                   title: "family_27_title",
                   description: "family_27_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_28_title",
                   description: "family_28_desc",
                   category: .family,
                   isPro: true // Planning annuale
               ),
               TaskItem(
                   title: "family_29_title",
                   description: "family_29_desc",
                   category: .family,
                   isPro: true // Gestione parenti
               ),
               TaskItem(
                   title: "family_30_title",
                   description: "family_30_desc",
                   category: .family,
                   isPro: true // Tech saving
               ),
               TaskItem(
                   title: "family_31_title",
                   description: "family_31_desc",
                   category: .family,
                   isPro: false // Democrazia alimentare
               ),
               TaskItem(
                   title: "family_32_title",
                   description: "family_32_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_33_title",
                   description: "family_33_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_34_title",
                   description: "family_34_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_35_title",
                   description: "family_35_desc",
                   category: .family,
                   isPro: false // DIY regalo
               ),
               TaskItem(
                   title: "family_36_title",
                   description: "family_36_desc",
                   category: .family,
                   isPro: true // Skill tecnica
               ),
               TaskItem(
                   title: "family_37_title",
                   description: "family_37_desc",
                   category: .family,
                   isPro: false
               ),

               // MARK: - Futuro & Scuola (Free: 8, Pro: 5)
               TaskItem(
                   title: "family_38_title",
                   description: "family_38_desc",
                   category: .family,
                   isPro: false // Risparmio libri
               ),
               TaskItem(
                   title: "family_39_title",
                   description: "family_39_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_40_title",
                   description: "family_40_desc",
                   category: .family,
                   type: .counter,
                   targetCount: 5,
                   isPro: true // Meal prep scolastico
               ),
               TaskItem(
                   title: "family_41_title",
                   description: "family_41_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_42_title",
                   description: "family_42_desc",
                   category: .family,
                   isPro: true // Investimento futuro (Cruciale)
               ),
               TaskItem(
                   title: "family_43_title",
                   description: "family_43_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_44_title",
                   description: "family_44_desc",
                   category: .family,
                   isPro: true // Networking logistico
               ),
               TaskItem(
                   title: "family_45_title",
                   description: "family_45_desc",
                   category: .family,
                   isPro: false // Salute mentale
               ),
               TaskItem(
                   title: "family_46_title",
                   description: "family_46_desc",
                   category: .family,
                   isPro: false
               ),
               TaskItem(
                   title: "family_47_title",
                   description: "family_47_desc",
                   category: .family,
                   isPro: true // Budgeting avanzato
               ),
               TaskItem(
                   title: "family_48_title",
                   description: "family_48_desc",
                   category: .family,
                   isPro: true // Hack risparmio
               ),
               TaskItem(
                   title: "family_49_title",
                   description: "family_49_desc",
                   category: .family,
                   isPro: false // Risparmio festa
               ),
               TaskItem(
                   title: "family_50_title",
                   description: "family_50_desc",
                   category: .family,
                   isPro: false
               ),
    ]
    
    var allTasks: [TaskItem] {
            return rawTasks.enumerated().map { index, task in
                // Creiamo un ID fisso basato sul numero di riga (Index)
                // Es. il primo task sarà sempre ...0000100, il secondo ...0000101, ecc.
                let stableUUIDString = String(format: "%08d-0000-0000-0000-000000000000", index + 100)
                let stableID = UUID(uuidString: stableUUIDString)!
                
                // Ricostruiamo il task identico ma con l'ID fisso
                return TaskItem(
                    id: stableID,
                    title: task.title,
                    description: task.description,
                    category: task.category,
                    type: task.type,
                    targetCount: task.targetCount,
                    isPro: task.isPro
                )
            }
        }
    
    // Funzione per ottenere l'articolo 'Task' del giorno
    // (Per ora prende un articolo non letto random, logica più complessa sarà nel ProgressService)
    func getDailyReadingTask() -> TaskItem {
        return TaskItem(title: "Leggi l'articolo del giorno", description: "L'educazione è il primo passo per la libertà.", category: .education)
    }
    
    
    //
    //
    //
    //
    // MARK: - Database Articoli
    
    let allArticles: [Article] = [
            
            // MARK: - RISPARMIO (Savings) - Hook (Tutti aperti)
            Article(title: "sav_001_title", fileName: "sav_001", imageName: "sav_001", category: .savings, difficulty: .beginner, readTimeMinutes: 3),
            Article(title: "sav_002_title", fileName: "sav_002", imageName: "sav_002", category: .savings, difficulty: .beginner, readTimeMinutes: 2),
            Article(title: "sav_003_title", fileName: "sav_003", imageName: "sav_003", category: .savings, difficulty: .intermediate, readTimeMinutes: 2),
            Article(title: "sav_004_title", fileName: "sav_004", imageName: "sav_004", category: .savings, difficulty: .intermediate, readTimeMinutes: 3),
            Article(title: "sav_005_title", fileName: "sav_005", imageName: "sav_005", category: .savings, difficulty: .advanced, readTimeMinutes: 2),

            // MARK: - ECO-RISPARMIO (Eco) - Hook (Tutti aperti)
            Article(title: "eco_001_title", fileName: "eco_001", imageName: "eco_001", category: .eco, difficulty: .beginner, readTimeMinutes: 3),
            Article(title: "eco_002_title", fileName: "eco_002", imageName: "eco_002", category: .eco, difficulty: .beginner, readTimeMinutes: 2),
            Article(title: "eco_003_title", fileName: "eco_003", imageName: "eco_003", category: .eco, difficulty: .intermediate, readTimeMinutes: 3),
            Article(title: "eco_004_title", fileName: "eco_004", imageName: "eco_004", category: .eco, difficulty: .intermediate, readTimeMinutes: 3),
            Article(title: "eco_005_title", fileName: "eco_005", imageName: "eco_005", category: .eco, difficulty: .advanced, readTimeMinutes: 4),

            // MARK: - FAMILY & CASA (Family) - Misto (Avanzati PRO)
            Article(title: "fam_001_title", fileName: "fam_001", imageName: "fam_001", category: .family, difficulty: .beginner, readTimeMinutes: 2),
            Article(title: "fam_002_title", fileName: "fam_002", imageName: "fam_002", category: .family, difficulty: .beginner, readTimeMinutes: 2),
            Article(title: "fam_003_title", fileName: "fam_003", imageName: "fam_003", category: .family, difficulty: .intermediate, readTimeMinutes: 3),
            Article(title: "fam_004_title", fileName: "fam_004", imageName: "fam_004", category: .family, difficulty: .intermediate, readTimeMinutes: 3, isPro: true), // PRO
            Article(title: "fam_005_title", fileName: "fam_005", imageName: "fam_005", category: .family, difficulty: .advanced, readTimeMinutes: 4, isPro: true), // PRO

            // MARK: - BUDGETING (Budgeting) - Locked (Value)
            Article(title: "bud_001_title", fileName: "bud_001", imageName: "bud_001", category: .budgeting, difficulty: .beginner, readTimeMinutes: 5, isPro: true),
            Article(title: "bud_002_title", fileName: "bud_002", imageName: "bud_002", category: .budgeting, difficulty: .beginner, readTimeMinutes: 4, isPro: true),
            Article(title: "bud_003_title", fileName: "bud_003", imageName: "bud_003", category: .budgeting, difficulty: .intermediate, readTimeMinutes: 3, isPro: true),
            Article(title: "bud_004_title", fileName: "bud_004", imageName: "bud_004", category: .budgeting, difficulty: .intermediate, readTimeMinutes: 4, isPro: true),
            Article(title: "bud_005_title", fileName: "bud_005", imageName: "bud_005", category: .budgeting, difficulty: .advanced, readTimeMinutes: 5, isPro: true),

            // MARK: - INVESTIMENTI (Investing) - Locked (Value)
            Article(title: "inv_001_title", fileName: "inv_001", imageName: "inv_001", category: .investing, difficulty: .beginner, readTimeMinutes: 2, isPro: false),
            Article(title: "inv_002_title", fileName: "inv_002", imageName: "inv_002", category: .investing, difficulty: .beginner, readTimeMinutes: 2, isPro: true),
            Article(title: "inv_003_title", fileName: "inv_003", imageName: "inv_003", category: .investing, difficulty: .intermediate, readTimeMinutes: 3, isPro: true),
            Article(title: "inv_004_title", fileName: "inv_004", imageName: "inv_004", category: .investing, difficulty: .intermediate, readTimeMinutes: 3, isPro: true),
            Article(title: "inv_005_title", fileName: "inv_005", imageName: "inv_005", category: .investing, difficulty: .advanced, readTimeMinutes: 3, isPro: true)
        ]
    
    
    
   
}
