//
//  ZInteractivePopupViewController.swift
//  Alitalia
//
//  Created by Alessio Boerio on 20/07/2018.
//  Copyright © 2019 Alessio Boerio. All rights reserved.
//

import Foundation
import UIKit

/// A ViewController that must be presented inside an **ZModalViewController**.
class ZModalChildViewController: UIViewController {
    /// The **ZModalViewController** who this view controller belong to
    weak var modalParentViewController: ZModalViewController?

    /// The delegate of this ZModalViewController
    public weak var delegate: ZModalDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    /// Returns the current **height** of this **ZModalChildViewController**.
    ///
    /// *Override* it if needed (example: tableview, collectionview or other view controllers with dynamic size)
    func getHeight() -> CGFloat { return self.view.frame.height }

    /// Returns the color that the `interactivePopupController` will use to paint the extra view in the bottom of the screen.
    func getBackgroundColor() -> UIColor? { return self.view.backgroundColor }

    /// By default it returns the `getBackgroundColor`
    func getTopBarColor() -> UIColor? { return getBackgroundColor() }

    /// By default is nil. If different, it will override the color of the line inside the `TopBarView`
    func getTopLineColor() -> UIColor? { return nil }

    /// If this ViewController has an **interactivePopupController** it will call the parent.dismiss.
    /// Otherwise it will dismiss normally.
    func dismiss(animated: Bool) {
        if let parent = modalParentViewController {
            parent.dismissPopup()
        } else {
            super.dismiss(animated: animated)
        }
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if let parent = modalParentViewController {
            parent.dismissPopup(animationTime: flag ? 0.5 : 0) {
                completion?()
            }
        } else {
            super.dismiss(animated: flag, completion: completion)
        }
    }
}

protocol ZModalDelegate: class {
    func ancillaryPopupIsCanceling(popupViewController: ZModalChildViewController)
    func ancillaryPopupHasMadeChanges(popupViewController: ZModalChildViewController)
}

/// This is a View Controller that comes from bottom and has vertical swipe gesture to handle the dismiss (animated).
///
/// Instantiate this through **ZModalChildViewController.instantiate()**.
///
/// It presents another sub-viewcontroller inside its `containerView`.
///
/// Add the desired sub-viewcontroller with **loadViewController()**
class ZModalViewController: UIViewController {

    /// The background of this ViewController. It's alpha will be animated.
    @IBOutlet weak fileprivate var viewBG: UIView!

    /// Useful empty view to calculate the space between the `containerView` and the top of the safe area.
    @IBOutlet weak fileprivate var availableSpaceView: UIView!

    /// A simple view who wraps the `topCornerView` and has pan gesture to move the `containerView` vertically.
    @IBOutlet weak fileprivate var draggableView: UIView!

    /// A little grey line on the top of the `draggableView`.
    //@IBOutlet weak fileprivate var littleLineView: UIView!

    /// A simple view between `containerView` and `availableSpaceView` with rounded corners.
    @IBOutlet weak fileprivate var topCornerView: UIView!

    /// A simple view anchored to the bottom of the `containerView` that becomes visible once the user swipe up.
    @IBOutlet weak fileprivate var outOfScreenView: UIView!

    /// This is the container view that contains the `subViewController`.
    @IBOutlet weak var containerView: UIView!

    /// This constraint allow this view controller to move the containerView vertically.
    @IBOutlet weak fileprivate var constraintFromBottom: NSLayoutConstraint!

    /// The height of the `containerView`.
    @IBOutlet weak fileprivate var containerViewHeightConstraint: NSLayoutConstraint!

    /// The line view to give a feedback to the user that the view is draggable.
    @IBOutlet weak fileprivate var handleView: UIView!

    /// The ViewController that is contained by `containerView`.
    weak var subViewController: ZModalChildViewController?

    // drag gesture stuff
    fileprivate var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)
    fileprivate var animationTime = 0.5
    fileprivate var backgroundMaxOpacity: CGFloat = 0.66
    fileprivate var viewIsDragging: Bool = false

    /// is the maximum height that will be used to calculate the return-bounce or the dismissable-distance.
    fileprivate var maxContainerHeight: CGFloat {
        get {
            return containerViewHeightConstraint.constant
        }
        set {
            containerViewHeightConstraint.constant = newValue
        }
    }

    /// a flag used to know if the from-bottom-to-top animation should be launced or not.
    /// by defult it becomes false after the first viewDidAppear()
    var isFirstAppearance: Bool = true

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadViewController(nil)
    }

    deinit {
        print("\(self.description): Deinit")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isFirstAppearance {
            topCornerView.setNeedsLayout()
            topCornerView.layoutIfNeeded()
            topCornerView.z_roundCorners([.topLeft, .topRight], radius: 10)
        }

        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowOffset = CGSize(width: 0, height: -topCornerView.frame.height)
        containerView.layer.shadowRadius = 10

        handleView.layer.cornerRadius = handleView.frame.height / 2
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstAppearance {
            isFirstAppearance = false
            updateContainer()
            setBottomConstraint(to: maxContainerHeight)
        }
    }

    // MARK: - Setup

    /// Configure and setup colors, localized strings, alpha, constraint, etc...
    private func setupUI() {
        // graphics
        viewBG.alpha = 0

        // actions
        draggableView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(draggableViewDidPan(_:))))
        containerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(draggableViewDidPan(_:))))
        availableSpaceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissDidTap(_:))))

        // constraints
        constraintFromBottom.constant = 0

        availableSpaceView.backgroundColor = UIColor.clear
        containerView.backgroundColor = UIColor.clear
    }

    // MARK: - Private functions

    /// Comunicate with `subViewController` to get its height and update the height of the `containerView`.
    /// Animated.
    fileprivate func updateContainer() {
        if let subViewController = self.subViewController {
            subViewController.modalParentViewController = self
            let subHeight = subViewController.getHeight()
            self.maxContainerHeight = subHeight
            self.outOfScreenView.backgroundColor = subViewController.getBackgroundColor()
            self.topCornerView.backgroundColor = subViewController.getTopBarColor()
            if let lineColor = subViewController.getTopLineColor() { self.handleView.backgroundColor = lineColor }
        } else {
            self.maxContainerHeight = 300
        }
    }

    /// Set the position of the MainView.
    ///
    /// - Parameter value: the desired position.
    fileprivate func setBottomConstraint(to value: CGFloat, animated: Bool = true, alpha: CGFloat = 1, duration: Double? = nil) {
        maxContainerHeight = value
        containerViewHeightConstraint.constant = maxContainerHeight
        constraintFromBottom.constant = maxContainerHeight
        if animated {
            UIView.animate(withDuration: duration ?? animationTime) { [weak self] in
                self?.viewBG.alpha = alpha
                self?.view.layoutIfNeeded()
            }
        } else {
            self.viewBG.alpha = alpha
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - IBAction

    /// The user tapped the `availableSpaceView`
    @objc func dismissDidTap(_ sender: UITapGestureRecognizer) {
        if !viewIsDragging {
            dismissPopup()
        }
    }

    /// The user is panning
    @objc func draggableViewDidPan(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)

        if sender.state == UIGestureRecognizer.State.began, !viewIsDragging {
            viewIsDragging = true
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizer.State.changed, sender.numberOfTouches == 1 {
            if touchPoint.y - initialTouchPoint.y > 0 {
                constraintFromBottom.constant =  maxContainerHeight - (touchPoint.y - initialTouchPoint.y)
                let alfaPan = 1 - ((maxContainerHeight - constraintFromBottom.constant) / maxContainerHeight)
                viewBG.alpha = alfaPan
            } else {
                constraintFromBottom.constant =  maxContainerHeight - (touchPoint.y - initialTouchPoint.y) * 0.5
                self.view.layoutIfNeeded()
            }
        } else if sender.state == UIGestureRecognizer.State.ended || sender.state == UIGestureRecognizer.State.cancelled {
            if sender.numberOfTouches == 0 {
                viewIsDragging = false
                if touchPoint.y - initialTouchPoint.y > 150 {
                    let animationPerc = Double(1 - ((maxContainerHeight - constraintFromBottom.constant) / maxContainerHeight))
                    self.dismissPopup(animationTime: animationTime * animationPerc)
                } else {
                    self.constraintFromBottom.constant = maxContainerHeight
                    UIView.animate(withDuration: animationTime, animations: { [weak self] in
                        self?.view.layoutIfNeeded()
                    })
                }
            }
        }
    }

    // MARK: - Methods

    /// Set the color of the top draggable view.
    func setTopViewBackgroundColor(toColor color: UIColor) {
        topCornerView.backgroundColor = color
    }

    /// Use this to force a reload of the `subViewController` and adapt the `containerView` to the new height (animated).
    ///
    /// This method will change constraints.
    func forceReload() {
        updateContainer()
        setBottomConstraint(to: self.maxContainerHeight)
    }

    /// Set constraintBottom as the sum of all visible view heights.
    ///
    /// - Parameter duration: the animation time. If nil, `animationTime` will be used.
    func expandToFitScreen(withDuration duration: Double? = nil) {
        let availableSpace = getAvailableSpace()
        let newHeight = maxContainerHeight + availableSpace
        setBottomConstraint(to: newHeight, duration: duration)
    }

    /// Returns the space between the top of the current popup view and the height of this view controller.
    /// It's useful to know the max height the popup can extend.
    func getAvailableSpace() -> CGFloat {
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        let totalAvailableSpace = availableSpaceView.frame.size.height// + draggableView.frame.size.height
        return totalAvailableSpace
    }

    /// Set the background color of the view anchored to the bottom of the `containerView`.
    /// *Default* is **UIColor.white**
    ///
    /// - Parameter color: the desired color.
    func setOffScreenColor(_ color: UIColor?) {
        outOfScreenView.backgroundColor = color ?? UIColor.white
    }

    /// Dismiss this view controller.
    func dismissPopup(animationTime: Double = 0.5, onCompletionBeforeDismiss: (() -> Void)? = nil) {
        self.constraintFromBottom.constant = 0
        UIView.animate(withDuration: animationTime, animations: { [weak self] in
            self?.viewBG.alpha = 0
            self?.containerView.layoutIfNeeded()
            self?.view.layoutIfNeeded()
        }, completion: { [weak self] (_) in onCompletionBeforeDismiss?()
            self?.dismiss(animated: false, completion: nil)
        })
    }

    /// Instantiate a new ViewController inside the `containerView`.
    /// If a view controller already exists, it will be dismissed before instantiate the new one.
    ///
    /// - Parameter newSubViewController: the new sub view controller that we want to put inside the `contentView`.
    func loadViewController(_ newSubViewController: ZModalChildViewController?) {
        // nice trick to load view hierarchy and avoid nil iBOutlet references
        _ = self.view

        guard let newSubViewController = newSubViewController else { return }

        // remove old childViewController
        if let oldVC = self.children.last {
            oldVC.willMove(toParent: nil)
            oldVC.view.removeFromSuperview()
            oldVC.removeFromParent()
        }

        self.addChild(newSubViewController)
        newSubViewController.view.frame = CGRect(
            x: 0,
            y: 0,
            width: self.containerView.frame.size.width,
            height: self.containerView.frame.size.height)
        self.containerView.addSubview(newSubViewController.view)
        newSubViewController.didMove(toParent: self)

        _ = newSubViewController.view
        self.subViewController = newSubViewController
        self.subViewController?.modalParentViewController = self

        self.setOffScreenColor(newSubViewController.view.backgroundColor)
    }
}
