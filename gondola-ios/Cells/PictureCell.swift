//
//  PictureCell.swift
//  Gondola TVOS
//
//  Created by Chris on 10/02/2017.
//  Copyright © 2017 Chris Hulbert. All rights reserved.
//

import UIKit

class PictureCell: UICollectionViewCell {
    
    let image = UIImageView()
    let label = UILabel()
    
    var imagePath: String? // For checking for stale image loads on recycled cells.
    var imageAspectRatio: CGFloat = 1.5
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        image.contentMode = .scaleAspectFit
        addSubview(image)
        
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = K.labelFont
        addSubview(label)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        let h = bounds.height
        let labelHeight = ceil(K.labelFont.lineHeight)
        
        image.frame = CGRect(x: 0, y: 0, width: w, height: round(w * imageAspectRatio))
        label.frame = CGRect(x: 0, y: h - labelHeight, width: w, height: labelHeight)
    }
    
    /// Best height for the given width.
    /// Aspect ratio is such that when multiplied by width, it gives height.
    static func height(forWidth: CGFloat, imageAspectRatio: CGFloat) -> CGFloat {
        let labelHeight = ceil(K.labelFont.lineHeight)
        let imageHeight = round(forWidth * imageAspectRatio)
        return round(labelHeight * 1.5) + imageHeight
    }
    
    static func width(forHeight: CGFloat, imageAspectRatio: CGFloat) -> CGFloat {
        let labelHeight = ceil(K.labelFont.lineHeight)
        let imageHeight = forHeight - round(1.5 * labelHeight)
        return round(imageHeight / imageAspectRatio)
    }
    
    struct K {
        static let labelFont = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)
    }
        
}
