import SwiftUI

struct FavoriteView: View {
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @State var selectedMediaItem: MediaItem?
    @State var showingDetail: Bool = false
    @State var navigationPath = NavigationPath()

    private let viewModelProvider = ViewModelProvider.shared

    var body: some View {
        VStack(spacing: Constants.spacing) {
            HStack(alignment: .center) {
                Picker("Sort by", selection: $favoritesViewModel.sortOption) {
                    ForEach(FavoritesSortOption.allCases, id: \.self) { option in
                        Text(option.description).tag(option)
                    }
                }

                TextField("SEARCH_BAR_PLACEHOLDER", text: $favoritesViewModel.searchText)
                    .padding(Constants.searchTextFieldSpacing)
                    .background(Color(.systemGray5))
                    .cornerRadius(Constants.cornerRadius)
                    .keyboardType(.webSearch)

                if !favoritesViewModel.searchText.isEmpty {
                    Button(
                        action: {
                            favoritesViewModel.searchText = ""
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
                            )
                        },
                        label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    )
                }
            }
            .padding(Constants.stackPadding)
            .background(favoritesViewModel.mediaItems.isEmpty == false ? Constants.backgroundColor : .clear)

            MediaItemsListView(
                mediaItems: $favoritesViewModel.mediaItems,
                selectedMediaItem: $selectedMediaItem,
                enableDelete: true,
                onDelete: favoritesViewModel.deleteMediaItem
            )
            .onChange(of: selectedMediaItem) { _, newMediaItem in
                guard newMediaItem != nil else { return }
                showingDetail = true
            }
            .task {
                do {
                    try await favoritesViewModel.fetchFavorites()
                } catch {
                    // Handle error
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .sheet(
            isPresented: $showingDetail,
            onDismiss: {
                selectedMediaItem = nil
                navigationPath = NavigationPath()
                Task {
                    do {
                        try await favoritesViewModel.fetchFavorites()
                    } catch {
                        // Handle eror
                    }
                }
            }, content: {
                NavigationStack(path: $navigationPath) {
                    if let selectedMediaItem {
                        mediaItemDetailView(for: selectedMediaItem)
                            .navigationDestination(for: MediaItem.self) { mediaItem in
                                mediaItemDetailView(for: mediaItem)
                            }
                    }
                }
            }
        )
        .onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
            )
        }
    }
}

extension FavoriteView {
    private func mediaItemDetailView(for mediaItem: MediaItem) -> some View {
        let mediaDetailViewModel = viewModelProvider.mediaDetailViewModel(mediaItem: mediaItem)
        let creditsViewModel = viewModelProvider.creditsViewModel(mediaItem: mediaItem)
        let similarViewModel = viewModelProvider.similarViewModel(mediaItem: mediaItem)
        let watchProviderViewModel = viewModelProvider.watchProviderViewModel(mediaItem: mediaItem)

        return MediaItemDetailView(
            path: $navigationPath,
            showingDetail: $showingDetail,
            mediaDetailViewModel: mediaDetailViewModel,
            creditsViewModel: creditsViewModel,
            similarViewModel: similarViewModel,
            watchProviderViewModel: watchProviderViewModel
        )
    }
}

extension FavoriteView {
    private enum Constants {
        static let spacing = CGFloat(20)
        static let searchTextFieldSpacing = CGFloat(10)
        static let stackPadding = EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
        static let cornerRadius = CGFloat(10)
        static let backgroundColor = Color(uiColor: .systemGray6)
    }
}

#Preview {
    FavoriteView(favoritesViewModel: PreviewData.favoritesViewModel)
}
