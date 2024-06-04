import SwiftUI

struct CreditItemView: View {
    let creditItem: CreditItem

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()

                AsyncImageView(url: creditItem.profileURL)
                    .aspectRatio(Constants.imageViewRatio, contentMode: .fit)

                Spacer()

                VStack(spacing: Constants.spacing) {
                    if let name = creditItem.name {
                        Text(name)
                            .font(.footnote)
                    }

                    if let character = creditItem.character {
                        Text(character)
                            .font(.caption2)
                    }
                }
                .multilineTextAlignment(.center)
                .lineLimit(Constants.textLineLimit)
                .frame(width: geometry.size.width, height: geometry.size.height * Constants.textStackHeightRatio)
            }
        }
    }
}

extension CreditItemView {
    private enum Constants {
        static let spacing = CGFloat(10)
        static let imageViewRatio = CGFloat(2)/CGFloat(3)
        static let textLineLimit = 2
        static let textStackHeightRatio = 0.5
    }
}

#Preview {
    GeometryReader { geometry in
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [
                GridItem()
            ], spacing: 0) {
                ForEach(PreviewData.creditsData.cast) { credit in
                    CreditItemView(creditItem: CreditItem(credit: credit))
                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                        .frame(width: geometry.size.width / 3, height: 200)
                }
            }
        }
        .scrollTargetBehavior(.paging)
    }
}
