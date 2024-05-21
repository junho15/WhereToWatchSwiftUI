import SwiftUI

struct MediaItemsCollectionView: View {
    @Binding var selectedMediaItem: MediaItem?
    let mediaItems: [MediaItem]
    let onReachEnd: (() -> Void)?

    init(
        selectedMediaItem: Binding<MediaItem?>,
        mediaItems: [MediaItem],
        onReachEnd: (() -> Void)? = nil
    ) {
        self._selectedMediaItem = selectedMediaItem
        self.mediaItems = mediaItems
        self.onReachEnd = onReachEnd
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [
                    GridItem(.fixed(geometry.size.height * Constants.gridItemRatio)),
                    GridItem(.fixed(geometry.size.height * Constants.gridItemRatio))
                ], spacing: .zero) {
                    ForEach(mediaItems) { mediaItem in
                        MediaItemView(mediaItem: mediaItem)
                            .frame(width: geometry.size.width, height: geometry.size.height * Constants.gridItemRatio)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedMediaItem = mediaItem
                            }
                            .onAppear {
                                if mediaItem == mediaItems.last {
                                    onReachEnd?()
                                }
                            }
                    }
                }
                .frame(height: geometry.size.height)
            }
            .scrollTargetBehavior(.paging)
        }
    }
}

extension MediaItemsCollectionView {
    private enum Constants {
        static let gridItemRatio = 0.5
    }
}

#Preview {
    @State var selectedMediaItem: MediaItem?

    return MediaItemsCollectionView(
        selectedMediaItem: $selectedMediaItem,
        mediaItems: PreviewData.mediaItems,
        onReachEnd: {
            print("Reach End!")
        }
    )
    .border(.blue)
    .frame(width: .infinity, height: 400)
}
