//
//  PokeDexApp.swift
//  PokeDex
//
//  Created by vscocca on 10/03/25.
//

import SwiftUI
import os.log

/// L'entry point principale dell'applicazione PokeDex.
///
/// La struct `PokeDexApp` conforma al protocollo `App` di SwiftUI e definisce l'intera gerarchia di view dell'app.
/// Utilizza un `AppCoordinator` come oggetto di stato per gestire la navigazione e la logica di presentazione dell'app.
@main
struct PokeDexApp: App {
    
    /// Oggetto coordinator responsabile della navigazione e della gestione delle view dell'app.
    ///
    /// Viene creato come `@StateObject` per assicurare che il suo ciclo di vita sia gestito da SwiftUI.
    @StateObject private var appCoordinator = AppCoordinator()
    
    /// Inizializzatore della app.
    ///
    /// Viene eseguito al lancio dell'app e utilizza `os_log` per registrare un messaggio di debug formattato,
    /// indicando che l'applicazione è stata avviata.
    init() {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "PokeDexApp launched"))
    }
    
    /// Definisce la scena principale dell'app.
    ///
    /// La proprietà `body` restituisce una `Scene` che contiene un `WindowGroup` dove viene visualizzata la vista
    /// presentabile fornita dall'`appCoordinator`. Inoltre, vengono registrati dei log per eventi quali l'apparizione
    /// della view principale e la ricezione di notifiche di avviso di memoria.
    var body: some Scene {
        WindowGroup {
            // Presenta la view principale ottenuta dal coordinator.
            appCoordinator.toPresentable()
                .onAppear {
                    // Log di debug quando la view principale appare.
                    os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "AppCoordinator view appeared"))
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                    // Log di errore in caso di ricezione di un avviso di memoria.
                    os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, formattedLogMessage(message: "Memory warning received"))
                }
        }
    }
}

