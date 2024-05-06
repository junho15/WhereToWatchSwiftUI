import SwiftUI

struct CreditItemsCollectionView: View {
    let creditItems: [CreditItem]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem()], spacing: Constants.spacing) {
                    ForEach(creditItems) { creditItem in
                        CreditItemView(creditItem: creditItem)
                            .padding(Constants.itemPadding)
                            .frame(width: geometry.size.width * Constants.itemWidthRatio, height: Constants.itemHeight)
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
        static let itemHeight = 200.0
    }
}

#Preview {
    CreditItemsCollectionView(creditItems: PreviewData.creditsData.cast.map { CreditItem(credit: $0) })
}
