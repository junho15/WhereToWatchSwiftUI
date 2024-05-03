import SwiftUI

struct MediaDetailHeaderView: View {
    let posterURL: URL?
    let backDropURL: URL?
    let title: String?
    let year: String?
    let genre: String?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                AsyncImageView(url: backDropURL)
                    .aspectRatio(Constants.backdropRatio, contentMode: .fill)
                    .overlay {
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))

                HStack(alignment: .bottom, spacing: Constants.spacing) {
                    AsyncImageView(url: posterURL)
                        .aspectRatio(Constants.posterRatio, contentMode: .fit)
                        .frame(width: geometry.size.width * Constants.posterWidthRatio)

                    VStack(alignment: .leading, spacing: Constants.spacing) {
                        if let title {
                            Text(title)
                                .font(.headline)
                        }

                        if let year, let genre {
                            Text("\(year) \(genre)")
                                .font(.footnote)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, Constants.spacing)
                .padding(.bottom, Constants.spacing)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

extension MediaDetailHeaderView {
    private enum Constants {
        static let spacing = CGFloat(10)
        static let cornerRadius = CGFloat(10)
        static let backdropRatio = CGFloat(281)/CGFloat(500)
        static let posterWidthRatio = 0.2
        static let posterRatio = CGFloat(2)/CGFloat(3)
    }
}

#Preview {
    GeometryReader { geometry in
        MediaDetailHeaderView(
            posterURL: PreviewData.mediaItem.posterURL,
            backDropURL: PreviewData.mediaItem.backdropURL,
            title: PreviewData.mediaItem.title!,
            year: PreviewData.mediaItem.year!,
            genre: PreviewData.mediaItem.genre!
        )
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        .frame(width: geometry.size.width, height: 100)
    }
}
