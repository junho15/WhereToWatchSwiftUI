import SwiftUI

struct MediaItemsListView: View {
    @Binding var mediaItems: [MediaItem]
    @Binding var selectedMediaItem: MediaItem?
    let enableDelete: Bool
    let onReachEnd: (() -> Void)?

    init(
        mediaItems: Binding<[MediaItem]>,
        selectedMediaItem: Binding<MediaItem?>,
        enableDelete: Bool,
        onReachEnd: (() -> Void)? = nil
    ) {
        self._mediaItems = mediaItems
        self._selectedMediaItem = selectedMediaItem
        self.enableDelete = enableDelete
        self.onReachEnd = onReachEnd
    }

    var body: some View {
        List {
            ForEach(mediaItems) { mediaItem in
                MediaItemView(mediaItem: mediaItem)
                    .frame(maxHeight: Constants.maxHeight)
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
            .onDelete(perform: enableDelete ? deleteItem : nil)
            .listRowSeparator(.hidden)
            .listRowInsets(Constants.listRowInsets)
        }
    }

    func deleteItem(at offset: IndexSet) {
        mediaItems.remove(atOffsets: offset)
    }
}

extension MediaItemsListView {
    private enum Constants {
        static let maxHeight = CGFloat(150)
        static let listRowInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
}

#Preview {
    @State var mediaItems = PreviewData.mediaItems
    @State var selectedMediaItem: MediaItem?

    return MediaItemsListView(
        mediaItems: $mediaItems,
        selectedMediaItem: $selectedMediaItem,
        enableDelete: true,
        onReachEnd: {
            print("Reach End!")
        }
    )
}
