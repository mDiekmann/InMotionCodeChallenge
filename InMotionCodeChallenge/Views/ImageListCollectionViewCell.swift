//
//  ImageListCollectionViewCell.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/10/21.
//

import UIKit

class ImageListCollectionViewCell: UICollectionViewCell {
    static var identifier: String = "ImageListCollectionViewCell"
    
    private let imageView: RemoteImageView = {
        let iv = RemoteImageView()
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    var image: Image? {
        didSet {
            if let imageUrlStr = image?.imageUrl,
               let imageId = image?.id {
                imageView.loadImageFromURL(imageUrlStr, withCacheKey: imageId)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        self.backgroundColor = .red
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        image = nil
    }
}
