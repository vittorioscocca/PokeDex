//
//  PokemonDetailsScreen.swift
//  PokeDex
//
//  Created by vscocca on 13/03/25.
//

import SwiftUI
import os.log

/// Vista per la schermata dei dettagli di un Pokémon.
///
/// Visualizza l'immagine, il nome, le statistiche (altezza e peso) e fornisce pulsanti per mostrare/nascondere le abilità e le mosse.
/// La vista osserva il suo ViewModel per aggiornamenti dinamici.
struct PokemonDetailsScreen: View {
    /// ViewModel che fornisce i dati e le azioni per la schermata dei dettagli.
    @ObservedObject var viewModel: PokemonDetailsScreenViewModel
    
    var body: some View {
        VStack {
            // Visualizza l'immagine del Pokémon se disponibile.
            if let imageURL = viewModel.imageURL {
                AsyncImage(url: imageURL) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit()
                    } else if phase.error != nil {
                        Color.red
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 150, height: 150)
            }
            
            // Visualizza il nome del Pokémon.
            Text(viewModel.name.capitalized)
                .font(.largeTitle)
                .padding()
            
            // Visualizza le statistiche: Altezza e Peso.
            Text("Altezza: \(viewModel.height)")
            Text("Peso: \(viewModel.weight)")
            
            // Pulsante per mostrare o nascondere le abilità.
            Button("Abilità") {
                os_log("Pulsante Abilità premuto", log: OSLog.default, type: .debug)
                viewModel.toggleAbilities()
            }
            // Se le abilità devono essere mostrate, visualizza una lista.
            if viewModel.showAbilities {
                List(viewModel.abilities, id: \.self) { ability in
                    Text(ability.capitalized)
                }
            }
            
            // Pulsante per mostrare o nascondere le mosse.
            Button("Mosse") {
                os_log("Pulsante Mosse premuto", log: OSLog.default, type: .debug)
                viewModel.toggleMoves()
            }
            // Se le mosse devono essere mostrate, visualizza una lista.
            if viewModel.showMoves {
                List(viewModel.moves, id: \.self) { move in
                    Text(move.capitalized)
                }
            }
        }
        .padding()
        .navigationTitle("Dettagli Pokémon")
    }
}
