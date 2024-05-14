import SwiftUI

struct MediaItemView: View {
    let mediaItem: MediaItem

    var body: some View {
        HStack(spacing: Constants.spacing) {
            AsyncImageView(url: mediaItem.posterURL)
                .aspectRatio(Constants.imageViewRatio, contentMode: .fit)

            VStack(alignment: .leading, spacing: Constants.spacing) {
                if let title = mediaItem.title {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                }

                if let year = mediaItem.year {
                    Text(year)
                        .font(.caption)
                }

                if let genre = mediaItem.genre {
                    Text(genre)
                        .font(.caption)
                }

                Spacer()
            }
            .lineLimit(Constants.textLineLimit)
            .frame(alignment: .topLeading)

            Spacer()
        }
        .padding(Constants.spacing)
        .frame(alignment: .topLeading)
    }
}

extension MediaItemView {
    private enum Constants {
        static let spacing = CGFloat(10)
        static let imageViewRatio = 1/1.3
        static let textLineLimit = 2
    }
}

#Preview {
    MediaItemView(mediaItem: PreviewData.mediaItem)
        .frame(width: .infinity, height: 150)
        .border(.blue)
}
