//
//  DemoTableViewCell.swift
//  ZapAnimatableCell
//
//  Created by Alessio Boerio on 26/03/2019.
//  Copyright © 2019 Alessio Boerio. All rights reserved.
//

import Foundation
import UIKit

//          .--------------------------------------------.
//    <--|| |                                            |
//    <--|| |   /  \    MAIN TITLE                       |
//          |   \  /    description label                | ||-->
//          |                                            | ||-->
//          '--------------------------------------------'
class DemoTableViewCell: ZSwipableTableViewCell {
    enum DemoCellStatus {
        case animatable(enabled: Bool)
        case swipable(selected: Bool)
    }

    // MARK: - Outlets
    /// The view where all the real stuff are stored.
    @IBOutlet weak var content: UIView!
    /// A view with same size/position of `content` in the background which has the shadow.
    @IBOutlet weak var contentShadow: UIView!

    /// The view on the left which contains the `pictureImageView`.
    @IBOutlet weak var pictureView: UIView!
    /// The image in the center of the `pictureView`.
    @IBOutlet weak var pictureImageView: UIImageView!
    /// The little view inside `pictureView` which will change its color based on the status selected/not selected of this view
    @IBOutlet weak var selectedView: UIView!
    /// The main label on the center of the view.
    @IBOutlet weak var titleLabel: UILabel!
    /// The label below the `titleLabel`. It contains secondary information and has a lighter color.
    @IBOutlet weak var descriptionLabel: UILabel!

    /// The icons on the background which will be visible during swipe gesture.
    @IBOutlet var undergroundIcons: [UIImageView]!
    /// The labels on the background which will be visible during swipe gesture.
    @IBOutlet var undergroundLabels: [UILabel]!

    // MARK: - Variables
    /// The object that this cell should represent.
    internal(set) var status: DemoCellStatus = .animatable(enabled: true)

    // MARK: - Swipable
    override var swipableLockDistance: CGFloat { return 65 }
    override func swipePanIsActive() -> Bool {
        switch self.status {
        case .swipable:   return true
        default:          return false
        }
    }

    // MARK: - Life-cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        content.layer.cornerRadius = ZTheme.cornerRadius

        contentShadow.backgroundColor      = ZTheme.Shadow.contentColor
        contentShadow.layer.shadowColor    = ZTheme.Shadow.color
        contentShadow.layer.shadowOpacity  = ZTheme.Shadow.opacity
        contentShadow.layer.shadowOffset   = ZTheme.Shadow.offset
        contentShadow.layer.shadowRadius   = ZTheme.Shadow.radius

        titleLabel.textColor        = ZTheme.Text.mainColor
        descriptionLabel.textColor  = ZTheme.Text.secondaryColor

        content.backgroundColor = UIColor.white

        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        swipableView.addGestureRecognizer(panGesture)
        swipableBackgroundLeftConstraintDefaultValue = swipableBackgroundLeftConstraint.constant
        swipableBackgroundView.layer.cornerRadius = ZTheme.cornerRadius
        swipableBackgroundView.backgroundColor    = ZTheme.Text.mainColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pictureView.layer.cornerRadius = pictureView.frame.height / 2
        selectedView.layer.cornerRadius = selectedView.frame.height / 2
    }

    // MARK: - Public methods
    /// Configure this cell passing the desired object.
    /// It will setup its own graphics and behaviour according to the passed status.
    func configure(withStatus status: DemoCellStatus) {
        self.status = status
        switch self.status {
        case .animatable(let enabled):
            touchAnimationIsActive = enabled
            setupSelectedView(visible: true, selected: enabled)
            setupPicture(selected: enabled, iconName: "ic-touch")
            setupTitle(text: "Animatable Cell")
            setupDescription(text: enabled ? "enabled" : "disabled")
            setupContentAlpha(toValue: enabled ? 1 : 0.25)

        case .swipable(let selected):
            touchAnimationIsActive = selected
            setupSelectedView(visible: true, selected: selected)
            setupPicture(selected: selected, iconName: "ic-swipe")
            setupTitle(text: "Swipable Cell")
            setupDescription(text: selected ? "selected" : "unselected")
            setupBackgroundView(selected: selected)
            setupContentAlpha(toValue: selected ? 1 : 0.25)
        }

        swipableBackgroundView.isHidden = true
        swipableBackgroundLeftConstraint.constant = swipableBackgroundLeftConstraintDefaultValue
        setNeedsLayout()
        layoutIfNeeded()
        swipableView.center = swipableOriginalPosition
        swipableBackgroundView.isHidden = false
    }
}

// MARK: - Private functions
extension DemoTableViewCell {
    /// Configure the status of the `selectedView`
    ///
    /// - Parameters:
    ///   - visible: if `selectedView` should be visible or not.
    ///   - selected: determines the background color of `selectedView`.
    internal func setupSelectedView(visible: Bool, selected: Bool) {
        selectedView.isHidden = !visible
        selectedView.backgroundColor = selected ? ZTheme.PaletteColor.positiveColor : UIColor.gray
    }

    /// Configure the background view visible during the swipe gesture.
    /// It changes the button icons and the label showed below according to the `selected` passed parameter.
    ///
    /// - Parameters:
    ///   - selected:
    ///     if **true**, the elements contained in the `swipableBackgroundView` will assume the "disable" appearance.
    ///     if **false**, the "enable" one.
    internal func setupBackgroundView(selected: Bool) {
        for icon in undergroundIcons {
            icon.image = selected ? UIImage(named: "ic-close") : UIImage(named: "ic-check")
        }
        for label in undergroundLabels {
            label.text = selected ? "Disable" : "Enable"
        }
        swipableBackgroundView.backgroundColor = selected ? ZTheme.PaletteColor.negativeColor : ZTheme.PaletteColor.positiveColor
    }

    /// Configure the picture group of views.
    ///
    /// - Parameters:
    ///   - selected: if **true** it will be full alpha and colored. If **false** will be transparent and grey.
    ///   - iconName: the name of the graphic resource to load and apply inside `pictureImageView`.
    internal func setupPicture(selected: Bool, iconName: String) {
        pictureView.backgroundColor = selected ? ZTheme.PaletteColor.primaryColor : UIColor.gray
        pictureImageView.image = UIImage(named: iconName)
    }

    /// Configure the main label of this view.
    ///
    /// - Parameter text: the text to be showed.
    internal func setupTitle(text: String?) {
        titleLabel.text = text
    }

    /// Configure the secondary label below the main one.
    ///
    /// - Parameter text: the text to be showed.
    internal func setupDescription(text: String) {
        descriptionLabel.text = text
    }

    /// Set the alpha value to each subview of `swipableView`
    internal func setupContentAlpha(toValue value: CGFloat) {
        titleLabel.alpha = value
        descriptionLabel.alpha = value
        pictureView.alpha = value
    }
}
