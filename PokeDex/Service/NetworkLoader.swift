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

/// Protocollo per l'invio di richieste HTTP tramite Combine.
///
/// Questo protocollo definisce un metodo generico per inviare una richiesta a un endpoint specificato,
/// restituendo un publisher che emette il risultato decodificato oppure un errore.
public protocol HTTPClientProtocol {
    /// Invia una richiesta per l'endpoint fornito.
    ///
    /// - Parameters:
    ///   - endpoint: L’endpoint che definisce la URLRequest, il parsing e la validazione della response.
    ///   - scheduler: Lo scheduler su cui ricevere e processare i dati.
    /// - Returns: Un publisher che emette il dato decodificato di tipo `A` oppure un errore di tipo `APIError`.
    func sendRequest<A, S: Scheduler>(for endpoint: Endpoint<A>, on scheduler: S) -> AnyPublisher<A, APIError> where A: Decodable
}

/// Enum che rappresenta gli errori generici della richiesta API.
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

/// Implementazione di `HTTPClientProtocol` che utilizza URLSession per inviare richieste HTTP.
///
/// La classe gestisce il flusso di dati tramite Combine, applicando trasformazioni e validazioni sulla response,
/// e utilizza `os.log` per il logging.
public class HTTPClient: HTTPClientProtocol {
    /// Istanza condivisa di HTTPClient, utilizzabile come singleton.
    public static let shared = HTTPClient()
    
    /// Invia una richiesta HTTP per l'endpoint specificato.
    ///
    /// - Parameters:
    ///   - endpoint: L'endpoint che definisce la URLRequest, il parsing e la validazione della response.
    ///   - scheduler: Lo scheduler su cui ricevere e processare i dati.
    /// - Returns: Un publisher che emette il risultato decodificato di tipo `A` oppure un errore di tipo `APIError`.
    public func sendRequest<A, S: Scheduler>(for endpoint: Endpoint<A>, on scheduler: S) -> AnyPublisher<A, APIError> where A: Decodable {
        let urlStr = endpoint.request.url?.absoluteString ?? "unknown"
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: urlStr, message: "Sending request to"))
        return URLSession.shared.dataTaskPublisher(for: endpoint.request)
            .map { ($0.data, $0.response) }
            .mapError { $0 as Error }
            .receive(on: scheduler)
            .tryMap { data, response in
                // Verifica che la response sia un HTTPURLResponse
                guard let httpResponse = response as? HTTPURLResponse else {
                    os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: urlStr, message: "No HTTPURLResponse for"))
                    throw APIError.requestFailed
                }
                // Controlla il codice di stato della response
                if !endpoint.expectedStatusCode(httpResponse.statusCode) {
                    if let errorMsg = try? JSONDecoder().decode(EmptyApiResponse.self, from: data).error {
                        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, formattedLogMessage(message: "Unexpected status code \(httpResponse.statusCode): \(errorMsg)"))
                    } else {
                        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, formattedLogMessage(message: "Unexpected status code \(httpResponse.statusCode) with no error message"))
                    }
                    throw APIError.requestFailed
                }
                // Effettua il parsing della response tramite l'endpoint
                return try endpoint.parse(data, response).get()
            }
            .mapError { err in
                os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, formattedLogMessage(message: "Mapping error: \(err)"))
                return APIError.requestFailed
            }
            .eraseToAnyPublisher()
    }
}
