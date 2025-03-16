//
//  NavigationStackCoordinator.swift
//  PokeDex
//
//  Created by vscocca on 13/03/25.
//

import SwiftUI
import Combine
import os.log

/// Coordinator che gestisce una gerarchia di navigazione in stile "NavigationController".
///
/// La classe `NavigationStackCoordinator` è responsabile di:
/// - Gestire il coordinator radice e il suo aggiornamento (con log e teardown).
/// - Gestire la presentazione di moduli in sheet e fullscreen cover.
/// - Mantenere uno stack di moduli per la navigazione e gestire le operazioni di push e pop.
/// - Fornire una vista presentabile ( tramite il metodo `toPresentable()`) che incapsula l'intera gerarchia di navigazione.
///
/// La classe è conforme ai protocolli:
/// - `ObservableObject`: per poter essere osservata dalle view SwiftUI.
/// - `CoordinatorProtocol`: per esporre metodi di start/stop e una vista presentabile.
/// - `CustomStringConvertible`: per fornire una descrizione testuale utile al debugging.
@MainActor
class NavigationStackCoordinator: ObservableObject, CoordinatorProtocol, CustomStringConvertible {
    
    // MARK: - Proprietà di Navigazione
    
    /// Modulo radice della navigazione.
    ///
    /// Quando viene aggiornato, esegue il teardown del modulo precedente (se esistente) e avvia il nuovo coordinator.
    @Published var rootModule: NavigationModule? {
        didSet {
            if let oldValue {
                self.logPresentationChange("Remove root", oldValue)
                oldValue.tearDown()
            }
            
            if let rootModule {
                self.logPresentationChange("Set root", rootModule)
                rootModule.coordinator?.start()
            }
        }
    }
    
    /// Il coordinator associato al modulo radice.
    var rootCoordinator: (any CoordinatorProtocol)? {
        self.rootModule?.coordinator
    }
    
    /// Modulo per la presentazione di uno sheet.
    ///
    /// Quando viene aggiornato, esegue il teardown del modulo precedente e avvia il nuovo coordinator.
    @Published var sheetModule: NavigationModule? {
        didSet {
            if let oldValue {
                self.logPresentationChange("Remove sheet", oldValue)
                oldValue.tearDown()
            }
            
            if let sheetModule {
                self.logPresentationChange("Set sheet", sheetModule)
                sheetModule.coordinator?.start()
            }
        }
    }
    
    /// Set dei detents per la presentazione dello sheet.
    var presentationDetents: Set<PresentationDetent> = []
    
    /// Il coordinator associato al modulo sheet corrente.
    var sheetCoordinator: (any CoordinatorProtocol)? {
        self.sheetModule?.coordinator
    }
    
    /// Modulo per la presentazione a schermo intero (fullscreen cover).
    ///
    /// Quando viene aggiornato, esegue il teardown del modulo precedente e avvia il nuovo coordinator.
    @Published var fullScreenCoverModule: NavigationModule? {
        didSet {
            if let oldValue {
                self.logPresentationChange("Remove fullscreen cover", oldValue)
                oldValue.tearDown()
            }
            
            if let fullScreenCoverModule {
                self.logPresentationChange("Set fullscreen cover", fullScreenCoverModule)
                fullScreenCoverModule.coordinator?.start()
            }
        }
    }
    
    /// Il coordinator associato al modulo di fullscreen cover corrente.
    var fullScreenCoverCoordinator: (any CoordinatorProtocol)? {
        self.fullScreenCoverModule?.coordinator
    }
    
    /// Stack dei moduli della navigazione.
    ///
    /// I cambiamenti in questo array vengono monitorati per gestire operazioni di push e pop con animazione.
    @Published var stackModules = [NavigationModule]() {
        didSet {
            let diffs = self.stackModules.difference(from: oldValue)
            diffs.forEach { change in
                switch change {
                case .insert(_, let module, _):
                    self.logPresentationChange("Push", module)
                    module.coordinator?.start()
                case .remove(_, let module, _):
                    self.logPresentationChange("Pop", module)
                    module.tearDown()
                }
            }
        }
    }
    
    /// I coordinatori correnti presenti nello stack (escludendo il coordinator radice).
    var stackCoordinators: [any CoordinatorProtocol] {
        self.stackModules.compactMap(\.coordinator)
    }
    
    // MARK: - Inizializzazione
    
    /// Inizializza un nuovo `NavigationStackCoordinator`.
    ///
    /// L'inizializzatore non richiede parametri in quanto le proprietà verranno impostate successivamente
    /// attraverso i metodi di navigazione (setRootCoordinator, push, ecc.).
    init() { }
    
    // MARK: - Metodi di Navigazione
    
    /// Imposta il coordinator radice per la navigazione.
    ///
    /// Questo metodo rimuove il coordinator corrente (se presente) e imposta il nuovo coordinator come radice.
    /// Viene eseguito un popToRoot prima di impostare il nuovo coordinator per garantire che lo stack sia vuoto.
    ///
    /// - Parameters:
    ///   - coordinator: Il coordinator da impostare come radice.
    ///   - animated: Indica se animare la transizione (default: `true`).
    ///   - dismissalCallback: Closure opzionale chiamata quando il coordinator radice viene rimosso o sostituito.
    func setRootCoordinator(_ coordinator: (any CoordinatorProtocol)?, animated: Bool = true, dismissalCallback: (() -> Void)? = nil) {
        guard let coordinator else {
            self.rootModule = nil
            return
        }
        
        if self.rootModule?.coordinator === coordinator {
            fatalError("Cannot use the same coordinator more than once")
        }
        
        self.popToRoot(animated: false)
        
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        withTransaction(transaction) {
            self.rootModule = NavigationModule(coordinator, dismissalCallback: dismissalCallback)
        }
    }
    
    /// Aggiunge (push) un nuovo coordinator nello stack di navigazione.
    ///
    /// - Parameters:
    ///   - coordinator: Il coordinator da aggiungere.
    ///   - animated: Indica se animare la transizione (default: `true`).
    ///   - dismissalCallback: Closure opzionale chiamata quando il coordinator viene rimosso (pop), in modo programmato o meno.
    func push(_ coordinator: any CoordinatorProtocol, animated: Bool = true, dismissalCallback: (() -> Void)? = nil) {
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        withTransaction(transaction) {
            self.stackModules.append(NavigationModule(coordinator, dismissalCallback: dismissalCallback))
        }
    }
    
    /// Rimuove tutti i coordinatori dallo stack, ritornando al coordinator radice.
    ///
    /// - Parameter animated: Indica se animare la transizione (default: `true`).
    func popToRoot(animated: Bool = true) {
        guard !stackModules.isEmpty else {
            return
        }
        
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        withTransaction(transaction) {
            self.stackModules.removeAll()
        }
    }
    
    /// Rimuove l'ultimo coordinator aggiunto dallo stack.
    ///
    /// - Parameter animated: Indica se animare la transizione (default: `true`).
    func pop(animated: Bool = true) {
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        withTransaction(transaction) {
            _ = self.stackModules.popLast()
        }
    }
    
    /// Imposta il coordinator per la presentazione in modalità sheet.
    ///
    /// Se il parametro `coordinator` è `nil`, rimuove il coordinator sheet attuale.
    ///
    /// - Parameters:
    ///   - coordinator: Il coordinator da presentare come sheet.
    ///   - animated: Indica se animare la transizione (default: `true`).
    ///   - dismissalCallback: Closure opzionale chiamata quando lo sheet viene dismesso.
    func setSheetCoordinator(_ coordinator: (any CoordinatorProtocol)?, animated: Bool = true, dismissalCallback: (() -> Void)? = nil) {
        guard let coordinator else {
            self.sheetModule = nil
            return
        }
        
        if self.sheetModule?.coordinator === coordinator {
            fatalError("Cannot use the same coordinator more than once")
        }
        
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        withTransaction(transaction) {
            self.sheetModule = NavigationModule(coordinator, dismissalCallback: dismissalCallback)
        }
    }
    
    /// Imposta il coordinator per la presentazione a schermo intero (fullscreen cover).
    ///
    /// Se il parametro `coordinator` è `nil`, rimuove il coordinator fullscreen cover attuale.
    ///
    /// - Parameters:
    ///   - coordinator: Il coordinator da presentare in fullscreen cover.
    ///   - animated: Indica se animare la transizione (default: `true`).
    ///   - dismissalCallback: Closure opzionale chiamata quando il fullscreen cover viene dismesso.
    func setFullScreenCoverCoordinator(_ coordinator: (any CoordinatorProtocol)?, animated: Bool = true, dismissalCallback: (() -> Void)? = nil) {
        guard let coordinator else {
            self.fullScreenCoverModule = nil
            return
        }
        
        if self.fullScreenCoverModule?.coordinator === coordinator {
            fatalError("Cannot use the same coordinator more than once")
        }
        
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        withTransaction(transaction) {
            self.fullScreenCoverModule = NavigationModule(coordinator, dismissalCallback: dismissalCallback)
        }
    }
    
    // MARK: - CoordinatorProtocol
    
    /// Restituisce una vista presentabile che incapsula l'intera gerarchia di navigazione.
    ///
    /// Utilizza una view dedicata che integra:
    /// - Uno `NavigationStack` per la navigazione basata su stack.
    /// - La presentazione di sheet e fullscreen cover, se configurati.
    ///
    /// - Returns: Una `AnyView` contenente la gerarchia di navigazione.
    func toPresentable() -> AnyView {
        AnyView(
            NavigationStackCoordinatorView(navigationStackCoordinator: self)
                .presentationDetents(presentationDetents)
        )
    }
    
    /// Ferma tutti i coordinatori gestiti dal modulo, interrompendo e rimuovendo il coordinator radice, sheet, fullscreen cover e tutti gli elementi dello stack.
    func stop() {
        self.rootModule?.tearDown()
        self.sheetModule?.tearDown()
        self.fullScreenCoverModule?.tearDown()
        
        self.stackModules.forEach { module in
            module.tearDown()
        }
    }
    
    // MARK: - CustomStringConvertible
    
    /// Restituisce una rappresentazione testuale del coordinator.
    ///
    /// Se esiste un coordinator radice, restituisce la sua descrizione; altrimenti indica che la gerarchia è vuota.
    nonisolated var description: String {
        // Se non è indispensabile accedere allo stato isolato, puoi restituire una stringa statica
        "NavigationStackCoordinator(Dettagli non disponibili fuori dal main actor)"
    }
    
    // MARK: - Funzioni Private
    
    /// Registra le variazioni di presentazione di un modulo, come push o pop, per il debug.
    ///
    /// - Parameters:
    ///   - change: Una stringa che descrive il cambiamento (ad es., "Set root", "Push", "Pop").
    ///   - module: Il modulo che ha subito il cambiamento.
    private func logPresentationChange(_ change: String, _ module: NavigationModule) {
        guard let coordinator = module.coordinator else { return }
        os_log("%{PUBLIC}@: %{PUBLIC}@", log: OSLog.appLogger, type: .debug, String(describing: self), "\(change): \(coordinator)")
    }
}

// MARK: - View di Supporto per la Presentazione della Navigazione

/// Una view privata che incapsula la presentazione della gerarchia di navigazione gestita da `NavigationStackCoordinator`.
///
/// La view utilizza:
/// - Uno `NavigationStack` per visualizzare la vista del coordinator radice e per navigare attraverso lo stack.
/// - Presentazioni di sheet e fullscreen cover, se configurate, basandosi sui binding associati ai moduli.
private struct NavigationStackCoordinatorView: View {
    @ObservedObject var navigationStackCoordinator: NavigationStackCoordinator
    
    var body: some View {
        NavigationStack(path: self.$navigationStackCoordinator.stackModules) {
            self.navigationStackCoordinator.rootModule?.coordinator?.toPresentable()
                .navigationDestination(for: NavigationModule.self) { module in
                    module.coordinator?.toPresentable()
                }
        }
        .sheet(item: self.$navigationStackCoordinator.sheetModule) { module in
            module.coordinator?.toPresentable()
        }
        .fullScreenCover(item: self.$navigationStackCoordinator.fullScreenCoverModule) { module in
            module.coordinator?.toPresentable()
        }
    }
}
