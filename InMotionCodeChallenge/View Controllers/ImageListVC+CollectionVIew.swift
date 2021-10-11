//
//  ImageListVC+CollectionVIew.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/10/21.
//

import UIKit

extension ImageListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastSectionIndex = (fetchedResultsController.sections?.count ?? 0) - 1
        // when we only have half as many as the number items we fetch remaining in our entire list of items to display
        let lastItemIndex = (fetchedResultsController.sections?[lastSectionIndex].numberOfObjects ?? 0) - (fetchReqManager.itemsPerRequest / 2)
        
        // when in the last row and past the row mark set aboce, and think we have more data available to fetchj
        if indexPath.section == lastSectionIndex &&
            indexPath.row >= lastItemIndex &&
            fetchReqManager.canFetchMoreItems() {
            self.fetchMoreImages()
        }
    }
}

extension ImageListVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let retVal = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        
        return retVal
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cellImage = fetchedResultsController.sections?[indexPath.section].objects?[indexPath.item] as? Image,
           let imageCell = customView.collectionView.dequeueReusableCell(withReuseIdentifier: ImageListCollectionViewCell.identifier, for: indexPath) as? ImageListCollectionViewCell {
            imageCell.image = cellImage
            
            return imageCell
        } else {
            return UICollectionViewCell()
        }
    }
}

extension ImageListVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                     layout collectionViewLayout: UICollectionViewLayout,
                     sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // 3 square cells per row
        // (width - left inset - right inset - 2 inter cell insets) / 3 cells = width
        let cellSize = (collectionView.frame.width - insets.left - insets.right - ((insets.left) * 2)) / 3
        let cellHeight = cellSize
        let cellWidth = cellSize
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }
  
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return insets.top
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
                        collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return insets.left / 2
    }
}

extension ImageListVC: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            print("Prefetch - \(indexPath)")
            if let image = fetchedResultsController.sections?[indexPath.section].objects?[indexPath.item]  as? Image,
               let urlStr = image.imageUrl,
               let url = URL(string: urlStr),
               let keyStr = image.id {
                print("Preloading - \(urlStr)")
                imageCache.loadImageIfNotInCache(imageUrl: url, forKey: keyStr)
            }
        }
    }
}
