//
//  ApiServiceProtocol.swift
//  PokeDex
//
//  Created by vscocca on 10/03/25.
//

import Foundation
import Combine
// MARK: - API PROTOCOL
/// Servizio per effettuare le chiamate alla PokeAPI.
protocol ApiServiceProtocol {
    /// Recupera la lista dei Pokémon dalla API.
    /// - Returns: Un oggetto `PokemonListResponse` contenente i Pokémon.
    func fetchPokemonList(from url: URL?) -> AnyPublisher<PokemonListResponse, APIError>
    func fetchPokemonListAsync(from url: URL?) async -> Result<PokemonListResponse, APIError>
    
    /// Recupera i dettagli di un Pokémon dato il suo URL.
    /// - Parameters:
    ///   - url: URL dei dettagli del Pokémon.
    /// - Returns: Un oggetto `PokemonDetail` contenente i dettagli.
    func fetchPokemonDetail(from url: URL) -> AnyPublisher<PokemonDetailResponse, APIError>
    func fetchPokemonDetailAsync(from url: URL) async -> Result<PokemonDetailResponse, APIError>
}
