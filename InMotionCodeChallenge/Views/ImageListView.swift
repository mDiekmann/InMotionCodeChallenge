//
//  ImageListView.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/10/21.
//

import UIKit

class ImageListView: BaseView {

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    // setup view UI (Text, font, coloring, etc.) and add subviews
    override func setViews() {
        super.setViews()
        self.backgroundColor = .white
        self.addSubview(collectionView)
    }

    // set constraints and layout subviews
    override func layoutViews() {
        super.layoutViews()
        
        collectionView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }

}
