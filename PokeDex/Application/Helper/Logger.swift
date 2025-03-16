//
//  Logger.swift
//  PokeDex
//
//  Created by vscocca on 14/03/25.
//

import os.log
import Foundation

// MARK: - Estensione di OSLog

/// Estende `OSLog` per configurare un logger specifico per l'applicazione.
///
/// Questa estensione definisce un logger chiamato `appLogger` che utilizza il bundle identifier
/// dell'app come subsystem. Se il bundle identifier non è disponibile, viene usato un valore di fallback.
/// Il logger viene configurato con la categoria "app" per distinguere i log generati dalla logica dell'app.
extension OSLog {
    /// Il subsystem utilizzato per il logger, basato sul bundle identifier dell'app.
    private static var subsystem = Bundle.main.bundleIdentifier ?? "com.vittorioscocca.pokedex.PokeDex"
    
    /// Logger specifico dell'app, configurato con il subsystem e la categoria "app".
    static let appLogger = OSLog(subsystem: subsystem, category: "app")
}

// MARK: - Funzione di Formattazione dei Log

/// Crea un messaggio di log formattato in maniera strutturata.
///
/// La funzione raccoglie informazioni quali timestamp ISO8601, nome del file (senza estensione),
/// nome della funzione, process identifier (pid) e altri campi fittizi (ip, correlationId, reqId) per creare
/// un messaggio di log uniforme e facilmente leggibile durante il debug.
///
/// - Parameters:
///   - endpoint: (Opzionale) Una stringa che rappresenta l'endpoint o l'URL a cui è riferito il log.
///               Se fornita e non vuota, verrà inclusa nel messaggio di log.
///   - message: Il messaggio di log da visualizzare.
///   - function: Il nome della funzione da cui viene chiamato il log. Valore di default impostato tramite `#function`.
///   - file: Il percorso del file da cui viene chiamato il log. Valore di default impostato tramite `#file`.
/// - Returns: Una stringa formattata contenente tutte le informazioni utili per il log.
func formattedLogMessage(endpoint: String? = nil,
                         message: String,
                         function: String = #function,
                         file: String = #file) -> String {
    // Ottiene il timestamp corrente in formato ISO8601.
    let isoTimestamp = ISO8601DateFormatter().string(from: Date())
    // Estrae il nome del file (ultimo componente del percorso) e rimuove l'estensione .swift.
    let fileName = URL(fileURLWithPath: file).lastPathComponent
    let classInstance = fileName.replacingOccurrences(of: ".swift", with: "")
    // Usa la funzione come nome del metodo.
    let method = function
    // Ottiene l'identificatore del processo.
    let pid = ProcessInfo.processInfo.processIdentifier
    
    // Se l'endpoint è fornito e non vuoto, lo include nel messaggio.
    if let endpoint = endpoint, !endpoint.isEmpty {
        return "[\(isoTimestamp)]-[\(classInstance)]-[\(method)]-[\(endpoint)]-[\(pid)]: \(message)"
    } else {
        // Altrimenti, restituisce il messaggio senza l'endpoint.
        return "[\(isoTimestamp)]-[\(classInstance)]-[\(method)]-[\(pid)]: \(message)"
    }
}
