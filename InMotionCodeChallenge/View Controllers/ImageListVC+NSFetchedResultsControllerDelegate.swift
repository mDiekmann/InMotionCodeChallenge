//
//  ImageListVC+NSFetchedResultsControllerDelegate.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/10/21.
//

import UIKit
import CoreData

extension ImageListVC: NSFetchedResultsControllerDelegate {
    // begin updates
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes.removeAll()
        updatedIndexes.removeAll()
        deletedIndexes.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                if let newIndexPath = newIndexPath {
                    insertedIndexes.append(newIndexPath)
                }
            case .update:
                if let indexPath = indexPath {
                    updatedIndexes.append(indexPath)
                }
            case .delete:
                if let indexPath = indexPath {
                    deletedIndexes.append(indexPath)
                }
            case .move:
                if let indexPath = indexPath,
                   let newIndexPath = newIndexPath {
                    deletedIndexes.append(indexPath)
                    insertedIndexes.append(newIndexPath)
                }
        @unknown default:
            //TODO: logger
            print("Unknown NSFetchedResultsChangeType : \(type)")
        }
    }
    //end updates
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        customView.collectionView.performBatchUpdates {
            if !deletedIndexes.isEmpty {
                customView.collectionView.deleteItems(at: deletedIndexes)
            }
            if !insertedIndexes.isEmpty {
                customView.collectionView.insertItems(at: insertedIndexes)
            }
            
            if !updatedIndexes.isEmpty {
                customView.collectionView.reloadItems(at: updatedIndexes)
            }
        }
    }
}
