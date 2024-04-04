//
//  ContentView.swift
//  WhereToWatch
//
//  Created by junho lee on 3/19/24.
//

import SwiftUI
import MovieDatabaseAPI

struct ContentView: View {
    var body: some View {
        return VStack {
            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500/7rwgEs15tFwyR9NPQ5vpzxTj19Q.jpg")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable().scaledToFit()
                case .failure:
                    Image(systemName: "photo")
                @unknown default:
                    EmptyView()
                }
            }

            Text(MediaType.tvShow.trendingTitle)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
