//
//  RemoteImageView.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/10/21.
//

import UIKit
import Combine

class RemoteImageView: UIImageView {

    private var cancellable: AnyCancellable?
    
    func loadImageFromURL(_ url: String, withCacheKey key: String) {
        guard let imageURL = URL(string: url) else { return }
        loadImageFromURL(imageURL, withCacheKey: key)
    }

    func loadImageFromURL(_ url: URL, withCacheKey key: String) {
        cancellable = imageCache.loadImageFromURL(url, forKey: key).sink( receiveValue: {image  in
            DispatchQueue.main.async {
                if let image = image {
                    self.image = image
                } else {
                    // error, nil image returned
                    self.displayNoImageFound()
                }
            }
        })
    }
    
    func displayNoImageFound() {
        self.image = UIImage(named: "photo")
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}
