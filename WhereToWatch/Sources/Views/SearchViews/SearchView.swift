import SwiftUI

struct SearchView: View {
    @ObservedObject var searchViewModel: SearchViewModel
    @State var selectedMediaItem: MediaItem?
    @State var showingDetail: Bool = false
    @State var navigationPath = NavigationPath()

    private let viewModelProvider = ViewModelProvider.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: Constants.spacing) {
                mediaSection(
                    title: "MOVIE_TITLE", mediaItems:
                        $searchViewModel.movieMediaItems,
                    totalCount: searchViewModel.movieTotalCount
                ) {
                    Task {
                        do {
                            try await searchViewModel.fetchMoreMovies()
                        } catch {
                            // Handle error
                        }
                    }
                }

                mediaSection(
                    title: "TVSHOW_TITLE",
                    mediaItems: $searchViewModel.tvShowMediaItems,
                    totalCount: searchViewModel.tvShowTotalCount
                ) {
                    Task {
                        do {
                            try await searchViewModel.fetchMoreTVShows()
                        } catch {
                            // Handle error
                        }
                    }
                }
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .padding(Constants.stackPadding)
            .background(Constants.backgroundColor)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        TextField("SEARCH_BAR_PLACEHOLDER", text: $searchViewModel.searchText)
                            .padding(Constants.searchTextFieldSpacing)
                            .background(Color(.systemGray5))
                            .cornerRadius(Constants.cornerRadius)
                            .keyboardType(.asciiCapable)

                        if !searchViewModel.searchText.isEmpty {
                            Button(
                                action: {
                                    searchViewModel.searchText = ""
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
                    .padding(Constants.searchBarStackPadding)
                }
            }
            .sheet(
                isPresented: $showingDetail,
                onDismiss: {
                    selectedMediaItem = nil
                    navigationPath = NavigationPath()
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
            .ignoresSafeArea(.keyboard)
        }
    }
}

extension SearchView {
    private func mediaSection(
        title: String, mediaItems: Binding<[MediaItem]>, totalCount: Int, onReachEnd: (() -> Void)? = nil
    ) -> some View {
        Section {
            MediaItemsCollectionView(
                selectedMediaItem: $selectedMediaItem,
                mediaItems: mediaItems.wrappedValue,
                onReachEnd: onReachEnd
            )
            .padding(Constants.mediaItemsCollectionViewPadding)
            .background(Constants.itemBackgroundStyle)
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
            .onChange(of: selectedMediaItem) { _, newMediaItem in
                guard newMediaItem != nil else { return }
                showingDetail = true
            }
        } header: {
            HStack {
                Text("\(NSLocalizedString(title, comment: "Header Title")) (\(totalCount))")
                    .font(Constants.sectionHeaderFont)
                    .foregroundStyle(Constants.sectionHeaderTextColor)
                Spacer()

                if mediaItems.isEmpty == false {
                    NavigationLink {
                        mediaItemsListView(mediaItems: mediaItems, onReachEnd: onReachEnd)
                            .navigationTitle("\(searchViewModel.searchText) (\(totalCount))")
                    } label: {
                        Text("VIEW_ALL")
                    }
                }
            }
            .padding(.leading, Constants.sectionHeaderTextLeadingPadding)
            .padding(.bottom, Constants.sectionHeaderBottomSpacing)
            .background(Constants.backgroundColor)
        }
    }

    private func mediaItemsListView(
        mediaItems: Binding<[MediaItem]>, onReachEnd: (() -> Void)? = nil
    ) -> some View {
        MediaItemsListView(
            mediaItems: mediaItems,
            selectedMediaItem: $selectedMediaItem,
            enableDelete: false,
            onReachEnd: onReachEnd
        )
    }

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

extension SearchView {
    private enum Constants {
        static let spacing = CGFloat(20)
        static let searchTextFieldSpacing = CGFloat(7)
        static let sectionHeaderTextLeadingPadding = CGFloat(10)
        static let sectionHeaderFont = Font.headline
        static let sectionHeaderTextColor = Color.blue
        static let sectionHeaderBottomSpacing = CGFloat(-10)
        static let searchBarStackPadding = EdgeInsets(top: 10, leading: 0, bottom: 15, trailing: 0)
        static let stackPadding = EdgeInsets(top: .zero, leading: 20, bottom: .zero, trailing: 20)
        static let mediaItemsCollectionViewPadding = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        static let cornerRadius = CGFloat(10)
        static let backgroundColor = Color(uiColor: .systemGray6)
        static let itemBackgroundStyle = BackgroundStyle.background
    }
}

#Preview {
    SearchView(searchViewModel: PreviewData.searchViewModel)
}
