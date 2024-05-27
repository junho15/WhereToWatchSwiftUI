import SwiftUI

struct SimilarItemView: View {
    let similarItem: MediaItem

    var body: some View {
        VStack(spacing: Constants.spacing) {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    AsyncImageView(url: similarItem.posterURL)
                        .aspectRatio(Constants.imageViewRatio, contentMode: .fit)
                    Spacer()

                    if let title = similarItem.title {
                        Text(title)
                            .font(.caption2)
                            .lineLimit(Constants.titleLineLimit)
                            .frame(width: geometry.size.width)
                    }
                }
            }
        }
    }
}

extension SimilarItemView {
    private enum Constants {
        static let spacing = CGFloat(10)
        static let imageViewRatio = CGFloat(2)/CGFloat(3)
        static let titleLineLimit = 1
    }
}

#Preview {
    GeometryReader { geometry in
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [
                GridItem()
            ], spacing: 0) {
                ForEach(PreviewData.mediaItems) { mediaItem in
                    SimilarItemView(similarItem: mediaItem)
                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                        .frame(width: geometry.size.width / 3, height: 200)
                }
            }
        }
        .scrollTargetBehavior(.paging)
    }
}
