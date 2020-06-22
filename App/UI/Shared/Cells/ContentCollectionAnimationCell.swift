// ContentCollectionAnimationCell.swift
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

struct ContentCollectionAnimationCellVM: ViewModel {
  /// The animation asset of the cell
  let asset: AnimationAsset
  /// Whether the animation should play. If false, the animation is paused.
  let shouldPlay: Bool

  var content: Animation? {
    return self.asset.animation
  }

  func shouldUpdateAsset(oldModel: Self?) -> Bool {
    guard let oldModel = oldModel else {
      return true
    }

    return self.asset != oldModel.asset
  }

  func shouldUpdateState(oldModel: Self?) -> Bool {
    guard let oldModel = oldModel else {
      return true
    }

    return self.shouldPlay != oldModel.shouldPlay
  }
}

final class ContentCollectionAnimationCell: UICollectionViewCell, ModellableView, ReusableView {
  let animation = AnimationView()

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

  func update(oldModel: ContentCollectionAnimationCellVM?) {
    guard let model = self.model else {
      return
    }

    if model.shouldUpdateAsset(oldModel: oldModel) {
      Self.Style.content(self.animation, content: model.content)
    }

    if model.shouldUpdateState(oldModel: oldModel) {
      if model.shouldPlay {
        self.animation.playIfPossible()
      } else {
        self.animation.pause()
      }
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

extension ContentCollectionAnimationCell {
  enum Style {
    static func content(_ view: AnimationView, content: Animation?) {
      view.animation = content
      view.loopMode = .loop
      view.backgroundBehavior = .pauseAndRestore
      view.shouldRasterizeWhenIdle = true
    }
  }
}
