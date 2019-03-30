//
//  ZSwipableTableViewCell.swift
//  ZapAnimatableCell
//
//  Created by Alessio Boerio on 26/03/2019.
//  Copyright © 2019 Alessio Boerio. All rights reserved.
//

import Foundation
import UIKit

protocol ZSwipableTableViewCellDelegate: ZAnimatableTableViewCellDelegate {
    /// The passed cell just started moving because of the swipe action.
    func swipeDidBegun(onCell cell: ZSwipableTableViewCell)
    /// The secret button under the main view has been pressed by the user.
    func swipeBackgroundButtonDidTap(onCell cell: ZSwipableTableViewCell)
}

extension ZSwipableTableViewCellDelegate {
    func swipeDidBegun(onCell cell: ZSwipableTableViewCell) {}
    func swipeBackgroundButtonDidTap(onCell cell: ZSwipableTableViewCell) {}
}

/// This table view cell is a ZAnimatableTableViewCell.
///
/// Define all the stored properties and Outlet to enable the horizontal swipe for this cell.
/// The main behaviour is:
///     the row follows your finger horizontally while the `swipableBackgroundView` will move in opposite direction.
///     In this way seems that the row is moving and but the backgroundView nope. (it's an optical illusion because it's moving with -delta).
///
class ZSwipableTableViewCell: ZAnimatableTableViewCell {
    /// The view under everything that will move in opposite direction (will remain still in the screen)
    @IBOutlet weak var swipableBackgroundView: UIView!

    /// Fix your `swipableBackgroundView` with a left constraint to superview and set this outlet to it.
    @IBOutlet weak var swipableBackgroundLeftConstraint: NSLayoutConstraint!

    /// The view that will move following the finger pan.
    internal var swipableView: UIView { return self.contentView }
    /// The origin of the `swipableView`. Useful to restore its position.
    internal var swipableOriginalPosition: CGPoint { return CGPoint(x: swipableView.frame.size.width / 2, y: swipableView.frame.size.height / 2) }
    /// If **true**, the swipe is actually acting.
    internal var swipableRowIsOpened: Bool { return swipableView.center != swipableOriginalPosition }
    /// The default position of the `swipableBackgroundView`. Useful to restore its position.
    internal var swipableBackgroundLeftConstraintDefaultValue: CGFloat = 0
    /// Define as you need.
    /// After this distance, the `swipableView` will lock and does not return to default position after the finger release.
    internal var swipableLockDistance: CGFloat { return 50 }
    /// Define as you need.
    /// If **true**, the swipe action is enabled.
    internal func swipePanIsActive() -> Bool { return true }
    /// This value becomes **true** a first time during *touchesBegan* if the touch location is inside the `swipableBackgroundView`.
    /// On *touchesEnded* and *touchesCanceled*, if this value was **true** and `swipableRowIsOpened`, it will be called the
    /// ```swipeBackgroundButtonDidTap``` of the delegate.
    /// In other cases it will be called the ```cellTapAnimationDidComplete```
    internal var areSwipableButtonsBeenTapped: Bool = false

    weak var swipableDelegate: ZSwipableTableViewCellDelegate?

    /// This method handle all the gesture for the swipe behaviour.
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard swipePanIsActive() else { return }

        switch gestureRecognizer.state {
        case .began:
            swipePanBegan(onPoint: self.swipableView.center, fromGestureRecognizer: gestureRecognizer)
        case .changed:
            swipePanChanged(by: gestureRecognizer.translation(in: self.swipableView), fromGestureRecognizer: gestureRecognizer)
        default:
            if swipePanExceedsRight() {
                swipePanLockRight()
            } else if swipePanExceedsLeft() {
                swipePanLockLeft()
            } else {
                swipePanReturnToCenter()
            }
        }
    }

    /// This method is called after the UIPanGestureRecognizer.state.began.
    /// If you need, you can define the operation that should be done before the swipe starts.
    internal func swipePanBegan(onPoint point: CGPoint, fromGestureRecognizer gestureRecognizer: UIPanGestureRecognizer) {
        swipableDelegate?.swipeDidBegun(onCell: self)
    }

    /// This method is called after the UIPanGestureRecognizer.state.changed.
    /// This method moves the swipableView by delta and the `swipableBackgroundView` by -delta.
    internal func swipePanChanged(by translation: CGPoint, fromGestureRecognizer gestureRecognizer: UIPanGestureRecognizer) {
        swipableView.center = CGPoint(x: swipableView.center.x + translation.x, y: swipableView.center.y)
        swipableBackgroundLeftConstraint.constant = swipableBackgroundLeftConstraint.constant - translation.x
        gestureRecognizer.setTranslation(CGPoint.zero, in: self)
    }

    //              +- - - -+---------------+
    //              |///////|    name     x | --->
    //              +- - - -+---------------+
    //                     ???
    /// If **true**, the `swipableView` is beyond the right limit (defined by `self.swipableLockDistance`)
    internal func swipePanExceedsRight() -> Bool {
        return swipableView.center.x > swipableOriginalPosition.x + swipableLockDistance
    }

    //      +---------------+- - - -+
    // <--- |    name     x |///////|
    //      +---------------+- - - -+
    //                     ???
    /// If **true**, the `swipableView` is beyond the left limit (defined by `-self.swipableLockDistance`)
    internal func swipePanExceedsLeft() -> Bool {
        return swipableView.center.x < swipableOriginalPosition.x - swipableLockDistance
    }

    //          --> +---------------+ <--
    //          --> |    name     x | <--
    //          --> +---------------+ <--
    //                  --->|<---
    /// Call this to reset both the `swipableView` and `swipableBackgroundView` to default position animated.
    internal func swipePanReturnToCenter() {
        swipableBackgroundLeftConstraint.constant = swipableBackgroundLeftConstraintDefaultValue
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            guard let aliveSelf = self else { return }
            aliveSelf.swipableView.center = CGPoint(x: aliveSelf.swipableOriginalPosition.x, y: aliveSelf.swipableView.center.y)
            aliveSelf.layoutIfNeeded()
            }, completion: nil)
    }

    //              +- - - -+---------------+
    //              |///////|    name     x |
    //              +- - - -+---------------+
    //                  ---> <---
    /// Call this to lock the `swipableView` to the left limit (defined by `-self.swipableLockDistance`)
    internal func swipePanLockRight() {
        swipableBackgroundLeftConstraint.constant = swipableBackgroundLeftConstraintDefaultValue - swipableLockDistance
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            guard let aliveSelf = self else { return }
            aliveSelf.swipableView.center = CGPoint(x: aliveSelf.swipableOriginalPosition.x + aliveSelf.swipableLockDistance, y: aliveSelf.swipableView.center.y)
            aliveSelf.layoutIfNeeded()
            }, completion: nil)
    }

    //      +---------------+- - - -+
    //      |    name     x |///////|
    //      +---------------+- - - -+
    //                  ---> <---
    /// Call this to lock the `swipableView` to the right limit (defined by `self.swipableLockDistance`)
    internal func swipePanLockLeft() {
        swipableBackgroundLeftConstraint.constant = swipableBackgroundLeftConstraintDefaultValue + swipableLockDistance
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            guard let aliveSelf = self else { return }
            aliveSelf.swipableView.center = CGPoint(x: aliveSelf.swipableOriginalPosition.x - aliveSelf.swipableLockDistance, y: aliveSelf.swipableView.center.y)
            aliveSelf.layoutIfNeeded()
            }, completion: nil)
    }

    /// This is to avoid that the swipe gesture locks useful behavior as the tableview scrolling action
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // this is to let the pan gesture to don't lock the scroll of the tableview.
        if swipePanIsActive(), let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: self)
            if abs(velocity.x) > abs(velocity.y) {
                return true
            }
        }
        return false
    }
}

// MARK: - PanGesture - for swipe behaviour
extension ZSwipableTableViewCell {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // if the touch is starting inside one of the enable/disable button, set `areSwipableButtonsBeenTapped` to true.
        if let touch = touches.first, swipableRowIsOpened {
            let superLocation = touch.location(in: swipableView)
            if !swipableView.frame.contains(superLocation) {
                let backgroundLocation = touch.location(in: swipableBackgroundView)
                if swipableBackgroundView.frame.contains(backgroundLocation) {
                    areSwipableButtonsBeenTapped = true
                }
            }
        }
        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        areSwipableButtonsBeenTapped = hasSwipableBackgroundViewCompletedTheTap(with: touches)
        if areSwipableButtonsBeenTapped, let swipableDelegate = self.swipableDelegate {
            restoreViewAnimated()
            swipableDelegate.swipeBackgroundButtonDidTap(onCell: self)
        } else {
            if swipableRowIsOpened {
                swipePanReturnToCenter()
            }
            super.touchesEnded(touches, with: event)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        areSwipableButtonsBeenTapped = hasSwipableBackgroundViewCompletedTheTap(with: touches)
        if areSwipableButtonsBeenTapped, let _ = self.swipableDelegate {
            restoreViewAnimated()
        } else {
            if swipableRowIsOpened {
                swipePanReturnToCenter()
            }
            super.touchesCancelled(touches, with: event)
        }
    }

    /// Return **true** if the tap Began and Ended inside a enable/disable button.
    internal func hasSwipableBackgroundViewCompletedTheTap(with touches: Set<UITouch>) -> Bool {
        if let touch = touches.first, swipableRowIsOpened, areSwipableButtonsBeenTapped {
            var isTouchingTheSwipeButton = false
            let superLocation = touch.location(in: swipableView)
            if !swipableView.frame.contains(superLocation) {
                let backgroundLocation = touch.location(in: swipableBackgroundView)
                if swipableBackgroundView.frame.contains(backgroundLocation) {
                    isTouchingTheSwipeButton = true
                }
            }

            return isTouchingTheSwipeButton
        }
        return false
    }
}
