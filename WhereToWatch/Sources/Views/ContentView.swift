import SwiftUI
import MovieDatabaseAPI

struct ContentView: View {
    var body: some View {
        FavoriteView(favoritesViewModel: ViewModelProvider.shared.favoritesViewModel())
    }
}

#Preview {
    ContentView()
}
