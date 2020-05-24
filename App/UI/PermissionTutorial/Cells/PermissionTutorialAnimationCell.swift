// PermissionTutorialAnimationCell.swift
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

import Extensions
import Lottie
import Tempura

struct PermissionTutorialAnimationCellVM: ViewModel {
  let animationName: String

  var content: Animation? {
    return Animation.named(self.animationName)
  }

  func shouldUpdate(oldVM: Self?) -> Bool {
    guard let oldVM = oldVM else {
      return true
    }

    return self.animationName != oldVM.animationName
  }
}

final class PermissionTutorialAnimationCell: UICollectionViewCell, ModellableView, ReusableView {
  private let animation = AnimationView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
    self.style()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.setup()
    self.style()
  }

  func setup() {
    self.contentView.addSubview(self.animation)
  }

  func style() {}

  func update(oldModel: PermissionTutorialAnimationCellVM?) {
    guard let model = self.model else {
      return
    }

    if model.shouldUpdate(oldVM: oldModel) {
      Self.Style.content(self.animation, content: model.content)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.animation.pin.all()
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let animationSize = self.animation.intrinsicContentSize
    let factor = size.width / animationSize.width
    return CGSize(width: size.width, height: animationSize.height * factor)
  }
}

extension PermissionTutorialAnimationCell {
  enum Style {
    static func content(_ view: AnimationView, content: Animation?) {
      view.animation = content
      view.loopMode = .loop
      view.backgroundBehavior = .pauseAndRestore
      view.playIfPossible()
    }
  }
}
