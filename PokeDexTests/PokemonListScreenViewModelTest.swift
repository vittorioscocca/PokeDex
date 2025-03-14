//
//  PokeDexTests.swift
//  PokeDexTests
//
//  Created by vscocca on 10/03/25.
//

import Testing
@testable import PokeDex
import Combine
import Foundation
import XCTest

// MARK: - Stub per simulare APIService

/// Stub per simulare le chiamate a `APIService` nei test della schermata della lista dei Pokémon.
///
/// `APIServiceStub` eredita da `APIService` e permette di controllare il comportamento delle chiamate API
/// configurando il flag `shouldReturnError` e fornendo una risposta di test tramite `testResponse`.
class APIServiceStub: APIService {
    /// Se impostato a true, le chiamate API restituiranno un errore.
    var shouldReturnError = false
    /// La risposta di test da restituire in caso di successo per il fetch della lista dei Pokémon.
    var testResponse: PokemonListResponse?
    
    /// Simula il fetch asincrono della lista dei Pokémon.
    ///
    /// - Parameter url: Un URL opzionale da cui effettuare il fetch; se non fornito, viene utilizzato l'URL di base.
    /// - Returns: Un `Result` contenente una `PokemonListResponse` in caso di successo, oppure un `APIError` in caso di fallimento.
    override func fetchPokemonListAsync(from url: URL? = nil) async -> Result<PokemonListResponse, APIError> {
        if shouldReturnError {
            return .failure(.requestFailed)
        } else {
            if let response = testResponse {
                return .success(response)
            } else {
                return .success(PokemonListResponse(count: 1, next: nil, previous: nil, results: []))
            }
        }
    }
    
    /// Metodo non utilizzato in questi test.
    override func fetchPokemonList(from url: URL? = nil) -> AnyPublisher<PokemonListResponse, APIError> {
        fatalError("Non usato in questi test")
    }
    
    /// Metodo non utilizzato in questi test.
    override func fetchPokemonDetailAsync(from url: URL) async -> Result<PokemonDetailResponse, APIError> {
        fatalError("Non usato in questi test")
    }
    
    /// Metodo non utilizzato in questi test.
    override func fetchPokemonDetail(from url: URL) -> AnyPublisher<PokemonDetailResponse, APIError> {
        fatalError("Non usato in questi test")
    }
}

// MARK: - Test per PokemonListScreenViewModel

/// Test suite per verificare il comportamento del ViewModel della schermata della lista dei Pokémon.
struct PokeDexTests {
    
    /// Verifica che, in caso di risposta positiva, lo stato venga aggiornato correttamente.
    ///
    /// Il test configura lo stub per restituire una risposta positiva contenente un `PokemonListItem` e controlla che:
    /// - Il conteggio (`count`) venga aggiornato a 1.
    /// - La lista dei Pokémon (`pokemonList`) contenga il `PokemonListItem` di test.
    /// - Le proprietà `next` e `previous` siano nil.
    /// - Non venga impostato alcun alert.
    @Test func testPokemonListScreenViewModelSuccess() async throws {
        let stub = APIServiceStub()
        let testItem = PokemonListItem(name: "pikachu",
                                       url: "https://pokeapi.co/api/v2/pokemon/25")
        let response = PokemonListResponse(count: 1,
                                           next: nil,
                                           previous: nil,
                                           results: [testItem])
        stub.testResponse = response
        stub.shouldReturnError = false
        
        let viewModel = await PokemonListScreenViewModel(apiService: stub)
        
        // Attende per consentire il completamento dell'aggiornamento asincrono dello state.
        try await Task.sleep(nanoseconds: 500_000_000)
        
        await #expect(viewModel.state.bindings.count == 1)
        await #expect(viewModel.state.bindings.pokemonList == [testItem])
        await #expect(viewModel.state.bindings.next == nil)
        await #expect(viewModel.state.bindings.previous == nil)
        await #expect(viewModel.state.bindings.alertInfo == nil)
    }
    
    /// Verifica che, in caso di errore durante il fetch, venga impostato un alert nello stato.
    ///
    /// Il test configura lo stub per restituire un errore e controlla che:
    /// - Il dettaglio della lista dei Pokémon non venga aggiornato (rimanga nil).
    /// - Venga impostato un alert in `alertInfo`.
    @Test func testPokemonListScreenViewModelFailure() async throws {
        let stub = APIServiceStub()
        stub.shouldReturnError = true
        
        let viewModel = await PokemonListScreenViewModel(apiService: stub)
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        await #expect(viewModel.state.bindings.alertInfo != nil)
    }
}
