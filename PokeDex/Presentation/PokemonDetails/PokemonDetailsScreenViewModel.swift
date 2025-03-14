//
//  PokemonDetailsScreenViewModel.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import Foundation
import Combine
import os.log

/// Alias per il tipo generico di ViewModel specifico per la schermata dei dettagli del Pokémon,
/// basato su `StateStoreViewModel` con stato definito da `PokemonDetailsScreenViewState` e azioni da `PokemonDetailsScreenViewAction`.
typealias PokemonDetailsScreenViewModelType = StateStoreViewModel<PokemonDetailsScreenViewState, PokemonDetailsScreenViewAction>

/// Protocollo che definisce l'interfaccia del ViewModel per la schermata dei dettagli del Pokémon.
///
/// Esso espone un publisher per le azioni (`actions`) e un contesto (`context`) per il binding dello stato.
@MainActor
protocol PokemonDetailsScreenViewModelProtocol {
    /// Publisher che emette le azioni del ViewModel di tipo `PokemonDetailsScreenViewModelAction`.
    var actions: AnyPublisher<PokemonDetailsScreenViewModelAction, Never> { get }
    /// Il contesto del ViewModel, che fornisce l'interfaccia per leggere e modificare lo stato.
    var context: PokemonDetailsScreenViewModelType.Context { get }
}

/// ViewModel responsabile della gestione della logica per la schermata dei dettagli del Pokémon.
///
/// Questa classe eredita da `StateStoreViewModel` per gestire lo stato e le azioni della view,
/// e implementa il protocollo `PokemonDetailsScreenViewModelProtocol`.
/// Si occupa di inizializzare lo stato con i dati basilari del Pokémon, eseguire la chiamata API
/// per ottenere i dettagli completi e gestire le azioni provenienti dalla view.
@MainActor
class PokemonDetailsScreenViewModel: PokemonDetailsScreenViewModelType,
                                     PokemonDetailsScreenViewModelProtocol {
    /// Soggetto Combine utilizzato per trasmettere le azioni del ViewModel.
    private var actionsSubject: PassthroughSubject<PokemonDetailsScreenViewModelAction, Never> = .init()
    
    /// Publisher che espone le azioni del ViewModel in modalità "read-only".
    var actions: AnyPublisher<PokemonDetailsScreenViewModelAction, Never> {
        self.actionsSubject.eraseToAnyPublisher()
    }
    
    /// Servizio API utilizzato per effettuare le chiamate alla PokeAPI.
    private var apiService: APIService
    
    /// Inizializza il ViewModel con un oggetto `PokemonListItem` e configura lo stato iniziale.
    ///
    /// - Parameters:
    ///   - pokemon: Un oggetto `PokemonListItem` contenente i dati basilari del Pokémon (nome, URL immagine, URL dei dettagli, ecc.).
    ///   - apiService: Il servizio API da utilizzare per ottenere i dettagli del Pokémon. Di default viene usata una nuova istanza di `APIService`.
    ///
    /// L'inizializzatore crea lo stato iniziale della schermata e avvia automaticamente il fetching dei dettagli.
    init(pokemon: PokemonListItem, apiService: APIService = APIService()) {
        self.apiService = apiService
        
        let initialState = PokemonDetailsScreenViewState(
            bindings: PokemonDetailsScreenViewStateBindings(
                name: pokemon.name,
                imageURL: pokemon.imageURL,
                height: 0,
                weight: 0,
                abilities: [],
                moves: []
            )
        )
        
        super.init(initialViewState: initialState)
        
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Initialized PokemonDetailsScreenViewModel for pokemon: \(pokemon.name)"))
        fetchPokemonDetails(for: pokemon.url)
    }
    
    /// Effettua una chiamata API per ottenere i dettagli del Pokémon.
    ///
    /// - Parameter url: La stringa che rappresenta l'URL dei dettagli del Pokémon.
    ///
    /// Se l'URL non è valido, viene loggato un errore e l'operazione viene interrotta.
    /// In caso di successo, lo stato della view viene aggiornato con i dettagli ottenuti.
    private func fetchPokemonDetails(for url: String) {
        guard let detailURL = URL(string: url) else {
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, formattedLogMessage(message: "Invalid URL: \(url)"))
            return
        }
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: detailURL.absoluteString, message: "Fetching pokemon details."))
        Task {
            switch await self.apiService.fetchPokemonDetailAsync(from: detailURL) {
            case .success(let response):
                os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: detailURL.absoluteString, message: "Successfully fetched details. Height: \(response.height), Weight: \(response.weight)"))
                self.state.bindings.height = response.height
                self.state.bindings.weight = response.weight
                self.state.bindings.abilities = response.abilities.map { $0.ability.name }
                self.state.bindings.moves = response.moves.map { $0.move.name }
            case .failure(let error):
                os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, formattedLogMessage(endpoint: detailURL.absoluteString, message: "Error fetching details: \(error)"))
                self.handleError(error)
            }
        }
    }
    
    /// Elabora le azioni inviate dalla view.
    ///
    /// - Parameter viewAction: L'azione della view da processare.
    ///
    /// Le azioni supportate sono:
    /// - `toggleAbilities`: Alterna la visualizzazione delle abilità.
    /// - `toggleMoves`: Alterna la visualizzazione delle mosse.
    override func process(viewAction: PokemonDetailsScreenViewAction) {
        switch viewAction {
        case .toggleAbilities:
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Toggling abilities display."))
            self.state.bindings.showAbilities.toggle()
        case .toggleMoves:
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Toggling moves display."))
            self.state.bindings.showMoves.toggle()
        }
    }
    
    /// Gestisce un errore derivante dalla chiamata API.
    ///
    /// - Parameter errorCode: L'errore di tipo `APIError` ottenuto dalla chiamata.
    ///
    /// Il metodo logga l'errore e aggiorna lo stato della view impostando un alert generico.
    private func handleError(_ errorCode: APIError) {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, formattedLogMessage(message: "Handling error: \(errorCode)"))
        switch errorCode {
        default:
            self.state.bindings.alertInfo = AlertInfo(id: .alert)
        }
    }
}
