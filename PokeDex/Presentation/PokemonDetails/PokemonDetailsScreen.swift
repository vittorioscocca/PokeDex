//
//  PokemonDetailsScreen.swift
//  PokeDex
//
//  Created by vscocca on 13/03/25.
//

import SwiftUI

struct PokemonDetailsScreen: View {
    @ObservedObject var context: PokemonDetailsScreenViewModel.Context
    
    var body: some View {
        VStack {
            if let imageURL = context.imageURL {
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
            
            Text(context.name.capitalized)
                .font(.largeTitle)
                .padding()
            
            Text("Altezza: \(context.height)")
            Text("Peso: \(context.weight)")
            
            Button("Abilità") {
                context.send(viewAction: .toggleAbilities)
            }
            if context.showAbilities {
                List(context.abilities, id: \.self) { ability in
                    Text(ability.capitalized)
                }
            }
            
            Button("Mosse") {
                context.send(viewAction: .toggleMoves)
            }
            if context.showMoves {
                List(context.moves, id: \.self) { move in
                    Text(move.capitalized)
                }
            }
        }
        .padding()
        .navigationTitle("Dettagli Pokémon")
    }
}
