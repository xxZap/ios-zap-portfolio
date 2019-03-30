//
//  ZTheme.swift
//  ZapAnimatableCell
//
//  Created by Alessio Boerio on 26/03/2019.
//  Copyright © 2019 Alessio Boerio. All rights reserved.
//

import Foundation
import UIKit

class ZTheme {
    // MARK: - LAYER
    static var cornerRadius: CGFloat {
        return 7
    }

    // MARK: - GLOBAL
    /// The basic background color for a view controller
    static var viewControllerBackgroundColor: UIColor {
        return UIColor.white
    }
}

// MARK: - Palette Color
extension ZTheme {
    class PaletteColor {
        /// The primary color
        static var primaryColor: UIColor {
            return UIColor(red: 87.0/255.0, green: 152.0/255.0, blue: 118.0/255.0, alpha: 1)
        }
        /// The color similar to the primaryColor **slightly darker**
        static var accentColor: UIColor {
            return UIColor(red: 42.0/255.0, green: 113.0/255.0, blue: 117.0/255.0, alpha: 1)
        }
        /// The color similar to the primaryColor **slightly lighter**
        static var lightVariant: UIColor {
            return UIColor(red: 174.0/255.0, green: 187.0/255.0, blue: 111.0/255.0, alpha: 1)
        }
        /// The color similar to the primaryColor **darker**
        static var darkVariant: UIColor {
            return UIColor(red: 47.0/255.0, green: 72.0/255.0, blue: 88.0/255.0, alpha: 1)
        }

        /// Green/Success color
        static var positiveColor: UIColor {
            return UIColor(red: 127.0/255.0, green: 169.0/255.0, blue: 112.0/255.0, alpha: 1)
        }
        /// Red/Failure color
        static var negativeColor: UIColor {
            return UIColor(red: 230.0/255.0, green: 132.0/255.0, blue: 87.0/255.0, alpha: 1)
        }
    }
}

// MARK: - Shadow
extension ZTheme {
    class Shadow {
        /// The color for the view which has the shadow
        static var contentColor: UIColor {
            return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        }
        /// The color for a shadow with a theoretical opacity 1.0
        static var color: CGColor {
            return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
        }
        /// The default shadow opacity.
        static var opacity: Float {
            return 0.2
        }
        /// The default shadow offset.
        static var offset: CGSize {
            return CGSize.zero
        }
        /// The default shadow radius.
        static var radius: CGFloat {
            return 10
        }
    }
}

// MARK: - Text
extension ZTheme {
    class Text {
        /// Used for dark label (bold, important, ....)
        static var mainColor: UIColor {
            return UIColor(red: 47.0/255.0, green: 72.0/255.0, blue: 88.0/255.0, alpha: 1)
        }
        /// Used for normal label
        static var secondaryColor: UIColor {
            return UIColor(red: 117.0/255.0, green: 103.0/255.0, blue: 121.0/255.0, alpha: 1)
        }
    }
}
