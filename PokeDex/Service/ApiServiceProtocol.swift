//
//  ApiServiceProtocol.swift
//  PokeDex
//
//  Created by vscocca on 10/03/25.
//

import Foundation
import Combine

// MARK: - API PROTOCOL

/// Protocollo che definisce il servizio per effettuare chiamate alla PokeAPI.
///
/// Questo protocollo espone metodi per ottenere sia l’elenco dei Pokémon che i dettagli di un singolo Pokémon,
/// offrendo due modalità di esecuzione: tramite Combine (basata su publisher) e tramite async/await.
/// L’implementazione di questo protocollo consente di astrarre la logica di rete, facilitando il testing e la manutenzione.
protocol ApiServiceProtocol {
    
    // MARK: - Recupero della Lista dei Pokémon
    
    /// Recupera la lista dei Pokémon dalla PokeAPI.
    ///
    /// Il metodo effettua una richiesta all'endpoint della PokeAPI per ottenere un elenco di Pokémon.
    ///
    /// - Parameter url: Un URL opzionale che specifica l'endpoint da cui recuperare i dati.
    ///   Se il parametro è `nil`, viene utilizzato un URL predefinito (ad es. `Endpoints.baseURL`).
    /// - Returns: Un publisher (`AnyPublisher<PokemonListResponse, APIError>`) che emette un oggetto `PokemonListResponse`
    ///   contenente i dati della lista dei Pokémon oppure un errore di tipo `APIError` in caso di fallimento.
    func fetchPokemonList(from url: URL?) -> AnyPublisher<PokemonListResponse, APIError>
    
    /// Recupera la lista dei Pokémon dalla PokeAPI in modalità asincrona.
    ///
    /// Questo metodo utilizza il paradigma async/await per restituire il risultato della richiesta.
    ///
    /// - Parameter url: Un URL opzionale che specifica l'endpoint da cui recuperare i dati.
    ///   Se il parametro è `nil`, viene utilizzato un URL predefinito.
    /// - Returns: Un valore di tipo `Result<PokemonListResponse, APIError>` che contiene un oggetto `PokemonListResponse`
    ///   in caso di successo oppure un errore di tipo `APIError` in caso di fallimento.
    func fetchPokemonListAsync(from url: URL?) async -> Result<PokemonListResponse, APIError>
    
    
    // MARK: - Recupero dei Dettagli del Pokémon
    
    /// Recupera i dettagli di un Pokémon specifico dalla PokeAPI.
    ///
    /// Il metodo effettua una richiesta all'endpoint fornito tramite l'URL per ottenere i dettagli di un Pokémon.
    ///
    /// - Parameter url: L'URL che punta all'endpoint dei dettagli del Pokémon.
    /// - Returns: Un publisher (`AnyPublisher<PokemonDetailResponse, APIError>`) che emette un oggetto `PokemonDetailResponse`
    ///   contenente i dettagli del Pokémon oppure un errore di tipo `APIError` in caso di fallimento.
    func fetchPokemonDetail(from url: URL) -> AnyPublisher<PokemonDetailResponse, APIError>
    
    /// Recupera in modalità asincrona i dettagli di un Pokémon specifico dalla PokeAPI.
    ///
    /// Utilizza il paradigma async/await per gestire la richiesta e restituire il risultato.
    ///
    /// - Parameter url: L'URL che punta all'endpoint per i dettagli del Pokémon.
    /// - Returns: Un valore di tipo `Result<PokemonDetailResponse, APIError>` che contiene un oggetto `PokemonDetailResponse`
    ///   in caso di successo oppure un errore di tipo `APIError` in caso di fallimento.
    func fetchPokemonDetailAsync(from url: URL) async -> Result<PokemonDetailResponse, APIError>
}
