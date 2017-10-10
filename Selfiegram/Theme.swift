//
//  Theme.swift
//  Selfiegram
//
//  Created by Tim Nugent on 4/10/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import Foundation
// BEGIN theme_import
import UIKit
// END theme_import

// BEGIN theme_font_ext
extension UIFont {
    convenience init? (familyName: String, size: CGFloat = UIFont.systemFontSize, variantName: String? = nil) {
        // Note! This is how you'd figure out the internal font name
        // using code. However, it introduces a bug if there's more
        // than one font family that contains <fontName> in its name,
        // or if the first font found isn't what you'd expect.
        
        // We're doing it this way because otherwise we'd just be
        // showing you the internal font names of the fonts we're
        // using, and you wouldn't learn as much. In your real apps,
        // you should manually specify the font name.
        
        guard let name = UIFont.familyNames
            .filter ({ $0.contains(familyName) })
            .flatMap ({ UIFont.fontNames(forFamilyName: $0) })
            .filter({ variantName != nil ? $0.contains(variantName!) : true })
            .first else { return nil }
        
        self.init(name: name, size: size)
    }
}
// END theme_font_ext

// BEGIN theme_struct
struct Theme {
    // BEGIN theme_apply
    static func apply() {
        
        // BEGIN theme_font
        guard let headerFont = UIFont(familyName: "Lobster", size: UIFont.systemFontSize * 2) else {
            NSLog("Failed to load header font")
            return
        }
        
        guard let primaryFont = UIFont(familyName: "Quicksand") else {
            NSLog("Failed to load application font")
            return
        }
        // END theme_font
        
        // BEGIN theme_tinting
        let tintColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        
        UIApplication.shared.delegate?.window??.tintColor = tintColor
        // END theme_tinting
        
        // BEGIN theme_bulk
        let navBarLabel = UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        
        let barButton = UIBarButtonItem.appearance()
        
        let buttonLabel = UILabel.appearance(whenContainedInInstancesOf: [UIButton.self])
        
        let navBar = UINavigationBar.appearance()
        
        let label = UILabel.appearance()
        
        // theming the navigation bar
        navBar.titleTextAttributes = [.font: headerFont]
        
        navBarLabel.font = primaryFont
        
        // theming labels
        label.font = primaryFont
        
        // theming the buttons' text
        barButton.setTitleTextAttributes([.font: primaryFont], for: .normal)
        barButton.setTitleTextAttributes([.font: primaryFont], for: .highlighted)
        
        buttonLabel.font = primaryFont
        // END theme_bulk
    }
    // END theme_apply
}
// END theme_struct
