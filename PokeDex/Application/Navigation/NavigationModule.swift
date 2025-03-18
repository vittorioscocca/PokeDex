//
//  NavigationModule.swift
//  PokeDex
//
//  Created by vscocca on 13/03/25.
//

import Foundation
import os.log

/// Un wrapper che incapsula un coordinator conforme a `CoordinatorProtocol` per la gestione dinamica della navigazione.
/// Questo componente consente di presentare schermate arbitrariamente, mantenendo un riferimento al coordinator sottostante.
///
/// La classe è identificabile (conformando a `Identifiable`) e hashabile (conformando a `Hashable`), in modo da poter essere utilizzata, ad esempio,
/// in una collection all'interno di uno stack di navigazione.
@MainActor
class NavigationModule: Identifiable, Hashable {
    /// Identificatore univoco per il modulo.
    let id = UUID()
    
    /// Il coordinator gestito, conformante a `CoordinatorProtocol`.
    var coordinator: (any CoordinatorProtocol)?
    
    /// Callback da eseguire al momento della rimozione del modulo.
    var dismissalCallback: (() -> Void)?
    
    /// Inizializza un nuovo modulo di navigazione.
    ///
    /// - Parameters:
    ///   - coordinator: Il coordinator da incapsulare.
    ///   - dismissalCallback: Callback opzionale da eseguire al momento della rimozione del modulo.
    init(_ coordinator: any CoordinatorProtocol, dismissalCallback: (() -> Void)? = nil) {
        self.coordinator = coordinator
        self.dismissalCallback = dismissalCallback
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "NavigationModule initialized with coordinator: \(coordinator)"))

    }
    
    /// Esegue il teardown del modulo:
    /// - Ferma il coordinator associato.
    /// - Rimuove il riferimento al coordinator.
    /// - Esegue il callback di dismiss, se presente.
    func tearDown() {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Tearing down NavigationModule: \(id)"))

        coordinator?.stop()
        coordinator = nil
        
        let callback = dismissalCallback
        dismissalCallback = nil
        if let callback = callback {
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Executing dismissal callback for NavigationModule: \(id)"))

            callback()
        }
    }
    
    // MARK: - Hashable & Equatable
    
    /// Confronta due istanze di NavigationModule basandosi sul loro id univoco.
    nonisolated static func == (lhs: NavigationModule, rhs: NavigationModule) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Calcola l'hash del modulo utilizzando il suo id.
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
