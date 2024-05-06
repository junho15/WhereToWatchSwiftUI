import SwiftUI

struct SimilarItemsCollectionView: View {
    @Binding var selectedSimilarItem: MediaItem?
    let similarItems: [MediaItem]
    var onReachEnd: (() -> Void)?

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [
                    GridItem()
                ], spacing: Constants.spacing) {
                    ForEach(similarItems) { similarItem in
                        SimilarItemView(similarItem: similarItem)
                            .padding(Constants.itemPadding)
                            .frame(width: geometry.size.width * Constants.itemWidthRatio, height: Constants.itemHeight)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedSimilarItem = similarItem
                            }
                            .onAppear {
                                if similarItem == similarItems.last  {
                                    onReachEnd?()
                                }
                            }
                    }
                }
            }
            .scrollTargetBehavior(.paging)
        }
    }
}

extension SimilarItemsCollectionView {
    private enum Constants {
        static let spacing = CGFloat.zero
        static let itemPadding = EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        static let itemWidthRatio = 1.0 / 3.0
        static let itemHeight = 200.0
    }
}

#Preview {
    @State var selectedSimilarItem: MediaItem?

    return SimilarItemsCollectionView(
        selectedSimilarItem: $selectedSimilarItem,
        similarItems: PreviewData.mediaItems,
        onReachEnd: {
            print("Reach End!")
        }
    )
}
