//
//  Theme.swift
//  Selfiegram
//
//  Created by Tim Nugent on 4/10/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    /// returns the first font that matches the font name
    /// - parameter familyName: the font family name you are after, eg Lobster
    /// - parameter size: the size of the font, defaults to system font size if not specified
    /// = parameter variantName: the variant of the font desired, such as bold
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

/// Container struct for the theme.
/// Should only be called through the static apply function.
struct Theme {
    /// Applies the theme to the application,
    /// sets fonts and colours.
    /// To be called on application launch.
    static func apply() {
        
        guard let headerFont = UIFont(familyName: "Lobster", size: UIFont.systemFontSize * 2) else {
            NSLog("Failed to load header font")
            return
        }
        
        guard let primaryFont = UIFont(familyName: "Quicksand") else {
            NSLog("Failed to load application font")
            return
        }
        
        let tintColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        
        UIApplication.shared.delegate?.window??.tintColor = tintColor
        
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
    }
}
