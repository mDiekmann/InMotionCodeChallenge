//
//  ImageListVC.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/10/21.
//

import UIKit
import CoreData
import Combine

class ImageListVC: BaseViewController<ImageListView> {

    //MARK: Variables
    var fetchedResultsController: NSFetchedResultsController<Image>!
    let coreDataManager: CoreDataManager!
    let fetchReqManager: ImageListFetchRequestManager!
    
    // for fetched results controller
    var insertedIndexes = [IndexPath]()
    var updatedIndexes = [IndexPath]()
    var deletedIndexes = [IndexPath]()
    
    // related to fetching of remote data
    private(set) var isLoading = false
    var fetchMoreImagesCancellable: AnyCancellable?
    
    // collection view layout
    let insets = UIEdgeInsets(top: 5.0,
                              left: 5.0,
                              bottom: 5.0,
                              right: 5.0)
    
    //MARK: Initiializers
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        //setup current page for fetchReqManager
        let totalCurrentImageCount = coreDataManager.getAllImagesCount()
        self.fetchReqManager = ImageListFetchRequestManager(totalCurrentImages: totalCurrentImageCount)
        super.init(nibName: nil, bundle: nil)
        
        let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: coreDataManager.managedObjectContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Override bae functionality
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customView.collectionView.delegate = self
        customView.collectionView.dataSource = self
        customView.collectionView.prefetchDataSource = self
        customView.collectionView.register(ImageListCollectionViewCell.self, forCellWithReuseIdentifier: ImageListCollectionViewCell.identifier)
        if coreDataManager.getAllImagesCount() == 0 {
            fetchMoreImages()
        }
    }
}
//MARK: Custom functionality
extension ImageListVC {
    func fetchMoreImages() {
        // if already waiting to load more items return
        if isLoading {
            return
        }
        
        isLoading = true
        fetchMoreImagesCancellable = fetchReqManager.fetchNext().sink(receiveCompletion: { [weak self] completion in
            self?.isLoading = false
            switch completion {
                case .failure:
                    //TODO: toast for failure
                    print("Error retrieving additional images")
                case .finished:
                    //TODO: use logger
                    print("Successfully retrieved images from API")
            }
        }, receiveValue: { [weak self] images in
            DispatchQueue.main.async {
                self?.coreDataManager.addImages(images)
            }
        })
    }
}
