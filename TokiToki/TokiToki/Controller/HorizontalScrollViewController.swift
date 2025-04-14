//
//  HorizontalScrollViewController.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 6/4/25.
//

import UIKit

class HorizontalScrollViewController: UICollectionViewController {
    private var indexOfCellBeforeDragging = 0
    private var collectionViewFlowLayout: UICollectionViewFlowLayout {
        guard let collectionView = collectionViewLayout as? UICollectionViewFlowLayout else {
            return UICollectionViewFlowLayout()
        }
        return collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionViewFlowLayout.minimumLineSpacing = 0
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        configureCollectionViewLayoutItemSize()
    }

    func calculateSectionInset() -> CGFloat { // should be overridden
        100
    }

    private func configureCollectionViewLayoutItemSize() {
        let inset: CGFloat = calculateSectionInset()
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)

        let size = CGSize(width:
                          collectionViewLayout.collectionView!.frame.size.width - inset * 2,
                          height: collectionViewLayout.collectionView!.frame.size.height)
        collectionViewFlowLayout.itemSize = size
    }

    func indexOfMajorCell() -> Int {
        let itemWidth = collectionViewFlowLayout.itemSize.width
        let proportionalOffset = collectionViewLayout.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let safeIndex = max(0, min(numberOfItems - 1, index))
        return safeIndex
    }

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }

    override func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                            withVelocity velocity: CGPoint,
                                            targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset

        let indexOfMajorCell = self.indexOfMajorCell()

        let dataSourceCount = collectionView(collectionView!, numberOfItemsInSection: 0)
        let swipeVelocityThreshold: CGFloat = 0.5
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < dataSourceCount && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell ||
             hasEnoughVelocityToSlideToThePreviousCell)

        if didUseSwipeToSkipCell {

            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = collectionViewFlowLayout.itemSize.width * CGFloat(snapToIndex)

            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1,
                           initialSpringVelocity: velocity.x,
                           options: .allowUserInteraction, animations: {
                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                scrollView.layoutIfNeeded()
            }, completion: nil)

        } else {
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

}
