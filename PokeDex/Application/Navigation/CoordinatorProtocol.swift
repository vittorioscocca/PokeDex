//
//  CoordinatorProtocol.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import SwiftUI

/// Un protocollo che definisce un coordinator per la gestione della navigazione e delle viste in un'app SwiftUI.
///
/// Il coordinator è responsabile dell'avvio e dell'arresto dei processi di navigazione e fornisce
/// una vista presentabile da integrare nella gerarchia delle viste. Il protocollo è marcato con
/// `@MainActor` per garantire che tutte le operazioni vengano eseguite sul thread principale.
@MainActor
protocol CoordinatorProtocol: AnyObject {
    /// Avvia il coordinator.
    ///
    /// Questo metodo dovrebbe contenere la logica per inizializzare il coordinator e impostare il flusso di navigazione.
    func start()
    
    /// Arresta il coordinator.
    ///
    /// Questo metodo dovrebbe contenere la logica per interrompere il coordinator e liberare eventuali risorse.
    func stop()
    
    /// Restituisce una vista presentabile associata al coordinator.
    ///
    /// Utilizzato per integrare il coordinator nella gerarchia delle viste come una `AnyView`.
    ///
    /// - Returns: Una `AnyView` che rappresenta la vista presentabile.
    func toPresentable() -> AnyView
}

/// Estensione di `CoordinatorProtocol` che fornisce implementazioni di default per i metodi del protocollo.
///
/// Le implementazioni di default possono essere sovrascritte dalle classi che adottano il protocollo,
/// offrendo così la flessibilità di personalizzare il comportamento del coordinator.
extension CoordinatorProtocol {
    /// Implementazione di default per avviare il coordinator.
    ///
    /// Di default, questo metodo non esegue alcuna operazione.
    func start() { }
    
    /// Implementazione di default per arrestare il coordinator.
    ///
    /// Di default, questo metodo non esegue alcuna operazione.
    func stop() { }
    
    /// Implementazione di default per restituire una vista presentabile.
    ///
    /// Restituisce una `AnyView` contenente un semplice `Text` che segnala che la vista non è stata configurata.
    /// Questa implementazione di default può essere sovrascritta per fornire una vista personalizzata.
    ///
    /// - Returns: Una `AnyView` con il testo "View not configured".
    func toPresentable() -> AnyView {
        AnyView(Text("View not configured"))
    }
}
