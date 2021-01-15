// UploadDataHeaderView.swift
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

import Foundation
import Lottie
import Tempura
import Models

struct UploadDataHeaderVM: ViewModel {
    var callCenterMode: Bool
}

// MARK: - View

class UploadDataHeaderView: UIView, ModellableView {
  static let horizontalMargin: CGFloat = 30.0
  static let textToDiscoverMore: CGFloat = 10.0

  typealias VM = UploadDataHeaderVM

  var didTapDiscoverMore: Interaction?
  var didTapContact: Interaction?

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

  private let message = UILabel()
            
  private var discoverMore = TextButton()
    var tapGesture =  UITapGestureRecognizer()
    
  @objc func contactTap(gestureRecognizer: UITapGestureRecognizer) {
    guard let text = self.message.text else { return }
    let termsRange = (text as NSString).range(of: "800.91.24.91")
    if self.tapGesture.didTapAttributedTextInLabel(label: self.message, inRange: termsRange) {
        self.didTapContact?()
    }
  }
    
  // MARK: - Setup

  func setup() {
    self.addSubview(self.message)
    self.addSubview(self.discoverMore)

    self.discoverMore.on(.touchUpInside) { [weak self] _ in
      self?.didTapDiscoverMore?()
    }
  }

  // MARK: - Style

  func style() {
    Self.Style.background(self)
    Self.Style.discoverMore(self.discoverMore)
  }

  // MARK: - Update

    func update(oldModel _: VM?) {
        guard let model = self.model else {
            return
        }
       
        Self.Style.message(self.message, content: model.callCenterMode ? L10n.UploadData.Warning.Message.callCenter : L10n.UploadData.Warning.message)
        
        if model.callCenterMode {
            self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(contactTap))
            self.message.isUserInteractionEnabled = true
            self.message.addGestureRecognizer(self.tapGesture)
        }
        
        setNeedsLayout()
    }
  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.discoverMore.pin
      .bottom()
      .horizontally(Self.horizontalMargin)
      .sizeToFit(.width)

    self.message.pin
      .above(of: self.discoverMore, aligned: .left)
      .marginBottom(Self.textToDiscoverMore)
      .horizontally(Self.horizontalMargin)
      .sizeToFit(.width)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let availableWidth = size.width - 2 * Self.horizontalMargin
    let availableSize = CGSize(width: availableWidth, height: .infinity)

    let messageSize = self.message.sizeThatFits(availableSize)
    let discoverMoreSize = self.discoverMore.sizeThatFits(availableSize)

    return CGSize(width: size.width, height: messageSize.height + discoverMoreSize.height + Self.textToDiscoverMore)
  }
}

// MARK: - Style

private extension UploadDataHeaderView {
  enum Style {
    static func background(_ view: UIView) {
      view.backgroundColor = .clear
    }

    static func message(_ label: UILabel, content: String) {

      let textStyle = TextStyles.p.byAdding(
        .color(Palette.grayNormal),
        .alignment(.left),
        .xmlRules([
          .style("u", TextStyles.pAnchor)
        ])
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }

    static func discoverMore(_ button: TextButton) {
      let textStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.primary),
        .alignment(.left)
      )
      button.contentHorizontalAlignment = .left
      button.contentVerticalAlignment = .bottom
      button.attributedTitle = L10n.UploadData.Warning.discoverMore.styled(with: textStyle)
    }
  }
}

extension UITapGestureRecognizer {

      func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
          // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
          let layoutManager = NSLayoutManager()
          let textContainer = NSTextContainer(size: CGSize.zero)
          let textStorage = NSTextStorage(attributedString: label.attributedText!)

          // Configure layoutManager and textStorage
          layoutManager.addTextContainer(textContainer)
          textStorage.addLayoutManager(layoutManager)

          // Configure textContainer
          textContainer.lineFragmentPadding = 0.0
          textContainer.lineBreakMode = label.lineBreakMode
          textContainer.maximumNumberOfLines = label.numberOfLines
          let labelSize = label.bounds.size
          textContainer.size = labelSize
          // Find the tapped character location and compare it to the specified range
          let locationOfTouchInLabel = self.location(in: label)
          let textBoundingBox = layoutManager.usedRect(for: textContainer)

          let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,y:(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
          let locationOfTouchInTextContainer = CGPoint(x:locationOfTouchInLabel.x - textContainerOffset.x,
                                                       y:locationOfTouchInLabel.y - textContainerOffset.y);
          let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
          return NSLocationInRange(indexOfCharacter, targetRange)
      }

  }
