//
//  PokeDexUITests.swift
//  PokeDexUITests
//
//  Created by vscocca on 10/03/25.
//

import XCTest

/// Test suite per l'interfaccia utente (UI) dell'applicazione PokeDex.
///
/// Questa classe contiene diversi casi d'uso per verificare che:
/// - La schermata della lista dei Pokémon venga caricata correttamente.
/// - La navigazione dalla lista alla schermata dei dettagli funzioni come previsto.
/// - Un alert venga visualizzato in caso di errore.
final class PokeDexUITests: XCTestCase {
    
    // MARK: - Setup
    
    /// Esegue la configurazione iniziale prima dell'esecuzione di ciascun test.
    ///
    /// In questo caso, viene impostato `continueAfterFailure` a `false` per interrompere il test al primo fallimento.
    override func setUp() {
        continueAfterFailure = false
    }
    
    // MARK: - Casi d'Uso UI Tests
    
    /// Caso d'uso 1: Verifica che la schermata della lista dei Pokémon venga caricata correttamente.
    ///
    /// Il test:
    /// - Avvia l'applicazione con un flag di test (launchEnvironment).
    /// - Attende che la navigation bar con titolo "Pokedex" sia presente.
    /// - Verifica che la table view (lista) esista.
    /// - Controlla che almeno una cella della lista sia visualizzata.
    func testListScreenLoads() {
        let app = XCUIApplication()
        // Imposta il flag di test nell'ambiente di lancio.
        app.launchEnvironment["UITest"] = "true"
        app.launch()
        
        // Attende che la navigation bar con titolo "Pokedex" esista.
        let navBar = app.navigationBars["Pokedex"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 10), "La navigation bar non è presente")
        
        // Verifica che la lista (table view) sia presente.
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10), "La lista non è presente")
        
        // Verifica che almeno una cella della lista esista.
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "Nessuna cella trovata nella lista")
    }
    
    /// Caso d'uso 2: Verifica la navigazione dalla schermata della lista alla schermata dei dettagli del Pokémon.
    ///
    /// Il test:
    /// - Avvia l'applicazione in modalità test.
    /// - Attende la presenza della lista dei Pokémon.
    /// - Simula un tap sulla prima cella della lista.
    /// - Attende che venga presentata la schermata dei dettagli, identificata da un elemento con l'accessibility identifier "pokemonDetailName".
    func testNavigationToDetail() {
        let app = XCUIApplication()
        app.launchEnvironment["UITest"] = "true"
        app.launch()
        
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10), "La lista non è presente")
        
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "La cella della lista non è presente")
        
        // Simula il tap sulla cella per navigare alla schermata dei dettagli.
        firstCell.tap()
        
        // Attende che la schermata dei dettagli venga presentata: l'elemento con accessibility identifier "pokemonDetailName" deve esistere.
        let detailLabel = app.staticTexts["pokemonDetailName"]
        XCTAssertTrue(detailLabel.waitForExistence(timeout: 10), "La schermata dei dettagli non è stata presentata")
    }
    
    /// Caso d'uso 3: Verifica che un alert venga visualizzato in caso di errore durante l'interazione con l'API.
    ///
    /// Il test:
    /// - Configura l'ambiente di lancio per simulare un errore nell'API impostando la variabile di ambiente "SIMULATE_ERROR".
    /// - Avvia l'applicazione in modalità test.
    /// - Attende che un alert venga visualizzato.
    /// - Verifica che il bottone "OK" sia presente nell'alert e simula un tap per chiuderlo.
    func testErrorAlertDisplayed() {
        let app = XCUIApplication()
        // Imposta la variabile di ambiente per simulare un errore nell'API.
        app.launchEnvironment["SIMULATE_ERROR"] = "1"
        app.launchEnvironment["UITest"] = "true"
        app.launch()
        
        // Attende che venga mostrato un alert.
        let errorAlert = app.alerts.firstMatch
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 10), "L'alert d'errore non è stato visualizzato")
        
        // Verifica che il bottone "OK" sia presente nell'alert e simula il tap per chiuderlo.
        let okButton = errorAlert.buttons["OK"]
        XCTAssertTrue(okButton.waitForExistence(timeout: 5), "Il bottone OK non è presente nell'alert")
        okButton.tap()
    }
}
