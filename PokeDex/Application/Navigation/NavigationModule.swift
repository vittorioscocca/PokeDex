//
//  NavigationModule.swift
//  PokeDex
//
//  Created by vscocca on 13/03/25.
//

import Foundation

/// Un componente che funge da wrapper per un coordinatore e da "type eraser" per presentare dinamicamente schermate arbitrarie.
///
/// La classe `NavigationModule` permette di gestire la navigazione mantenendo una referenza opzionale al coordinatore,
/// così da poter liberare le risorse e interrompere il ciclo di navigazione al momento opportuno.
@MainActor
class NavigationModule: Identifiable, Hashable {
    
    /// Identificatore univoco per il modulo di navigazione.
    let id = UUID()
    
    /// Il coordinatore associato al modulo.
    ///
    /// Poiché lo `NavigationStack` tende a mantenere gli elementi del percorso più a lungo del necessario,
    /// si lavora rimuovendo manualmente il coordinatore quando il modulo viene dismesso.
    /// Questo è un valore opzionale perché il modulo agisce come wrapper e non è problematico che
    /// istanze multiple continuino a vivere una volta dismesse.
    var coordinator: (any CoordinatorProtocol)?
    
    /// Callback da eseguire al momento della dismissione del modulo.
    ///
    /// Questo closure, se definito, viene invocato quando il modulo viene "smontato" per permettere eventuali operazioni di cleanup.
    var dismissalCallback: (() -> Void)?
    
    /// Inizializza un nuovo `NavigationModule` con il coordinatore fornito.
    ///
    /// - Parameters:
    ///   - coordinator: Un'istanza che adotta `CoordinatorProtocol` da gestire.
    ///   - dismissalCallback: Un closure opzionale da eseguire quando il modulo viene dismesso.
    init(_ coordinator: any CoordinatorProtocol, dismissalCallback: (() -> Void)? = nil) {
        self.coordinator = coordinator
        self.dismissalCallback = dismissalCallback
    }
    
    /// Esegue il teardown del modulo.
    ///
    /// Questo metodo interrompe il coordinatore associato invocando il metodo `stop()`,
    /// rimuove il riferimento al coordinatore (impostandolo a `nil`) e poi esegue la callback di dismissione,
    /// se definita.
    func tearDown() {
        coordinator?.stop()
        coordinator = nil
        
        let callback = dismissalCallback
        dismissalCallback = nil
        callback?()
    }
    
    /// Confronta due istanze di `NavigationModule` basandosi sul loro identificatore univoco.
    ///
    /// - Parameters:
    ///   - lhs: Il primo `NavigationModule`.
    ///   - rhs: Il secondo `NavigationModule`.
    /// - Returns: `true` se gli identificatori sono uguali, altrimenti `false`.
    nonisolated static func == (lhs: NavigationModule, rhs: NavigationModule) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Calcola l'hash per l'istanza di `NavigationModule` utilizzando il suo identificatore.
    ///
    /// - Parameter hasher: L'oggetto `Hasher` utilizzato per combinare i valori hash.
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
