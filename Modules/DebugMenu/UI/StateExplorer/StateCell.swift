// StateCell.swift
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

class StateCell: UITableViewCell {
  static let reusableIdentifier = "StateCell"

  lazy var nameLabel: UILabel = {
    let nameLabel = UILabel()
    nameLabel.numberOfLines = 0
    nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
    return nameLabel
  }()

  lazy var descriptionLabel: UILabel = {
    let descriptionLabel = UILabel()
    descriptionLabel.numberOfLines = 0
    descriptionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    return descriptionLabel
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setupView()
  }

  private func setupView() {
    self.contentView.addSubview(self.nameLabel)
    self.contentView.addSubview(self.descriptionLabel)

    // layout

    self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
    self.nameLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 15).isActive = true
    self.nameLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -10).isActive = true
    self.nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true

    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    self.descriptionLabel.leftAnchor.constraint(equalTo: self.nameLabel.leftAnchor).isActive = true
    self.descriptionLabel.rightAnchor.constraint(equalTo: self.nameLabel.rightAnchor).isActive = true
    self.descriptionLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 5).isActive = true
    self.descriptionLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
  }
}
