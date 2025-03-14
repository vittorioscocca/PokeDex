//
//  Untitled.swift
//  PokeDex
//
//  Created by vscocca on 13/03/25.
//

import Testing
@testable import PokeDex
import Combine
import Foundation

// MARK: - Stub per simulare le chiamate per il dettaglio

/// Stub per simulare le chiamate API nella schermata dei dettagli dei Pokémon.
///
/// `APIServiceDetailsStub` eredita da `APIService` e permette di controllare il comportamento delle chiamate API,
/// restituendo una risposta di successo o fallendo in base al valore di `shouldReturnError`.
class APIServiceDetailsStub: APIService {
    /// Se impostato a true, la chiamata API restituirà un errore.
    var shouldReturnError = false
    /// La risposta di test da restituire in caso di successo.
    var testDetailResponse: PokemonDetailResponse?
    
    /// Simula il fetch asincrono dei dettagli del Pokémon.
    ///
    /// - Parameter url: L'URL da cui ottenere i dettagli.
    /// - Returns: Un `Result` che contiene una `PokemonDetailResponse` in caso di successo, oppure un `APIError` in caso di fallimento.
    override func fetchPokemonDetailAsync(from url: URL) async -> Result<PokemonDetailResponse, APIError> {
        if shouldReturnError {
            return .failure(.requestFailed)
        } else {
            if let response = testDetailResponse {
                return .success(response)
            } else {
                // Risposta di default se non impostata nello stub
                let defaultResponse = PokemonDetailResponse(
                    id: 1,
                    name: "pikachu",
                    height: 4,
                    weight: 60,
                    abilities: [],
                    moves: [],
                    sprites: PokemonSprites(front_default: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png")
                )
                return .success(defaultResponse)
            }
        }
    }
    
    override func fetchPokemonListAsync(from url: URL? = nil) async -> Result<PokemonListResponse, APIError> {
        fatalError("Non usato in questo test")
    }
    
    override func fetchPokemonList(from url: URL? = nil) -> AnyPublisher<PokemonListResponse, APIError> {
        fatalError("Non usato in questo test")
    }
    
    override func fetchPokemonDetail(from url: URL) -> AnyPublisher<PokemonDetailResponse, APIError> {
        fatalError("Non usato in questo test")
    }
}

// MARK: - Strutture ipotetiche per il dettaglio (da definire nel modulo PokeDex)

// State per il dettaglio, conforme a BindableState
struct PokemonDetailsScreenViewState: BindableState {
    var bindings: PokemonDetailsBindings
}

// Bindings per il dettaglio, che contiene il dettaglio vero e proprio e un eventuale alert
struct PokemonDetailsBindings {
    var detail: PokemonDetailResponse?
    var alertInfo: AlertInfo<PokemonDetailsScreenAlertType>?
}

// Tipologia di alert per la schermata dettagli
enum PokemonDetailsScreenAlertType {
    case alert
}

// Azioni per il view model dei dettagli (eventualmente espandibili)
enum PokemonDetailsScreenViewAction {
    case fetchDetail
}

// Il view model per il dettaglio dei Pokémon.
// Si assume che, al momento dell'inizializzazione, venga lanciata una chiamata API per ottenere il dettaglio.
class PokemonDetailsScreenViewModel: StateStoreViewModel<PokemonDetailsScreenViewState, PokemonDetailsScreenViewAction> {
    private let apiService: APIService
    private let pokemonDetailUrl: URL
    
    init(apiService: APIService, pokemonDetailUrl: URL) {
        self.apiService = apiService
        self.pokemonDetailUrl = pokemonDetailUrl
        let bindings = PokemonDetailsBindings(detail: nil, alertInfo: nil)
        super.init(initialViewState: PokemonDetailsScreenViewState(bindings: bindings))
        fetchDetail()
    }
    
    /// Effettua una chiamata API per ottenere i dettagli del Pokémon.
    ///
    /// Utilizza il metodo asincrono `fetchPokemonDetailAsync` del servizio API e aggiorna lo stato:
    /// - In caso di successo, aggiorna il dettaglio.
    /// - In caso di fallimento, imposta un alert.
    func fetchDetail() {
        Task {
            let result = await apiService.fetchPokemonDetailAsync(from: pokemonDetailUrl)
            switch result {
            case .success(let detail):
                self.state.bindings.detail = detail
            case .failure:
                self.state.bindings.alertInfo = AlertInfo(id: .alert)
            }
        }
    }
    
    override func process(viewAction: PokemonDetailsScreenViewAction) {
        // Al momento non gestiamo ulteriori azioni.
    }
}

// MARK: - Test per PokemonDetailsScreenViewModel

/// Test suite per il ViewModel della schermata dei dettagli del Pokémon.
///
/// Questi test verificano il corretto aggiornamento dello stato in caso di risposta API di successo o di fallimento.
struct PokeDexDetailsTests {
    
    /// Verifica il comportamento del ViewModel in caso di fetch dei dettagli di successo.
    ///
    /// Lo stub è configurato per restituire una risposta positiva con i dettagli di un Pokémon.
    /// Il test attende il completamento del Task interno e poi verifica che:
    /// - Il dettaglio ottenuto abbia l'id corretto (25).
    /// - Il nome del Pokémon sia "pikachu".
    /// - Nessun alert sia stato impostato.
    @Test func testPokemonDetailsScreenViewModelSuccess() async throws {
        // Configuriamo lo stub per una risposta positiva
        let stub = APIServiceDetailsStub()
        let detailResponse = PokemonDetailResponse(
            id: 25,
            name: "pikachu",
            height: 4,
            weight: 60,
            abilities: [PokemonAbility(ability: NamedAPIResource(name: "static", url: "url1"), is_hidden: false, slot: 1)],
            moves: [PokemonMove(move: NamedAPIResource(name: "thunder-shock", url: "url2"))],
            sprites: PokemonSprites(front_default: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png")
        )
        stub.testDetailResponse = detailResponse
        stub.shouldReturnError = false
        
        let detailURL = URL(string: "https://pokeapi.co/api/v2/pokemon/25")!
        let viewModel = await PokemonDetailsScreenViewModel(apiService: stub, pokemonDetailUrl: detailURL)
        
        // Attende per permettere al Task interno di completare l'aggiornamento dello state.
        try await Task.sleep(nanoseconds: 500_000_000)
        
        await #expect(viewModel.state.bindings.detail?.id == 25)
        await #expect(viewModel.state.bindings.detail?.name == "pikachu")
        await #expect(viewModel.state.bindings.alertInfo == nil)
    }
    
    /// Verifica il comportamento del ViewModel in caso di fetch dei dettagli fallito.
    ///
    /// Lo stub è configurato per restituire un errore.
    /// Il test attende il completamento del Task interno e poi verifica che:
    /// - Il dettaglio rimanga nil.
    /// - Un alert sia stato impostato nello stato.
    @Test func testPokemonDetailsScreenViewModelFailure() async throws {
        let stub = APIServiceDetailsStub()
        stub.shouldReturnError = true
        
        let detailURL = URL(string: "https://pokeapi.co/api/v2/pokemon/25")!
        let viewModel = await PokemonDetailsScreenViewModel(apiService: stub, pokemonDetailUrl: detailURL)
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        await #expect(viewModel.state.bindings.detail == nil)
        await #expect(viewModel.state.bindings.alertInfo != nil)
    }
}
