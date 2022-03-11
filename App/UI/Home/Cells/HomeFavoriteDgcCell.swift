// HomeFavoriteDgcCell.swift
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
import Foundation
import Lottie
import Tempura

struct HomeFavoriteDgcCellVM: ViewModelWithState {
        
  var favoriteGreenCertificate: GreenCertificate?

  var animation: Animation? = AnimationAsset.cardFlagEuropa.animation

  var lightContent: Bool = false

  var shadow: UIView.Shadow = .cardLightBlue

}

class HomeFavoriteDgcCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = HomeFavoriteDgcCellVM

  private static let containerInset: CGFloat = 25
  private static let iconWidth: CGFloat = UIDevice.getByScreen(normal: 130, narrow: 100)
  private static let placeholderIconSize: CGFloat = 45
  private static let placeholderIconTop: CGFloat = 10

  let container = UIView()
  let placeholderIcon = UIImageView()
  var qrCode = UIImageView()
  var didTapAction: CustomInteraction<GreenCertificate>?
  let title = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
    self.style()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
    self.style()
  }

  func setup() {
    self.contentView.addSubview(self.container)

    self.container.addSubview(self.placeholderIcon)
    self.container.addSubview(self.qrCode)
    self.container.addSubview(self.title)

    let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
    self.container.addGestureRecognizer(gesture)
  }

  func style() {}

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    if let favoriteGreenCertificate = model.favoriteGreenCertificate {
        let dataDecoded: Data? = Data(base64Encoded: favoriteGreenCertificate.greenCertificate, options: .ignoreUnknownCharacters)
        if let dataDecoded = dataDecoded, let decodedimage = UIImage(data: dataDecoded) {
          Self.Style.imageContent(qrCode, image: decodedimage)
        }
        Self.Style.title(self.title, content: favoriteGreenCertificate.name, lightContent: model.lightContent)
    }
    Self.Style.placeholderIcon(self.placeholderIcon)
    Self.Style.shadow(self.contentView, shadow: model.shadow)
    Self.Style.container(self.container, lightContent: model.lightContent)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.container.pin
      .top(8)
      .bottom(7)
      .horizontally(Self.containerInset)
    
    self.title.pin
      .left(HomeView.cellHorizontalInset)
      .right(Self.iconWidth)
      .sizeToFit(.width)
      .top(Self.placeholderIconTop + (Self.placeholderIconSize/4))
    
    self.placeholderIcon.pin
        .top(Self.placeholderIconTop)
        .right(Self.placeholderIconTop)
        .aspectRatio(self.placeholderIcon.intrinsicContentSize.width / self.placeholderIcon.intrinsicContentSize.height)
        .width(Self.placeholderIconSize)
    
      self.qrCode.pin
        .below(of: self.title)
        .marginTop(Self.placeholderIconTop)
        .hCenter()
        .width(container.frame.width*0.94)
        .height(container.frame.width*0.94)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth = size.width - HomeView.cellHorizontalInset - HomeFavoriteDgcCell.iconWidth - 2 * HomeFavoriteDgcCell.containerInset
    let titleSize = self.title.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))

    let qrCodeSize = self.qrCode.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    let iconSize = self.placeholderIcon.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))

      return CGSize(width: size.width, height: qrCodeSize.height + (titleSize.height > iconSize.height ? titleSize.height : iconSize.height) * 2 + 3 * Self.containerInset)
  }
}

private extension HomeFavoriteDgcCell {
  @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
      guard let certificate = self.model?.favoriteGreenCertificate else { return }
      self.didTapAction?(certificate)
  }
}

private extension HomeFavoriteDgcCell {
  enum Style {
    static func title(_ label: UILabel, content: String, lightContent: Bool) {
      let textStyle = TextStyles.h4.byAdding(
        .color(lightContent ? Palette.white : Palette.purple),
        .alignment(.left)
      )

    TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }
    static func container(_ view: UIView, lightContent: Bool) {
      view.backgroundColor = Palette.white

      view.layer.cornerRadius = SharedStyle.cardCornerRadius
      view.layer.masksToBounds = true
    }

    static func shadow(_ view: UIView, shadow: UIView.Shadow) {
      view.layer.masksToBounds = false
      view.addShadow(shadow)
    }

    static func icon(_ view: AnimationView, animation: Animation?) {
      view.animation = animation
      view.loopMode = .loop
      view.backgroundBehavior = .pauseAndRestore
      view.playIfPossible()
    }
    static func placeholderIcon(_ imageView: UIImageView) {
        imageView.image = Asset.Home.pinSelected.image
    }
    static func imageContent(_ imageView: UIImageView, image: UIImage) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
      }
    
  }
}
extension HomeFavoriteDgcCellVM {
  init(state: AppState) {
      self.init(favoriteGreenCertificate: state.user.favoriteGreenCertificate)
  }

  init(favoriteGreenCertificate: GreenCertificate?) {
      self.favoriteGreenCertificate = favoriteGreenCertificate
  }
}
