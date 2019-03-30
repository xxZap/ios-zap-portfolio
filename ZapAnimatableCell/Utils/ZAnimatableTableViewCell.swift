//
//  ZAnimatableTableViewCell.swift
//  ZapAnimatableCell
//
//  Created by Alessio Boerio on 26/03/2019.
//  Copyright © 2019 Alessio Boerio. All rights reserved.
//

import Foundation
import UIKit

protocol ZAnimatableTableViewCellDelegate: class {
    func cellTapAnimationDidComplete(onCell cell: UITableViewCell)
}

/// This TableViewCell change its scale during the touch to give a bouncing animation.
/// By default it animate all the TableViewCell content but if you want you can set the `animatableView` and only that view will be animated.
class ZAnimatableTableViewCell: UITableViewCell {

    /// If you want to animate only a particular view and not all the content of the tableview, you can assign that view to this variable
    var animatableView: UIView?
    var targetScaleX: CGFloat = 0.96
    var targetScaleY: CGFloat = 0.96

    /// Called when the user taps this cell
    weak var animatableDelegate: ZAnimatableTableViewCellDelegate?
    var touchAnimationIsActive: Bool = true

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard touchAnimationIsActive else { return }
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            guard let aliveSelf = self else { return }
            let view = aliveSelf.animatableView ?? aliveSelf
            view.transform = CGAffineTransform(scaleX: aliveSelf.targetScaleX, y: aliveSelf.targetScaleY)
            }, completion: nil)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard touchAnimationIsActive else { return }
        restoreViewAnimated()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard touchAnimationIsActive else { return }
        restoreViewAnimated { [weak self] in
            guard let aliveSelf = self else { return }
            aliveSelf.animatableDelegate?.cellTapAnimationDidComplete(onCell: aliveSelf)
        }
    }

    internal func restoreViewAnimated(completion: (()->())? = nil) {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            guard let aliveSelf = self else { return }
            let view = aliveSelf.animatableView ?? aliveSelf
            view.transform = CGAffineTransform.identity
            }, completion: { completed in
                completion?()
        })
    }
}
