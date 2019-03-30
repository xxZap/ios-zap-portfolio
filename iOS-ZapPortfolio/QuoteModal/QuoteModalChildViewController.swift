//
//  QuoteModalChildViewController.swift
//  ZapAnimatableCell
//
//  Created by Alessio Boerio on 28/03/2019.
//  Copyright © 2019 Alessio Boerio. All rights reserved.
//

import Foundation
import AlamofireImage

/// This view controller shows a random picture and a random quote.
///
/// It uses 2 free API services to retrieve this objects:
/// - **Lorempixel**: random image.
///     http://lorempixel.com
///
/// - **Opinionated Quote**: random quote.
///     https://opinionated-quotes-api.gigalixirapp.com
class QuoteModalChildViewController: ZModalChildViewController {

    // MARK: - Outlets
    /// The view whose height is passed to the `modalParentViewController` to calculate the correct size to be shown.
    @IBOutlet weak var mainContent: UIView!
    /// The title of the text this view controller is showing.
    @IBOutlet weak var titleLabel: UILabel!
    /// The image this view controller is showing.
    @IBOutlet weak var photoImageView: UIImageView!
    /// The stack view which contains the quote's tags.
    @IBOutlet weak var tagsView: UIStackView!
    /// A thin view between `randomTextLabel` and its title.
    @IBOutlet weak var separatorLine: UIView!
    /// The text this view controller is showing.
    @IBOutlet weak var randomTextLabel: UILabel!

    /// The quote to represent.
    var quote: ZQuote?

    // MARK: - variables
    /// The url to be called to retrieve a random image. I'm using the free Lorempixel service.
    internal let placeholderURLString: String = "http://lorempixel.com/640/360/nature"

    // MARK: - ZModalChildViewController overrides
    override func getTopBarColor() -> UIColor? { return ZTheme.PaletteColor.primaryColor }
    override func getTopLineColor() -> UIColor? { return UIColor.white }
    override func getHeight() -> CGFloat { return min(mainContent.frame.height, UIScreen.main.bounds.height - 100) }

    // MARK: - Life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureQuote()
    }

    deinit {
        clearCache()
        print("\(self): Deinit")
    }
}

// MARK: - Private functions
extension QuoteModalChildViewController {
    /// Configure the graphic of this ViewController
    internal func setupUI() {
        photoImageView.layer.masksToBounds = true
        photoImageView.layer.cornerRadius = ZTheme.cornerRadius
        if let url = URL(string: placeholderURLString) {
            photoImageView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main,
                                       imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false, completion: nil)
        }

        titleLabel.textColor = UIColor.white
        separatorLine.backgroundColor = ZTheme.PaletteColor.lightVariant
        randomTextLabel.textColor = ZTheme.Text.mainColor
    }

    /// Clear the cache of Alamofire Image
    internal func clearCache() {
        guard let url = URL(string: placeholderURLString) else { return }
        let urlRequest = URLRequest(url: url)
        let imageDownloader = UIImageView.af_sharedImageDownloader
        if let imageCache = imageDownloader.imageCache {
            _ = imageCache.removeImage(for: urlRequest, withIdentifier: nil)
        }
    }

    internal func configureQuote() {
        titleLabel.text = quote?.author ?? "Title"
        randomTextLabel.text = quote?.quote ?? "Random quote here"
        for child in tagsView.subviews {
            child.removeFromSuperview()
        }
        for tag in quote?.tags ?? [] {
            addTag(withText: tag)
        }

        view.setNeedsLayout()
        view.setNeedsUpdateConstraints()
        view.layoutIfNeeded()
    }

    internal func addTag(withText tag: String) {
        if let newTagView = ZTagView.fromNib() {
            newTagView.setTag(withText: tag, andColor: UIColor.z_generateRandomPastelColor(withMixedColor: ZTheme.PaletteColor.accentColor))
            tagsView.addArrangedSubview(newTagView)
        }
    }
}
