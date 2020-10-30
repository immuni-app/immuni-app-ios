// StateExplorerTableController.swift
// Copyright (C) 2020 Presidenza del Consiglio dei Ministri.
// Please refer to the AUTHORS file for more information.
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

import UIKit

class StateExplorerTableController: UIViewController {
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.register(StateCell.self, forCellReuseIdentifier: StateCell.reusableIdentifier)
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 100
    tableView.delegate = self
    tableView.dataSource = self

    return tableView
  }()

  fileprivate var stateSlice: [(String, Any)]

  init(title: String, serializedAppState: Any?) {
    self.stateSlice = []

    if let dictAppState = serializedAppState as? [String: Any] {
      for (key, value) in dictAppState.sorted(by: { $0.key <= $1.key }) {
        self.stateSlice.append((key, value))
      }
    }

    if let arrayAppState = serializedAppState as? [Any] {
      for (index, value) in arrayAppState.enumerated() {
        self.stateSlice.append(("\(index)", value))
      }
    }

    super.init(nibName: nil, bundle: nil)
    self.title = title
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupTableView()
    self.setupCancelButton()
  }

  private func setupTableView() {
    self.view.addSubview(self.tableView)
    self.tableView.translatesAutoresizingMaskIntoConstraints = false
    self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
    self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
  }

  private func setupCancelButton() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .done,
      target: self,
      action: #selector(StateExplorerTableController.cancelTapped)
    )
  }

  @objc private func cancelTapped() {
    self.dismiss(animated: true, completion: nil)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let selected = self.tableView.indexPathForSelectedRow {
      self.tableView.deselectRow(at: selected, animated: true)
    }
  }
}

extension StateExplorerTableController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let index = indexPath.row

    let (key, value) = self.stateSlice[index]

    if let arrayValue = value as? [Any] {
      let detail = StateExplorerTableController(title: key, serializedAppState: arrayValue)
      self.navigationController?.pushViewController(detail, animated: true)
    } else if let dictionaryValue = value as? [String: Any] {
      let detail = StateExplorerTableController(title: key, serializedAppState: dictionaryValue)
      self.navigationController?.pushViewController(detail, animated: true)
    } else {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
}

extension StateExplorerTableController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.stateSlice.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: StateCell.reusableIdentifier, for: indexPath) as? StateCell
    else {
      LibLogger.fatalError("State explore cell must be a statecell")
    }

    let index = indexPath.row

    let (key, value) = self.stateSlice[index]

    cell.nameLabel.text = key

    if value as? [Any] != nil {
      cell.accessoryType = .disclosureIndicator
      cell.descriptionLabel.text = "Tap for more..."
    } else if value as? [String: Any] != nil {
      cell.accessoryType = .disclosureIndicator
      cell.descriptionLabel.text = "Tap for more..."
    } else {
      cell.accessoryType = .none
      cell.descriptionLabel.text = "\(value)"
    }

    return cell
  }
}
