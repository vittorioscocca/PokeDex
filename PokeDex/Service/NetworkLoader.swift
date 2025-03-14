//
//  NetworkLoader.swift
//  PokeDex
//
//  Created by vscocca on 10/03/25.
//

import Foundation
import Combine
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import os.log

// MARK: - Protocollo HTTPClientProtocol

/// Protocollo per l'invio di richieste HTTP.
///
/// Definisce un metodo generico per inviare una richiesta a un endpoint e ottenere, tramite Combine,
/// il dato decodificato di tipo `A` oppure un errore di tipo `APIError`.
public protocol HTTPClientProtocol {
    /// Invia una richiesta per l'endpoint passato e restituisce un publisher che emette il DTO decodificato.
    ///
    /// - Parameters:
    ///   - endpoint: L’endpoint che definisce la `URLRequest`, il parsing e la validazione della response.
    ///   - scheduler: Lo scheduler su cui ricevere e processare i dati.
    /// - Returns: Un publisher che emette il dato di tipo `A` oppure un errore di tipo `APIError`.
    func sendRequest<A, S: Scheduler>(for endpoint: Endpoint<A>, on scheduler: S) -> AnyPublisher<A, APIError> where A: Decodable
}

// MARK: - Classe HTTPClient

/// Implementazione di `HTTPClientProtocol` che utilizza URLSession per inviare richieste HTTP.
///
/// Gestisce il flusso di dati tramite Combine, applicando trasformazioni e validazioni sulla response,
/// e utilizza `os.log` per il logging dettagliato di ogni fase del processo.
public class HTTPClient: HTTPClientProtocol {
    public static let shared = HTTPClient()
    
    public func sendRequest<A, S: Scheduler>(for endpoint: Endpoint<A>, on scheduler: S) -> AnyPublisher<A, APIError> where A: Decodable {
        // Estrae l'URL per i log; se non disponibile, usa "unknown".
        let urlStr = endpoint.request.url?.absoluteString ?? "unknown"
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: urlStr, message: "Sending request"))
        
        return URLSession.shared.dataTaskPublisher(for: endpoint.request)
            .map { (data: $0.data, response: $0.response) }
            .mapError { $0 as Error }
            .receive(on: scheduler)
            .tryMap { data, response in
                // Verifica che la response sia un HTTPURLResponse.
                guard let httpResponse = response as? HTTPURLResponse else {
                    let errorMsg = formattedLogMessage(endpoint: urlStr, message: "No HTTPURLResponse received")
                    os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, errorMsg)
                    throw APIError.requestFailed
                }
                // Controlla il codice di stato della response.
                if !endpoint.expectedStatusCode(httpResponse.statusCode) {
                    let errorMsg: String
                    // Prova a decodificare un messaggio di errore dalla response.
                    if let errorResponse = try? JSONDecoder().decode(EmptyApiResponse.self, from: data).error {
                        errorMsg = formattedLogMessage(endpoint: urlStr, message: "Unexpected status code \(httpResponse.statusCode). Error response: \(errorResponse)")
                        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, errorMsg)
                        throw APIError.requestFailed
                    } else {
                        errorMsg = formattedLogMessage(endpoint: urlStr, message: "Unexpected status code \(httpResponse.statusCode) and no error response")
                        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, errorMsg)
                        throw APIError.requestFailed
                    }
                }
                let successMsg = formattedLogMessage(endpoint: urlStr, message: "Received HTTP status code \(httpResponse.statusCode)")
                os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, successMsg)
                return try endpoint.parse(data, response).get()
            }
            .mapError { err in
                let errorMsg = formattedLogMessage(endpoint: urlStr, message: "Mapping error: \(err)")
                os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, errorMsg)
                return APIError.requestFailed
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - APIError e EmptyApiResponse

/// Enum che rappresenta un errore generico per la richiesta API.
public enum APIError: Error {
    /// Errore generico per richieste fallite.
    case requestFailed
}

/// Struttura per decodificare una response vuota contenente un messaggio di errore.
///
/// Utilizzata per estrarre il messaggio di errore quando la response non contiene dati utili.
public struct EmptyApiResponse: Decodable {
    /// Il messaggio di errore restituito dall'API.
    let error: String
}
