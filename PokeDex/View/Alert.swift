//
//  Untitled.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import SwiftUI

// MARK: - Protocollo AlertProtocol

/// Un protocollo che descrive le proprietà essenziali di un alert.
///
/// Tipicamente, ogni tipo che rappresenta le informazioni di un alert deve fornire almeno un titolo.
protocol AlertProtocol {
    /// Il titolo dell'alert.
    var title: String { get }
}

// MARK: - Estensioni di View per Alert Personalizzati

extension View {
    /// Presenta un alert personalizzato su una view utilizzando un oggetto che adotta `AlertProtocol`.
    ///
    /// Questa funzione consente di configurare un alert sfruttando i binding, e costruisce un binding Booleano basato
    /// sulla presenza o meno dell'oggetto `Item`. Quando l'alert viene dismesso (binding impostato su `false`), l'oggetto viene resettato a `nil`.
    ///
    /// - Parameters:
    ///   - item: Un binding opzionale ad un oggetto che adotta `AlertProtocol`.
    ///   - actions: Una closure che, dato l'oggetto, restituisce le azioni (bottoni) da visualizzare nell'alert.
    ///   - message: Una closure che, dato l'oggetto, restituisce il contenuto testuale (o altro) dell'alert.
    /// - Returns: Una view che presenta l'alert configurato.
    func alert<Item, Actions, Message>(
        item: Binding<Item?>,
        @ViewBuilder actions: (Item) -> Actions,
        @ViewBuilder message: (Item) -> Message
    ) -> some View where Item: AlertProtocol, Actions: View, Message: View {
        let binding = Binding<Bool>(get: {
            item.wrappedValue != nil
        }, set: { newValue in
            if !newValue {
                item.wrappedValue = nil
            }
        })
        return alert(
            item.wrappedValue?.title ?? "",
            isPresented: binding,
            presenting: item.wrappedValue,
            actions: actions,
            message: message
        )
    }
    
    /// Presenta un alert personalizzato su una view utilizzando un oggetto che adotta `AlertProtocol`, senza messaggio.
    ///
    /// - Parameters:
    ///   - item: Un binding opzionale ad un oggetto che adotta `AlertProtocol`.
    ///   - actions: Una closure che, dato l'oggetto, restituisce le azioni (bottoni) da visualizzare nell'alert.
    /// - Returns: Una view che presenta l'alert configurato.
    func alert<Item, Actions>(
        item: Binding<Item?>,
        @ViewBuilder actions: (Item) -> Actions
    ) -> some View where Item: AlertProtocol, Actions: View {
        let binding = Binding<Bool>(get: {
            item.wrappedValue != nil
        }, set: { newValue in
            if !newValue {
                item.wrappedValue = nil
            }
        })
        return alert(
            item.wrappedValue?.title ?? "",
            isPresented: binding,
            presenting: item.wrappedValue,
            actions: actions
        )
    }
}

// MARK: - Struct AlertInfo

/// Un tipo che descrive le informazioni necessarie per visualizzare un alert all'utente.
///
/// `AlertInfo` adotta i protocolli `Identifiable` e `AlertProtocol`, il che lo rende utilizzabile
/// come item in un binding per la presentazione di alert personalizzati in SwiftUI.
///
/// Esempio di utilizzo:
/// ```swift
/// view.alert(item: $context.alertInfo)
/// ```
struct AlertInfo<T: Hashable>: Identifiable, AlertProtocol {
    
    // MARK: - Tipi Annidati
    
    /// Rappresenta un pulsante dell'alert.
    struct AlertButton: Identifiable {
        /// Identificatore univoco generato automaticamente.
        let id = UUID()
        /// Il titolo del pulsante.
        let title: String
        /// Il ruolo del pulsante (opzionale), che può influenzare lo stile.
        var role: ButtonRole?
        /// L'azione da eseguire quando il pulsante viene premuto (opzionale).
        let action: (() -> Void)?
    }
    
    /// Rappresenta un campo di testo (TextField) visualizzato nell'alert.
    struct AlertTextField: Identifiable {
        /// Identificatore univoco generato automaticamente.
        let id = UUID()
        /// Il testo placeholder del campo.
        let placeholder: String
        /// Il binding che gestisce il testo immesso.
        let text: Binding<String>
        /// La modalità di capitalizzazione automatica del testo.
        let autoCapitalization: TextInputAutocapitalization
        /// Indica se l'autocorrezione deve essere disabilitata.
        let autoCorrectionDisabled: Bool
    }
    
    // MARK: - Proprietà di AlertInfo
    
    /// Un identificatore per distinguere tra diversi alert.
    let id: T
    /// Il titolo dell'alert.
    let title: String
    /// Un messaggio opzionale da visualizzare nell'alert.
    var message: String?
    /// Il pulsante primario dell'alert. Di default è impostato su "OK" senza azione.
    var primaryButton = AlertButton(title: "OK", action: nil)
    /// Un pulsante secondario opzionale.
    var secondaryButton: AlertButton?
    /// Una lista opzionale di campi di testo da visualizzare nell'alert.
    var textFields: [AlertTextField]?
    /// Una lista opzionale di pulsanti aggiuntivi, disposti verticalmente sopra il pulsante primario.
    var verticalButtons: [AlertButton]?
}

// MARK: - Estensioni di AlertInfo

extension AlertInfo {
    /// Inizializza un alert con un titolo e un messaggio generici per un errore sconosciuto.
    ///
    /// - Parameter id: Un identificatore per l'alert.
    init(id: T) {
        self.id = id
        title = "Errore"
        message = "Errore sconosciuto"
    }
    
    /// Inizializza un alert utilizzando la descrizione localizzata di un errore come titolo.
    ///
    /// Questo inizializzatore può essere utilizzato per creare rapidamente un alert basato su un errore.
    ///
    /// - Parameter error: L'errore da visualizzare.
    init(error: Error) where T == String {
        self.init(id: error.localizedDescription,
                  title: error.localizedDescription)
    }
}

// MARK: - Estensione di View per AlertInfo

extension View {
    /// Presenta un alert basato su un oggetto `AlertInfo`.
    ///
    /// Questo modificatore di view mostra un alert configurato con:
    /// - Un elenco di pulsanti aggiuntivi (se definiti in `verticalButtons`).
    /// - Campi di testo (se definiti in `textFields`).
    /// - Il pulsante primario (obbligatorio) e, se presente, il pulsante secondario.
    /// - Un messaggio testuale (se definito).
    ///
    /// - Parameter item: Un binding opzionale a un oggetto `AlertInfo` che configura l'alert.
    /// - Returns: Una view che presenta l'alert quando l'oggetto `AlertInfo` è presente.
    func alert<T: Hashable>(item: Binding<AlertInfo<T>?>) -> some View {
        alert(item: item) { item in
            // Aggiunge eventuali pulsanti verticali se presenti.
            if let verticalButtons = item.verticalButtons {
                ForEach(verticalButtons) { button in
                    Button(button.title, role: button.role) {
                        button.action?()
                    }
                }
            }
            
            // Aggiunge eventuali campi di testo se presenti.
            if let textFields = item.textFields {
                VStack(spacing: 24) {
                    ForEach(textFields) { textField in
                        TextField(textField.placeholder, text: textField.text)
                            .textInputAutocapitalization(textField.autoCapitalization)
                            .autocorrectionDisabled(textField.autoCorrectionDisabled)
                    }
                }
            }
            
            // Il pulsante primario dell'alert.
            Button(item.primaryButton.title, role: item.primaryButton.role) {
                item.primaryButton.action?()
            }
            
            // Il pulsante secondario, se definito.
            if let secondaryButton = item.secondaryButton {
                Button(secondaryButton.title, role: secondaryButton.role) {
                    secondaryButton.action?()
                }
                .foregroundStyle(.cyan)
                .tint(.black)
            }
        } message: { item in
            // Visualizza il messaggio se presente.
            if let message = item.message {
                Text(message)
                    .foregroundStyle(.cyan)
            }
        }
    }
}
