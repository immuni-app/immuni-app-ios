// TextStyles.swift
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

import BonMot

// swiftlint:disable all

// MARK: - Styles

// Namespace for app text styles
typealias TextStyles = StringStyle

extension TextStyles {
  static var alphanumericCode: StringStyle {
    let font = UIFont.sourceCodeProBold(size: 34)
    let style = StringStyle(
      .font(font),
      .lineSpacing(37.40 - font.lineHeight),
      .lineBreakMode(.byTruncatingTail),
      .tracking(.point(-1.02)),
      .adapt(.body)
    )

    return style
  }

  static var alphanumericCodeSmall: StringStyle {
    let font = UIFont.sourceCodeProBold(size: 30)
    let style = StringStyle(
      .font(font),
      .lineSpacing(33.00 - font.lineHeight),
      .lineBreakMode(.byTruncatingTail),
      .tracking(.point(-1.02)),
      .adapt(.body)
    )

    return style
  }

  static var h1: StringStyle {
    let font = UIFont.euclidCircularBBold(size: 31)
    let style = StringStyle(
      .font(font),
      .lineSpacing(34.10 - font.lineHeight),
      .lineBreakMode(.byTruncatingTail),
      .adapt(.control)
    )

    return style
  }

  static var h2: StringStyle {
    let font = UIFont.euclidCircularBBold(size: 26)
    let style = StringStyle(
      .font(font),
      .lineSpacing(28.60 - font.lineHeight),
      .lineBreakMode(.byTruncatingTail),
      .adapt(.control)
    )

    return style
  }

  static var h2Smaller: StringStyle {
    let font = UIFont.euclidCircularBBold(size: 24)
    let style = StringStyle(
      .font(font),
      .lineSpacing(26.40 - font.lineHeight),
      .lineBreakMode(.byTruncatingTail),
      .adapt(.control)
    )

    return style
  }

  static var h2Medium: StringStyle {
    let font = UIFont.euclidCircularBMedium(size: 26)
    let style = StringStyle(
      .font(font),
      .lineSpacing(28.60 - font.lineHeight),
      .lineBreakMode(.byTruncatingTail),
      .adapt(.control)
    )

    return style
  }

  static var h3: StringStyle {
    let font = UIFont.euclidCircularBBold(size: 23)
    let style = StringStyle(
      .font(font),
      .lineSpacing(27.60 - font.lineHeight),
      .lineBreakMode(.byTruncatingTail),
      .adapt(.control)
    )

    return style
  }

  static var h4: StringStyle {
    let font = UIFont.euclidCircularBSemibold(size: 18)
    let style = StringStyle(
      .font(font),
      .lineBreakMode(.byTruncatingTail),
      .adapt(.control)
    )

    return style
  }

  static var h4Bold: StringStyle {
    let font = UIFont.euclidCircularBBold(size: 18)
    let style = StringStyle(
      .font(font),
      .lineBreakMode(.byTruncatingTail),
      .adapt(.control)
    )

    return style
  }

  static var navbarSmallTitle: StringStyle {
    let font = UIFont.euclidCircularBBold(size: 19)
    let style = StringStyle(
      .font(font),
      .lineSpacing(20.90 - font.lineHeight),
      .lineBreakMode(.byTruncatingTail),
      .adapt(.control)
    )

    return style
  }

  static var p: StringStyle {
    let font = UIFont.euclidCircularBMedium(size: 16)
    let style = StringStyle(
      .font(font),
      .lineBreakMode(.byTruncatingTail),
      .adapt(.control)
    )

    return style
  }

  static var pBold: StringStyle {
    let font = UIFont.euclidCircularBBold(size: 16)
    let style = StringStyle(
      .font(font),
      .lineBreakMode(.byTruncatingTail),
      .adapt(.control)
    )

    return style
  }

  static var i: StringStyle {
    let font = UIFont.italicSystemFont(ofSize: 16)
    let style = StringStyle(
      .font(font),
      .lineBreakMode(.byTruncatingTail),
      .adapt(.control)
   )
    
    return style
  }

  static var pLink: StringStyle {
    let font = UIFont.euclidCircularBBold(size: 16)
    let style = StringStyle(
      .font(font),
      .underline(.single, nil),
      .lineBreakMode(.byTruncatingTail),
      .adapt(.control)
    )

    return style
  }

  static var pAnchor: StringStyle {
    let font = UIFont.euclidCircularBBold(size: 16)
    let style = StringStyle(
      .font(font),
      .color(Palette.purple),
      .underline(.single, nil),
      .lineBreakMode(.byTruncatingTail),
      .adapt(.control)
      )

      return style
    }

  static var pSemibold: StringStyle {
    let font = UIFont.euclidCircularBSemibold(size: 16)
    let style = StringStyle(
      .font(font),
      .lineBreakMode(.byTruncatingTail),
      .adapt(.control)
    )

    return style
  }

  static var protectionCardHeader: StringStyle {
    let font = UIFont.euclidCircularBBold(size: 28)
    let style = StringStyle(
      .font(font),
      .lineSpacing(30.80 - font.lineHeight),
      .lineBreakMode(.byTruncatingTail),
      .adapt(.control)
    )

    return style
  }

  static var s: StringStyle {
    let font = UIFont.euclidCircularBMedium(size: 14)
    let style = StringStyle(
      .font(font),
      .lineBreakMode(.byTruncatingTail),
      .adapt(.control)
    )

    return style
  }

  static var sSemibold: StringStyle {
    let font = UIFont.euclidCircularBSemibold(size: 14)
    let style = StringStyle(
      .font(font),
      .lineBreakMode(.byTruncatingTail),
      .adapt(.control)
    )

    return style
  }
}

// MARK: - UIFont helpers

extension UIFont {
  static func euclidCircularBBold(size: CGFloat) -> UIFont {
    return UIFont(name: "EuclidCircularB-Bold", size: size)!
  }

  static func euclidCircularBMedium(size: CGFloat) -> UIFont {
    return UIFont(name: "EuclidCircularB-Medium", size: size)!
  }

  static func euclidCircularBSemibold(size: CGFloat) -> UIFont {
    return UIFont(name: "EuclidCircularB-Semibold", size: size)!
  }

  static func sourceCodeProBold(size: CGFloat) -> UIFont {
    return UIFont(name: "SourceCodePro-Bold", size: size)!
  }
}

// MARK: - Utilities

// Namespace for labels utilities
enum TempuraStyles {}

extension TempuraStyles {
  /// Styles a standard label by using the given style applied to the given content.
  /// The label won't resize the font size according to the content and frame
  static func styleStandardLabel(
    _ label: UILabel,
    content: String?,
    style: StringStyle,
    numberOfLines: Int = 0
  ) {
    label.numberOfLines = numberOfLines

    // We are using BonMot's lineBreakMode instead of setting it directly to the label since when no lineBreakMode is supplied,
    // the default one in NSParagraphStyle is used.
    // NSParagraphStyle has .byWordWrapping value by default and not .byTruncatingTail as UILabel does.
    // This was resulting in an unwanted behaviour.
    var newStyle = style
    newStyle.lineBreakMode = style.lineBreakMode ?? .byTruncatingTail

    label.attributedText = content?.styled(with: newStyle).adapted()
  }

  /// Styles a shrinkableLabel label by using the given style applied to the given content.
  /// The label will resize the font size according to the content and frame
  static func styleShrinkableLabel(
    _ label: UILabel,
    content: String?,
    style: StringStyle,
    numberOfLines: Int = 0,
    minimumScaleFactor: CGFloat = 0.7
  ) {
    label.numberOfLines = numberOfLines
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = minimumScaleFactor

    // We are using BonMot's lineBreakMode instead of setting it directly to the label since when no lineBreakMode is supplied,
    // the default one in NSParagraphStyle is used.
    // NSParagraphStyle has .byWordWrapping value by default and not .byTruncatingTail as UILabel does.
    // This was resulting in an unwanted behaviour.
    var newStyle = style
    newStyle.lineBreakMode = style.lineBreakMode ?? .byTruncatingTail

    label.attributedText = content?.styled(with: newStyle).adapted()
  }
}

extension NSAttributedString {
  /// Create a new `NSAttributedString` adapted to the current trait collection if available.
  func adapted() -> NSAttributedString {
    return self.adapted(to: UITraitCollection.current)
  }
}
