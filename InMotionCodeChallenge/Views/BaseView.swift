//
//  BaseView.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/7/21.
//

import UIKit

class BaseView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        setViews()
        layoutViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setViews()
        layoutViews()
    }

    // setup view UI (Text, font, coloring, etc.) and add subviews
    func setViews() {}

    // set constraints and layout subviews
    func layoutViews() {}
}
