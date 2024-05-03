import SwiftUI

struct MediaItemsListView: View {
    @Binding var mediaItems: [MediaItem]
    @Binding var selectedMediaItem: MediaItem?
    let enableDelete: Bool
    var onReachEnd: (() -> Void)?

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
