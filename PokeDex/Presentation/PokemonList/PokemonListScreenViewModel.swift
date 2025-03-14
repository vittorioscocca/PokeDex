//
//  PokemonListScreenViewModel.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//
import Combine
import SwiftUI
import os.log

/// Alias per il ViewModel della schermata della lista dei Pokémon.
/// Si basa su `StateStoreViewModel` utilizzando lo stato definito in `PokemonListScreenViewState`
/// e le azioni definite in `PokemonListScreenViewAction`.
typealias PokemonListScreenViewModelType = StateStoreViewModel<PokemonListScreenViewState, PokemonListScreenViewAction>

/// Protocollo che definisce l'interfaccia del ViewModel per la schermata della lista dei Pokémon.
///
/// Espone:
/// - Un publisher per le azioni (`actions`) che il ViewModel emette.
/// - Un contesto (`context`) per il binding bidirezionale dello stato.
@MainActor
protocol PokemonListScreenViewModelProtocol {
    /// Publisher che emette le azioni del ViewModel di tipo `PokemonListScreenViewModelAction`.
    var actions: AnyPublisher<PokemonListScreenViewModelAction, Never> { get }
    /// Il contesto del ViewModel, contenente lo stato e le funzioni di binding per l'interfaccia.
    var context: PokemonListScreenViewModelType.Context { get }
}

/// ViewModel per la schermata della lista dei Pokémon.
///
/// La classe gestisce:
/// - Il fetching della lista dei Pokémon tramite il servizio API.
/// - L'elaborazione delle azioni provenienti dalla view (ad esempio, mostrare dettagli di un Pokémon o caricare la pagina successiva).
/// - L'aggiornamento dello stato bindabile della schermata.
/// - La gestione degli errori derivanti dalle chiamate API.
@MainActor
class PokemonListScreenViewModel: PokemonListScreenViewModelType,
                                  PokemonListScreenViewModelProtocol {
    
    // MARK: - Proprietà Private
    
    /// Soggetto Combine per trasmettere le azioni emesse dal ViewModel.
    private var actionsSubject: PassthroughSubject<PokemonListScreenViewModelAction, Never> = .init()
    
    /// Servizio API utilizzato per effettuare le chiamate alla PokeAPI.
    private let apiService: APIService
    
    // MARK: - Proprietà Pubbliche
    
    /// Publisher che espone in modalità read-only le azioni emesse dal ViewModel.
    var actions: AnyPublisher<PokemonListScreenViewModelAction, Never> {
        self.actionsSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Inizializzazione
    
    /// Inizializza il ViewModel per la schermata della lista dei Pokémon.
    ///
    /// - Parameter apiService: Il servizio API da utilizzare per effettuare le chiamate. Il valore di default è una nuova istanza di `APIService`.
    ///
    /// L'inizializzazione crea uno stato iniziale con binding vuoti (lista vuota, nessun URL per next/previous) e avvia
    /// immediatamente il fetch della lista dei Pokémon.
    init(apiService: APIService = APIService()) {
        self.apiService = apiService
        
        let bindings = PokemonListScreennViewStateBindings(count: nil,
                                                           pokemonList: [],
                                                           next: nil,
                                                           previous: nil)
        
        super.init(initialViewState: PokemonListScreenViewState(bindings: bindings))
        
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Initialized. Starting to fetch pokemon list."))
        fetchPokemonList()
    }
    
    // MARK: - Processo delle Azioni della View
    
    /// Elabora le azioni inviate dalla view.
    ///
    /// - Parameter viewAction: L'azione della view da processare.
    ///
    /// Le azioni gestite includono:
    /// - `showPokemonDetails`: invia un'azione per mostrare i dettagli del Pokémon selezionato.
    /// - `loadNextPage`: invoca il caricamento della pagina successiva della lista.
    override func process(viewAction: PokemonListScreenViewAction) {
        switch viewAction {
        case .showPokemonDetails(let pokemon):
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Processing action: showPokemonDetails for pokemon: \(pokemon.name)"))
            self.actionsSubject.send(.didShowPokemonDetails(pokemon: pokemon))
        case .loadNextPage:
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Processing action: loadNextPage"))
            loadNextPage()
        }
    }
    
    // MARK: - Metodi Privati
    
    /// Effettua una chiamata API per ottenere la lista dei Pokémon.
    ///
    /// - Parameter url: (Opzionale) Una stringa contenente l'URL da cui effettuare il fetch. Se `nil`,
    /// viene utilizzato l'URL di base definito in `Endpoints`.
    ///
    /// La funzione aggiorna lo stato della view:
    /// - Aggiunge i Pokémon ottenuti alla lista.
    /// - Aggiorna il conteggio totale, il link alla pagina successiva e quella precedente.
    /// - In caso di errore, gestisce l'errore tramite `handleError(_:)`.
    private func fetchPokemonList(url: String? = nil) {
        Task {
            let endpoint = url ?? Endpoints.baseURL.absoluteString
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: endpoint, message: "Fetching pokemon list."))
            
            guard let url = URL(string: endpoint) else {
                os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, formattedLogMessage(endpoint: endpoint, message: "Invalid URL."))
                return
            }
            
            switch await self.apiService.fetchPokemonListAsync(from: url) {
            case .success(let response):
                guard let results = response.results else {
                    os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, formattedLogMessage(endpoint: endpoint, message: "Response succeeded but 'results' is nil."))
                    self.handleError(.requestFailed)
                    return
                }
                os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: endpoint, message: "Successfully fetched pokemon list. Count: \(String(describing: response.count)), next: \(String(describing: response.next)), previous: \(String(describing: response.previous))."))
                
                self.state.bindings.pokemonList.append(contentsOf: results)
                self.state.bindings.count = response.count
                self.state.bindings.next = response.next
                self.state.bindings.previous = response.previous
            case .failure(let error):
                os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, formattedLogMessage(endpoint: endpoint, message: "Error fetching pokemon list: \(error)"))
                self.handleError(error)
            }
        }
    }
    
    /// Carica la pagina successiva della lista dei Pokémon.
    ///
    /// Se lo stato contiene un URL per la pagina successiva, invoca il metodo `fetchPokemonList(url:)`
    /// con tale URL. In caso contrario, registra un log che indica che non è disponibile una pagina successiva.
    func loadNextPage() {
        if let nextURL = self.state.bindings.next {
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: nextURL, message: "Loading next page."))
            fetchPokemonList(url: nextURL)
        } else {
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "No next URL available to load next page."))
        }
    }
    
    /// Gestisce un errore derivante da una chiamata API.
    ///
    /// - Parameter errorCode: L'errore di tipo `APIError` ricevuto dalla chiamata.
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
