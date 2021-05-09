//
//  Fonts.swift
//  gondola-ios
//
//  Created by Chris on 9/5/21.
//  Copyright © 2021 Gondola. All rights reserved.
//

import UIKit

extension UIFont {

    fileprivate static func brandFont(ofSize size: CGFloat, weight: Weight) -> UIFont {
        let name: String
        switch weight {
        case .regular: name = "Barlow-Regular"
        case .semibold: name = "Barlow-SemiBold"
        default:
            return systemFont(ofSize: size, weight: weight)
        }
        return UIFont(name: name, size: size) ?? systemFont(ofSize: size, weight: weight)
    }

    static let navTitle = UIFont.brandFont(ofSize: 20, weight: .semibold)
    static let barButton = UIFont.brandFont(ofSize: 16, weight: .regular)
    static let tabItem = UIFont.brandFont(ofSize: 13, weight: .regular)
    
}
