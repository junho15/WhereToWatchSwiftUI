import SwiftUI
import MovieDatabaseAPI

struct ContentView: View {
    var body: some View {
        TrendingView(trendingViewModel: ViewModelProvider.shared.trendingViewModel())
    }
}

#Preview {
    ContentView()
}
