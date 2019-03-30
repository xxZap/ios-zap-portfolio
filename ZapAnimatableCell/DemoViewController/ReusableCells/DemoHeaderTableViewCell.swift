//
//  DemoHeaderTableViewCell.swift
//  ZapAnimatableCell
//
//  Created by Alessio Boerio on 26/03/2019.
//  Copyright © 2019 Alessio Boerio. All rights reserved.
//

import Foundation
import UIKit

class DemoHeaderTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    // MARK: - Life-cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = ZTheme.Text.mainColor
        subtitleLabel.textColor = ZTheme.Text.secondaryColor

        titleLabel.text = "Header Title"
        subtitleLabel.text = "This is a subtitle. It's under the title and you can see me and watch me and read me with your eyes."
    }
}
