//
//  PokeDexUITestsLaunchTests.swift
//  PokeDexUITests
//
//  Created by vscocca on 10/03/25.
//

import XCTest

/// Test suite per verificare il lancio dell'applicazione PokeDex.
///
/// La classe `PokeDexUITestsLaunchTests` contiene test specifici per la configurazione dell'interfaccia utente
/// all'avvio dell'app, garantendo che l'app venga lanciata correttamente e allegando uno screenshot della schermata di lancio.
final class PokeDexUITestsLaunchTests: XCTestCase {
    
    /// Indica se il test deve essere eseguito per ogni configurazione dell'applicazione UI target.
    ///
    /// Restituisce `true` per garantire che ogni configurazione dell'interfaccia venga testata.
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    
    /// Configurazione iniziale eseguita prima dell'esecuzione di ogni test.
    ///
    /// Imposta `continueAfterFailure` a `false` per interrompere immediatamente il test in caso di errore.
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    /// Test principale per verificare il lancio dell'applicazione.
    ///
    /// Il test:
    /// - Avvia l'applicazione.
    /// - (Opzionale) Esegue eventuali passaggi post-lancio, come login o navigazione in specifiche aree dell'app.
    /// - Cattura uno screenshot della schermata di lancio e lo allega al report dei test.
    ///
    /// - Throws: Un errore se il test fallisce.
    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Inserisci eventuali passaggi da eseguire dopo il lancio dell'app,
        // ad esempio effettuare il login o navigare in una specifica area dell'app
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
