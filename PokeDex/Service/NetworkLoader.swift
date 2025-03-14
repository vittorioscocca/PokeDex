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

public protocol HTTPClientProtocol {
    /// Invia una richiesta per l'endpoint passato e restituisce un publisher che emette il DTO decodificato.
    /// - Parameters:
    ///   - endpoint: L’endpoint che definisce la URLRequest, il parsing e la validazione della response.
    ///   - scheduler: Lo scheduler su cui ricevere i dati.
    /// - Returns: Un publisher che emette il dato di tipo A o un errore di tipo APIError.
    func sendRequest<A, S: Scheduler>(for endpoint: Endpoint<A>, on scheduler: S) -> AnyPublisher<A, APIError> where A: Decodable
}

// MARK: - Classe HTTPClient

public class HTTPClient: HTTPClientProtocol {
    public static let shared = HTTPClient()
    
    public func sendRequest<A, S: Scheduler>(for endpoint: Endpoint<A>, on scheduler: S) -> AnyPublisher<A, APIError> where A: Decodable {
        // Estrae l'URL per i log
        let urlStr = endpoint.request.url?.absoluteString ?? "unknown"
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: urlStr, message: "Sending request"))
        
        return URLSession.shared.dataTaskPublisher(for: endpoint.request)
            .map { (data: $0.data, response: $0.response) }
            .mapError { $0 as Error }
            .receive(on: scheduler)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    let errorMsg = formattedLogMessage(endpoint: urlStr, message: "No HTTPURLResponse received")
                    os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, errorMsg)
                    throw APIError.requestFailed
                }
                if !endpoint.expectedStatusCode(httpResponse.statusCode) {
                    let errorMsg: String
                    if let errorResponse = try? JSONDecoder().decode(EmptyApiResponse.self, from: data).error {
                        errorMsg = formattedLogMessage(endpoint: urlStr, message: "Unexpected status code \(httpResponse.statusCode). Error response: \(errorResponse)")
                        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, errorMsg)
                        throw APIError.customApiError(errorResponse)
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
                return APIError.normalError(err)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - APIError e EmptyApiResponse

public enum APIError: Error {
    case requestFailed
    case customApiError(String)
    case normalError(Error)
}

public struct EmptyApiResponse: Decodable {
    let error: String
}
