import SwiftUI
import MovieDatabaseAPI

struct ContentView: View {
    var body: some View {
        SearchView(searchViewModel: ViewModelProvider.shared.searchViewModel())
    }
}

#Preview {
    ContentView()
}
