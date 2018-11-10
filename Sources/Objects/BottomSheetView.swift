//
//  BottomSheetView.swift
//  MapKitSearchView
//
//  Created by Philip on 10/11/18.
//  Copyright © 2018 Next Generation. All rights reserved.
//

import UIKit

class BottomSheetView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topRight, .topLeft],
            cornerRadii: CGSize(width: 16, height: 16))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
        layer.borderColor = UIColor(white: 0, alpha: 0.11).cgColor
    }
}

class BottomSheetShadowView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 5
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topRight, .topLeft],
            cornerRadii: CGSize(width: 17, height: 17)).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
