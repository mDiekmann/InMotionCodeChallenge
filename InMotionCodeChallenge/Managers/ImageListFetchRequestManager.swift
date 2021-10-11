//
//  ImageListFetchRequestManager.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/7/21.
//

import Foundation
import Combine

public enum ImageListFetchRequesError: Error {
    case generalError
    case selfRetainError
    case alreadyLoading
    case getListReqFailure
    case endOfFeedErr
}

class ImageListFetchRequestManager: NSObject {
    private(set) var currentPage: Int = 1
    private(set) var itemsPerRequest: Int = 36
    private(set) var isLoading = false
    private(set) var endOfFeedReached: Bool = false
    private let apiClient: APIClient!
    private var cancellable: AnyCancellable?
    
    // init with how many known items there currently are, current page decided from that
    init(totalCurrentImages: Int, apiClient: APIClient = APIClient()) {
        self.currentPage = Int(totalCurrentImages / itemsPerRequest) + 1
        // API treats page 0 and 1 as the same pages increment 0 to 1 to prevent issues
        if self.currentPage == 0 {
            self.currentPage = 1
        }
        self.apiClient = apiClient
    }
    
    // start index used to start retrieving from set index when cached data is present
    init(startPage: Int = 0, apiClient: APIClient = APIClient()) {
        self.currentPage = startPage
        // API treats page 0 and 1 as the same pages increment 0 to 1 to prevent issues
        if self.currentPage == 0 {
            self.currentPage = 1
        }
        self.apiClient = apiClient
    }
    
    func setFetchPage(_ page: Int) {
        currentPage = page
    }
    
    func canFetchMoreItems() -> Bool {
        return !endOfFeedReached
    }
    
    func fetchNext() -> Future<[ImageDataModel], ImageListFetchRequesError>  {
        let future = Future<[ImageDataModel], ImageListFetchRequesError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.selfRetainError))
                return
            }
            if self.isLoading {
                // if already loading don't retrieve more data or unexpected results may occur
                promise(.failure(.alreadyLoading))
                return
            } else if self.endOfFeedReached {
                // if at the end of the feed return error notifying user of that.
                promise(.failure(.endOfFeedErr))
            } else {
                self.cancellable = self.apiClient.getImageList(currentPage: self.currentPage, fetchLimit: self.itemsPerRequest).sink(receiveCompletion: { completion in
                    switch completion {
                        case .failure:
                            promise(.failure(.getListReqFailure))
                        case .finished:
                            //TODO: use logger
                            print("Successfully retrieved images from API")
                    }
                },
                receiveValue: { response in
                    self.currentPage += 1
                    self.endOfFeedReached = response.count < self.itemsPerRequest
                    promise(.success(response))
                })
            }
        }
        
        return future
    }
    
    func cancel() {
        cancellable?.cancel()
        cancellable = nil
    }
    
    func reset() {
        currentPage = 0
        endOfFeedReached = false
    }
}
