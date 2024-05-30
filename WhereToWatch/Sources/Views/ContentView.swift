import SwiftUI

struct ContentView: View {
    @StateObject private var trendingViewModel = ViewModelProvider.shared.trendingViewModel()
    @StateObject private var searchViewModel = ViewModelProvider.shared.searchViewModel()
    @StateObject private var favoritesViewModel = ViewModelProvider.shared.favoritesViewModel()

    var body: some View {
        TabView {
            TrendingView(trendingViewModel: trendingViewModel)
                .tabItem {
                    Label("TRENDING_TAB_TITLE", systemImage: "chart.line.uptrend.xyaxis.circle")
                }

            SearchView(searchViewModel: searchViewModel)
                .tabItem {
                    Label("SEARCH_TAB_TITLE", systemImage: "magnifyingglass.circle")
                }

            FavoriteView(favoritesViewModel: favoritesViewModel)
                .tabItem {
                    Label("FAVORITE_TAB_TITLE", systemImage: "star.circle")
                }

            SettingsView()
                .tabItem {
                    Label("SETTINGS_TAB_TITLE", systemImage: "gear.circle.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
