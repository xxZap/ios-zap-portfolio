//
//  ZTagView.swift
//  ZapAnimatableCell
//
//  Created by Alessio Boerio on 30/03/2019.
//  Copyright © 2019 Alessio Boerio. All rights reserved.
//

import Foundation
import UIKit

class ZTagView: UIView {
    // MARK: - Outlets
    @IBOutlet internal weak var button: UIButton!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        button.layer.cornerRadius = button.frame.height / 2
    }

    // MARK: - Public methods
    func setTag(withText text: String, andColor color: UIColor? = nil) {
        button.setTitle(text, for: .normal)
        if let color = color {
            button.backgroundColor = color
        }
    }
}
