//
//  ImageListFetchRequestManager.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/7/21.
//

import Foundation

public enum ImageListFetchRequesError: Error {
    case generalError
    case invalidLocalData
    case invalidFeedObj
    case getFeedReqFailure
    case endOfFeedErr
}

class ImageListFetchRequestManager: NSObject {
    var itemsPerRequest: Int = 20
    private var isLoading = false
    private(set) var currentIndex: Int = 0
    private var endOfFeedReached: Bool = false
    
    // start index used to start retrieving from set index when cached data is present
    init(startIndex: Int = 0) {
        self.currentIndex = startIndex
    }
    
    func setFetchIndex(_ index: Int) {
        currentIndex = index
    }
    
    func canFetchMoreItems() -> Bool {
        return !endOfFeedReached
    }
    
    /*func fetchNext(onSuccess: @escaping ([GizmoDataModel]) -> Void, onError: @escaping
                    (FeedFetchRequestError) -> Void) {
        // if already loading ignore request to fetch more items
        // UI asking for more items before initial request completed
        if isLoading {
            return
        }
        if endOfFeedReached {
            onError(.endOfFeedErr)
            return
        }
        
        guard let feedType = feedType,
              let user = user else {
            onError(.invalidLocalData)
            return
        }
        
        isLoading = true
        API.getFeed(forFeedType: feedType, startIndex: currentIndex, endIndex: currentIndex + itemsPerRequest, filters: filters, forUser: user.uuid) { feed in
            self.isLoading = false
            if let feed = feed {
                self.currentIndex = self.currentIndex + feed.gizmos.count
                // if less than the requested count end of the feed reached
                self.endOfFeedReached = feed.count < self.itemsPerRequest
                onSuccess(feed.gizmos)
            } else {
                onError(.invalidFeedObj)
            }
        } onFailure: { error in
            self.isLoading = false
            onError(.getFeedReqFailure)
        }
    }*/
    
    func reset() {
        currentIndex = 0
        endOfFeedReached = false
    }
}
