//
//  DemoViewController.swift
//  ZapAnimatableCell
//
//  Created by Alessio Boerio on 26/03/2019.
//  Copyright © 2019 Alessio Boerio. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {

    enum Section {
        case header
        case animatable(enabled: Bool)
        case swipable(selected: Bool)
    }

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    internal var sections: [Section] = []
    /// The service used to retrieve random quote.
    internal let quoteService: QuoteService = QuoteService()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateSection()
        setupTableView()
    }
}

// MARK: - Private functions

extension DemoViewController {
    /// Restore `self.sections` to default value.
    internal func updateSection() {
        self.sections = [
            .header,
            .animatable(enabled: true),
            .animatable(enabled: false),
            .swipable(selected: true),
            .swipable(selected: false)
        ]
    }

    internal func setupUI() {
        self.view.backgroundColor = ZTheme.viewControllerBackgroundColor
        self.title = "ZAP DEMO"
    }

    internal func setupTableView() {
        tableView.registerCellNib(DemoTableViewCell.self)
        tableView.registerCellNib(DemoHeaderTableViewCell.self)
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
    }

    internal func openQuoteVC(withQuote quote: ZQuote?) {
        guard let quote = quote, let viewController = ZModalViewController.fromNib() else { return }
        let childVC = DemoOptionViewController.fromNib()
        childVC?.quote = quote
        viewController.loadViewController(childVC)
        viewController.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(viewController, animated: false, completion: nil)
    }

    internal func getQuote() {
        quoteService.getRandomQuote { [weak self] result in
            guard let _ = self else { return }
            switch result {
            case .found(let quotes):
                DispatchQueue.main.async { [weak self] in
                    guard let aliveSelf = self else { return }
                    aliveSelf.openQuoteVC(withQuote: quotes.first)
                }

            case .notFound(let error):
                print("\(error)")
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension DemoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = sections[safe: indexPath.row] else { return UITableViewCell() }

        switch section {
        case .header:
            if let header = tableView.dequeueReusableCell(DemoHeaderTableViewCell.self, indexPath: indexPath) {
                return header
            }
        case .animatable(let enabled):
            if let cell = tableView.dequeueReusableCell(DemoTableViewCell.self, indexPath: indexPath) {
                cell.configure(withStatus: DemoTableViewCell.DemoCellStatus.animatable(enabled: enabled))
                cell.animatableDelegate = self
                cell.swipableDelegate = self
                return cell
            }
        case .swipable(let selected):
            if let cell = tableView.dequeueReusableCell(DemoTableViewCell.self, indexPath: indexPath) {
                cell.configure(withStatus: DemoTableViewCell.DemoCellStatus.swipable(selected: selected))
                cell.animatableDelegate = self
                cell.swipableDelegate = self
                return cell
            }
        }

        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension DemoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - ZAnimatableTableViewCellDelegate
extension DemoViewController: ZAnimatableTableViewCellDelegate {
    func cellTapAnimationDidComplete(onCell cell: UITableViewCell) {
        getQuote()
    }
}

extension DemoViewController: ZSwipableTableViewCellDelegate {
    func swipeBackgroundButtonDidTap(onCell cell: ZSwipableTableViewCell) {
        guard
            let indexPath = cell.z_indexPath,
            let section = sections[safe: indexPath.row] else { return }

        switch section {
        case .animatable(let enabled):
            sections[indexPath.row] = .animatable(enabled: !enabled)
        case .swipable(let selected):
            sections[indexPath.row] = .swipable(selected: !selected)
        default:
            ()
        }

        tableView.reloadData()
    }
}
