//
//  PokeDexUITests.swift
//  PokeDexUITests
//
//  Created by vscocca on 10/03/25.
//

import XCTest

/// Test per verificare il corretto caricamento della schermata della lista dei Pokémon.
///
/// Questa classe contiene diversi casi d'uso per verificare che:
/// - La schermata della lista dei Pokémon venga caricata correttamente.
/// - La navigazione dalla lista alla schermata dei dettagli funzioni come previsto.
/// - Un alert venga visualizzato in caso di errore.
final class PokeDexUITests: XCTestCase {
    
    // MARK: - Setup
    
    /// Configurazione iniziale eseguita prima di ogni test.
    ///
    /// Imposta `continueAfterFailure` a `false` per interrompere il test al primo fallimento.
    override func setUp() {
        continueAfterFailure = false
    }
    
    // MARK: - Casi d'Uso UI Tests
    
    /// Caso d'uso 1: Verifica che la schermata della lista dei Pokémon venga caricata correttamente.
    ///
    /// Il test:
    /// - Avvia l'applicazione in modalità test impostando il flag "UITest" nell'ambiente.
    /// - Attende che la navigation bar con il titolo "Pokedex" sia presente.
    /// - Verifica che la List sia presente, utilizzando l'accessibility identifier "pokemonList".
    /// - Verifica che almeno una cella della List, identificata come "pokemonListCell", sia presente.
    func testListScreenLoads() {
        let app = XCUIApplication()
        // Imposta il flag di test nell'ambiente di lancio.
        app.launchEnvironment["UITest"] = "true"
        app.launch()
        
        // Verifica che la navigation bar con titolo "Pokedex" esista.
        let navBar = app.navigationBars["Pokedex"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 10), "La navigation bar non è presente")
        
        // Verifica che la List sia presente (usa l'accessibility identifier impostato sulla List).
        let list = app.descendants(matching: .any).matching(identifier: "pokemonList").firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 10), "La lista non è presente")
        
        // Verifica che almeno una cella della List sia presente.
        // Se le celle non hanno l'accessibility identifier "pokemonListCell", il test fallirà.
        let firstCell = app.descendants(matching: .any).matching(identifier: "pokemonListCell").firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "Nessuna cella trovata nella lista")
    }
    
    /// Caso d'uso 2: Verifica la navigazione dalla schermata della lista alla schermata dei dettagli del Pokémon.
    /// Verifica che la schermata dei dettagli del Pokémon visualizzi le informazioni relative ad altezza e peso.
    ///
    /// Il test:
    /// - Avvia l'app in modalità test.
    /// - Attende la presenza della List e della prima cella.
    /// - Simula un tap sulla cella.
    /// - Attende che la schermata dei dettagli venga presentata controllando che un elemento
    ///   con l'accessibility identifier "pokemonDetailName" esista.
    func testNavigationToDetail() {
        let app = XCUIApplication()
        app.launchEnvironment["UITest"] = "true"
        app.launch()
        
        // Verifica la presenza della List.
        let list = app.descendants(matching: .any).matching(identifier: "pokemonList").firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 10), "La lista non è presente")
        
        // Verifica la presenza della cella nella List.
        let firstCell = app.descendants(matching: .any).matching(identifier: "pokemonListCell").firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "Nessuna cella trovata nella lista")
        
        // Simula il tap sulla cella per avviare la navigazione alla schermata dei dettagli.
        firstCell.tap()
        
        // Verifica che la schermata dei dettagli presenti il campo "Altezza:".
        let heightLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'Altezza:'")).firstMatch
        XCTAssertTrue(heightLabel.waitForExistence(timeout: 10), "La schermata dei dettagli non presenta il campo 'Altezza'")
        
        // Verifica che la schermata dei dettagli presenti il campo "Peso:".
        let weightLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'Peso:'")).firstMatch
        XCTAssertTrue(weightLabel.waitForExistence(timeout: 10), "La schermata dei dettagli non presenta il campo 'Peso'")
        
        // Verifica che la schermata dei dettagli presenti il campo "Abilità" come Button.
        let abilitiesButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Abilità'")).firstMatch
        XCTAssertTrue(abilitiesButton.waitForExistence(timeout: 10), "La schermata dei dettagli non presenta il campo 'Abilità' come Button")
        
        // Verifica che la schermata dei dettagli presenti il campo "Mosse" come Button.
        let movesButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Mosse'")).firstMatch
        XCTAssertTrue(movesButton.waitForExistence(timeout: 10), "La schermata dei dettagli non presenta il campo 'Mosse' come Button")
    }
    
    /// Caso d'uso 3: Verifica che venga visualizzato un alert in caso di errore durante l'interazione con l'API.
    ///
    /// Il test:
    /// - Imposta la variabile di ambiente per simulare un errore nell'API ("SIMULATE_ERROR").
    /// - Avvia l'applicazione in modalità test.
    /// - Attende che un alert venga visualizzato.
    /// - Verifica che il bottone "OK" sia presente nell'alert e simula un tap per chiuderlo.
    func testErrorAlertDisplayed() {
        let app = XCUIApplication()
        app.launchEnvironment["SIMULATE_ERROR"] = "1"
        app.launchEnvironment["UITest"] = "true"
        app.launch()
        
        // Prova a cercare l'alert utilizzando l'accessibility identifier "Errore" (se impostato nella view).
        let errorAlertTitle = app.descendants(matching: .any).matching(identifier: "Attenzione").firstMatch
        XCTAssertTrue(errorAlertTitle.waitForExistence(timeout: 15), "L'alert d'errore non è stato visualizzato")
        
        // Verifica che il bottone "OK" sia presente nell'alert e simula un tap per chiuderlo.
        let okButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'OK'")).firstMatch
        XCTAssertTrue(okButton.waitForExistence(timeout: 5), "Il bottone OK non è presente nell'alert")
        okButton.tap()
    }
}
