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
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(Constants.spacing)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

extension MediaItemView {
    private enum Constants {
        static let spacing = CGFloat(10)
        static let imageViewRatio = CGFloat(2)/CGFloat(3)
    }
}

#Preview {
    MediaItemView(mediaItem: PreviewData.mediaItem)
        .frame(width: .infinity, height: 150)
        .border(.blue)
}
