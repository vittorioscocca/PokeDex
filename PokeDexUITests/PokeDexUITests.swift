//
//  PokeDexUITests.swift
//  PokeDexUITests
//
//  Created by vscocca on 10/03/25.
//

import XCTest

final class PokeDexUITests: XCTestCase {
    
    override func setUp() {
        continueAfterFailure = false
    }
    
    // Caso d'uso 1: Verifica che la schermata della lista venga caricata correttamente
    func testListScreenLoads() {
        let app = XCUIApplication()
        // Aggiungiamo un flag per i test, se necessario
        app.launchEnvironment["UITest"] = "true"
        app.launch()
        
        // Attende che la navigation bar con titolo "Pokedex" esista
        let navBar = app.navigationBars["Pokedex"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 10), "La navigation bar non è presente")
        
        // Verifica che la lista (table view) sia presente
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10), "La lista non è presente")
        
        // Verifica che almeno una cella della lista esista
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "Nessuna cella trovata nella lista")
    }
    
    // Caso d'uso 2: Navigazione dalla lista alla schermata dei dettagli
    func testNavigationToDetail() {
        let app = XCUIApplication()
        app.launchEnvironment["UITest"] = "true"
        app.launch()
        
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10), "La lista non è presente")
        
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "La cella della lista non è presente")
        
        // Simula il tap sulla cella per navigare ai dettagli
        firstCell.tap()
        
        // Attende che la schermata dei dettagli venga presentata: l'elemento con accessibility identifier "pokemonDetailName"
        let detailLabel = app.staticTexts["pokemonDetailName"]
        XCTAssertTrue(detailLabel.waitForExistence(timeout: 10), "La schermata dei dettagli non è stata presentata")
    }
    
    // Caso d'uso 3: Visualizzazione di un alert in caso di errore
    func testErrorAlertDisplayed() {
        let app = XCUIApplication()
        // Imposta la variabile di ambiente per simulare un errore nell'API
        app.launchEnvironment["SIMULATE_ERROR"] = "1"
        app.launchEnvironment["UITest"] = "true"
        app.launch()
        
        // Attende che venga mostrato un alert
        let errorAlert = app.alerts.firstMatch
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 10), "L'alert d'errore non è stato visualizzato")
        
        // Verifica che il bottone "OK" sia presente nell'alert e simula il tap per chiuderlo
        let okButton = errorAlert.buttons["OK"]
        XCTAssertTrue(okButton.waitForExistence(timeout: 5), "Il bottone OK non è presente nell'alert")
        okButton.tap()
    }
}
