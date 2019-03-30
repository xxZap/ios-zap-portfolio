//
//  ZapStuff.swift
//  ZapAnimatableCell
//
//  Created by Alessio Boerio on 26/03/2019.
//  Copyright © 2019 Alessio Boerio. All rights reserved.
//

import Foundation
import UIKit

extension Collection where Indices.Iterator.Element == Index {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UIResponder {
    func z_next<T: UIResponder>(_ type: T.Type) -> T? {
        return next as? T ?? next?.z_next(type)
    }
}

extension String {
    func z_localized(withComment:String = "") -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: withComment)
    }
}

extension UITableViewCell {
    /// try to get the tableview from the superview
    var z_tableView: UITableView? {
        return z_next(UITableView.self)
    }

    /// try to get the real indexpath of the cell
    var z_indexPath: IndexPath? {
        return z_tableView?.indexPath(for: self)
    }
}

extension UIView {
    /// Apply `radius` rounded corner to the desired corners.
    ///
    /// - Parameters:
    ///   - corners: list of desired corner.
    ///   - radius: radius of the corner in points.
    func z_roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension UIApplication {
    /// Return, if possible, the view controller on the top of the screen.
    class func z_topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return z_topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return z_topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return z_topViewController(controller: presented)
        }
        return controller
    }
}

public extension UIAlertController {
    @discardableResult static func z_showProgressAlertController(in viewController: UIViewController, withTitle title: String, andMessage message: String, completion: ((UIAlertController) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message + "\n\n", preferredStyle: .alert)

        let spinnerIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .white)

        spinnerIndicator.center = CGPoint(x: 135.0, y: 85)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()

        alertController.view.addSubview(spinnerIndicator)
        alertController.view.frame.size.height += spinnerIndicator.frame.size.height + 5

        DispatchQueue.main.async {
            viewController.present(alertController, animated: true) {
                completion?(alertController)
            }
        }

        return alertController
    }

    static func z_dismissAlertController(_ alertController: UIAlertController, animated: Bool, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            alertController.dismiss(animated: animated, completion: completion)
        }
    }

    static func z_showOkAlertController(in viewController: UIViewController, withTitle title: String, andMessage message: String, completionHandler: (()->Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok".z_localized(), style: .cancel) { action in
            completionHandler?()
        })
        viewController.present(alertController, animated: true, completion: nil)
    }

    static func z_showYesNoAlertController(in viewController: UIViewController, withTitle title: String, andMessage message: String, yesButtonHandler: (()->Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No".z_localized(), style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes".z_localized(), style: .default) { action in
            yesButtonHandler?()
        })
        viewController.present(alertController, animated: true, completion: nil)
    }
}

extension UIColor {
    static func z_generateRandomPastelColor(withMixedColor mixColor: UIColor?) -> UIColor {
        // Randomly generate number in closure
        let randomColorGenerator = { ()-> CGFloat in
            CGFloat(arc4random() % 256 ) / 256
        }

        var red: CGFloat = randomColorGenerator()
        var green: CGFloat = randomColorGenerator()
        var blue: CGFloat = randomColorGenerator()

        // Mix the color
        if let mixColor = mixColor {
            var mixRed: CGFloat = 0, mixGreen: CGFloat = 0, mixBlue: CGFloat = 0;
            mixColor.getRed(&mixRed, green: &mixGreen, blue: &mixBlue, alpha: nil)

            red = (red + mixRed) / 2;
            green = (green + mixGreen) / 2;
            blue = (blue + mixBlue) / 2;
        }

        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
