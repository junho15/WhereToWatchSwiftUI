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
                    .frame(width: geometry.size.width)
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
                        .frame(width: geometry.size.width * Constants.posterWidthRatio)
                        .aspectRatio(Constants.posterRatio, contentMode: .fit)

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
                    .frame(alignment: .leading)
                    .foregroundStyle(.white)

                    Spacer()
                }
                .frame(alignment: .bottomLeading)
                .padding(Constants.padding)
            }
        }
    }
}

extension MediaDetailHeaderView {
    private enum Constants {
        static let spacing = CGFloat(10)
        static let cornerRadius = CGFloat(10)
        static let backdropRatio = CGFloat(281)/CGFloat(500)
        static let posterWidthRatio = 0.2
        static let posterRatio = 1/1.3
        static let padding = EdgeInsets(top: .zero, leading: 10, bottom: 10, trailing: .zero)
    }
}

#Preview {
    GeometryReader { geometry in
        ScrollView(.vertical) {
            VStack(spacing: 10) {
                MediaDetailHeaderView(
                    posterURL: PreviewData.mediaItem.posterURL,
                    backDropURL: PreviewData.mediaItem.backdropURL,
                    title: PreviewData.mediaItem.title!,
                    year: PreviewData.mediaItem.year!,
                    genre: PreviewData.mediaItem.genre!
                )
                .frame(height: geometry.size.width * CGFloat(281)/CGFloat(500))

                Text("Next View")
            }
        }
    }
}
