import SwiftUI

struct MediaItemsCollectionView: View {
    let mediaItems: [MediaItem]
    @Binding var selectedMediaItem: MediaItem?

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [
                    GridItem(.fixed(geometry.size.height * Constants.gridItemRatio)),
                    GridItem(.fixed(geometry.size.height * Constants.gridItemRatio))
                ]) {
                    ForEach(mediaItems) { mediaItem in
                        MediaItemView(mediaItem: mediaItem)
                            .frame(width: geometry.size.width, height: geometry.size.height * Constants.gridItemRatio)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedMediaItem = mediaItem
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

    return MediaItemsCollectionView(mediaItems: PreviewData.mediaItems, selectedMediaItem: $selectedMediaItem)
        .border(.blue)
        .frame(width: .infinity, height: 400)
}
