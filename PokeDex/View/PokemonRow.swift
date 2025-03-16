//
//  PokemonRow.swift
//  PokeDex
//
//  Created by vscocca on 13/03/25.
//

import SwiftUI

struct PokemonRowView: View {
    let pokemon: PokemonListItem
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            if let imageURL = pokemon.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit()
                    case .failure:
                        Color.red
                    default:
                        ProgressView()
                    }
                }
                .frame(width: 50, height: 50)
            } else {
                Color.gray.frame(width: 50, height: 50)
            }
            Text(pokemon.name.capitalized)
                .font(.headline)
        }
        .onTapGesture {
            onTap()
        }
        .accessibilityIdentifier("pokemonListCell")
    }
}
