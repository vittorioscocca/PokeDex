# PokeDex

PokeDex è un'app iOS sviluppata con SwiftUI che utilizza l'API di PokeAPI per recuperare e visualizzare un elenco di Pokémon con dettagli e immagini.

## 🛠 Tecnologie utilizzate
- Swift 5
- SwiftUI
- Combine
- Async/Await
- MVVM con Coordinators
- Networking con URLSession

## 📦 Struttura del Progetto

- `PokeDexApp.swift` - Punto di ingresso dell'app.
- `PokemonListScreen.swift` - UI per la lista dei Pokémon.
- `PokemonListScreenViewModel.swift` - ViewModel che gestisce il recupero e la gestione dei dati.
- `PokemonListScreenCoordinator.swift` - Coordinator per la navigazione.
- `APIService.swift` - Servizio di rete per comunicare con PokeAPI.
- `NetworkLoader.swift` - Classe per le chiamate API.
- `PokemonListResponse.swift`, `PokemonDetailResponse.swift` - Modelli dati per l'API.

## 🚀 Installazione

1. Clona il repository:
   ```sh
   git clone https://github.com/tuo-username/tuo-repo.git
   cd tuo-repo
   ```

2. Apri il progetto in Xcode:
   ```sh
   open PokeDex.xcodeproj
   ```
# PokeDex
