import SwiftUI

struct AsyncImageView: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                Image("Empty")
                    .resizable()
                    .scaledToFit()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                Image("Empty")
                    .resizable()
                    .scaledToFit()
            @unknown default:
                EmptyView()
            }
        }
    }
}

#Preview {
    return VStack {
        AsyncImageView(
            url: PreviewData.mediaItem.posterURL
        )

        AsyncImageView(
            url: PreviewData.mediaItem.backdropURL
        )
    }
}
