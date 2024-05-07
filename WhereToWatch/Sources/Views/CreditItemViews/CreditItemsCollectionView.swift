import SwiftUI

struct CreditItemsCollectionView: View {
    let creditItems: [CreditItem]
    let itemHeight: CGFloat

    init(creditItems: [CreditItem], itemHeight: CGFloat = Constants.itemHeight) {
        self.creditItems = creditItems
        self.itemHeight = itemHeight
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Constants.spacing) {
                    ForEach(creditItems) { creditItem in
                        CreditItemView(creditItem: creditItem)
                            .padding(Constants.itemPadding)
                            .frame(width: geometry.size.width * Constants.itemWidthRatio, height: itemHeight)
                    }
                }
            }
            .scrollTargetBehavior(.paging)
        }
    }
}

extension CreditItemsCollectionView {
    private enum Constants {
        static let spacing = CGFloat.zero
        static let itemPadding = EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        static let itemWidthRatio = 1.0 / 3.0
        static let itemHeight = CGFloat(200)
    }
}

#Preview {
    CreditItemsCollectionView(creditItems: PreviewData.creditsData.cast.map { CreditItem(credit: $0) })
}
