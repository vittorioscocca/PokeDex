//
//  StateStoreViewModel.swift
//  PokeDex
//
//  Created by vscocca on 13/03/25.
//

import Combine
import Foundation

/// Implementazione comune di un ViewModel per la gestione dello `State` e delle `ViewAction`.
///
/// Il tipo generico `State` è vincolato al protocollo `BindableState`, in modo tale da poter
/// eventualmente contenere una porzione di stato che può essere in modo sicuro legato alle view tramite binding bidirezionale.
/// Questo ViewModel centralizza la logica di gestione dello stato, offrendo la possibilità di aggiungere in futuro ulteriori funzionalità
/// (come il processamento dello stato fuori dal main thread) senza dover modificare l'intera architettura.
@MainActor
class StateStoreViewModel<State: BindableState, ViewAction> {
    
    // MARK: - Proprietà di Base
    
    /// Insieme per conservare le referenze alle sottoscrizioni di Combine.
    ///
    /// Questa proprietà viene lasciata pubblica per facilitare l'implementazione nelle sottoclassi del ViewModel.
    var cancellables = Set<AnyCancellable>()
    
    /// Interfaccia ristretta che viene passata alle view per interagire con il ViewModel.
    ///
    /// La classe `Context` fornisce:
    /// - La possibilità di leggere e osservare lo stato della view.
    /// - La possibilità di inviare eventi (ViewAction) al ViewModel.
    /// - Un binding sicuro per porzioni specifiche dello stato.
    var context: Context
    
    /// Stato corrente del ViewModel.
    ///
    /// La proprietà `state` incapsula lo stato della view e permette di accedervi in modo leggibile e modificabile.
    var state: State {
        get { self.context.viewState }
        set { self.context.viewState = newValue }
    }
    
    // MARK: - Inizializzazione
    
    /// Inizializza il ViewModel con lo stato iniziale.
    ///
    /// - Parameter initialViewState: Lo stato iniziale da assegnare alla view.
    init(initialViewState: State) {
        self.context = Context(initialViewState: initialViewState)
        self.context.viewModel = self
    }
    
    // MARK: - Gestione delle Azioni della View
    
    /// Elabora le `ViewAction` inviate dalla view.
    ///
    /// Il metodo va sovrascritto dalle sottoclassi per gestire in modo specifico le azioni inviate dalla view.
    ///
    /// - Parameter viewAction: L'azione della view da processare.
    func process(viewAction: ViewAction) {
        // Implementazione di default: non fa nulla (no-op).
    }
    
    // MARK: - Context
    
    /// Un'interfaccia ristretta e concisa per interagire con il ViewModel.
    ///
    /// La classe `Context` è fortemente legata a `StateStoreViewModel` e fornisce l'interfaccia esatta
    /// che la view necessita per interagire con il ViewModel. Questa interfaccia include:
    /// - La possibilità di leggere/osservare lo stato della view tramite una proprietà `@Published`.
    /// - La possibilità di inviare eventi alla view.
    /// - La possibilità di legare (bind) in maniera sicura porzioni specifiche dello stato.
    ///
    /// Questo design evita l'uso diretto di property wrapper (come `@Published`) nelle interfacce dei protocolli,
    /// fornendo un livello di astrazione che migliora la consistenza e la sicurezza nell'interazione tra view e ViewModel.
    @dynamicMemberLookup
    @MainActor
    final class Context: ObservableObject {
        
        /// Riferimento debole al ViewModel proprietario, per evitare cicli di retain.
        fileprivate weak var viewModel: StateStoreViewModel?
        
        /// Proprietà osservabile che contiene lo stato della view.
        ///
        /// La proprietà è di sola lettura per le view, mentre il ViewModel può modificarla internamente.
        @Published fileprivate(set) var viewState: State
        
        /// Sottoscrizione dinamica per accedere in maniera bindabile a porzioni specifiche dello stato.
        ///
        /// Utilizzando il key path, è possibile leggere o aggiornare direttamente una porzione del `BindStateType`
        /// definito in `BindableState`.
        subscript<T>(dynamicMember keyPath: WritableKeyPath<State.BindStateType, T>) -> T {
            get { self.viewState.bindings[keyPath: keyPath] }
            set { self.viewState.bindings[keyPath: keyPath] = newValue }
        }
        
        /// Invia una `ViewAction` al ViewModel per il relativo processamento.
        ///
        /// - Parameter viewAction: L'azione della view da inviare al ViewModel.
        func send(viewAction: ViewAction) {
            viewModel?.process(viewAction: viewAction)
        }
        
        /// Inizializza il contesto con lo stato iniziale.
        ///
        /// - Parameter initialViewState: Lo stato iniziale da assegnare a `viewState`.
        fileprivate init(initialViewState: State) {
            self.viewState = initialViewState
        }
    }
}
