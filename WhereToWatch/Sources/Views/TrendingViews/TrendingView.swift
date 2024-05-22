import SwiftUI

struct TrendingView: View {
    @ObservedObject var trendingViewModel: TrendingViewModel
    @State var selectedMediaItem: MediaItem?
    @State var showingDetail: Bool = false
    @State var navigationPath = NavigationPath()

    private let segments: [LocalizedStringKey] = ["TIME_WINDOW_DAY", "TIME_WINDOW_WEEK"]
    private let viewModelProvider = ViewModelProvider.shared

    var body: some View {
        VStack(spacing: Constants.spacing) {
            Picker("TimeWindow", selection: $trendingViewModel.selectedTimeWindowIndex) {
                ForEach(0..<2) { index in
                    Text(segments[index]).tag(index)
                }
            }
            .frame(maxWidth: Constants.pickerMaxWidth)
            .pickerStyle(SegmentedPickerStyle())
            .accessibilityIdentifier("TimeWindowPicker")

            mediaSection(title: "MOVIE_TITLE", mediaItems: trendingViewModel.movieMediaItems)
            mediaSection(title: "TVSHOW_TITLE", mediaItems: trendingViewModel.tvShowMediaItems)
        }
        .padding(Constants.stackPadding)
        .background(Constants.backgroundColor)
        .task {
            do {
                try await trendingViewModel.fetchTrendingMediaItems()
            } catch {
                // Handle error
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
            })
    }
}

extension TrendingView {
    private func mediaSection(title: LocalizedStringKey, mediaItems: [MediaItem]) -> some View {
        Section {
            MediaItemsCollectionView(
                selectedMediaItem: $selectedMediaItem,
                mediaItems: mediaItems
            )
            .padding(Constants.MediaItemsCollectionViewPadding)
            .background(Constants.itemBackgroundStyle)
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
            .onChange(of: selectedMediaItem) { _, newMediaItem in
                guard newMediaItem != nil else { return }
                showingDetail = true
            }
        } header: {
            HStack {
                Text(title)
                    .font(Constants.sectionHeaderFont)
                    .foregroundStyle(Constants.sectionHeaderTextColor)
                Spacer()
            }
            .padding(.leading, Constants.sectionHeaderTextLeadingPadding)
            .padding(.bottom, Constants.sectionHeaderBottomSpacing)
        }
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

extension TrendingView {
    private enum Constants {
        static let spacing = CGFloat(20)
        static let pickerMaxWidth = CGFloat(200)
        static let sectionHeaderTextLeadingPadding = CGFloat(10)
        static let sectionHeaderFont = Font.headline
        static let sectionHeaderTextColor = Color(.systemPink)
        static let sectionHeaderBottomSpacing = CGFloat(-10)
        static let stackPadding = EdgeInsets(top: .zero, leading: 20, bottom: .zero, trailing: 20)
        static let MediaItemsCollectionViewPadding = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        static let cornerRadius = CGFloat(10)
        static let backgroundColor = Color(uiColor: .systemGray6)
        static let itemBackgroundStyle = BackgroundStyle.background
    }
}

#Preview {
    TrendingView(trendingViewModel: PreviewData.trendingViewModel)
}
