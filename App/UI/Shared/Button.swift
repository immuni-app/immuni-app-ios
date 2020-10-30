// Button.swift
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
import UIKit

/// Button is a wrapper of the standard UIButton with some nice additions that should help
/// develop UI faster. It allows to create a UIButton with a gradient as background and an overlay
/// view as foreground. Besides these additions, this element exposes almost every method and property
/// of the standard `UIButton` and you should refer to the Apple's documentation for its usage.
///
/// ### Background Color
/// The Button offers an helper to specify different background colors in different states
/// (e.g., normal, highlighted)
///
/// ### Custom Alpha Values
/// It is possible to set custom alpha values for each state (e.g., normal, highlighted)
///
/// ### Overlay
/// The button has an overlay for the various states. It follows the standard BSP conventions, so it is
/// visible just for the highlighted state with an alpha of 0.07 black color. It is possible to customize
/// these values using the APIs
///
/// ### Gradient
/// It is possible to easily add a gradient as a background of the button, specifying the different
/// gradients for each state (e.g., normal, highlighted)
open class Button: UIView, TargetActionable {
  /// Dictionary that stores the button opacities
  private var opacities: [UInt: CGFloat] = [
    UIControl.State.normal.rawValue: 1.0,
    UIControl.State.highlighted.rawValue: 1.0,
    UIControl.State.disabled.rawValue: 0.4
  ]

  /// Dictionary that stores the overlay opacities
  private var overlayOpacities: [UInt: CGFloat] = [
    UIControl.State.normal.rawValue: 0.0,
    UIControl.State.highlighted.rawValue: 0.07,
    UIControl.State.disabled.rawValue: 0.0
  ]

  /// Dictionary that stores the overlay colors
  private var overlayColors: [UInt: UIColor] = [
    UIControl.State.normal.rawValue: UIColor.black,
    UIControl.State.highlighted.rawValue: UIColor.black,
    UIControl.State.disabled.rawValue: UIColor.black
  ]

  /// Dictionary that stores the gradients
  private var gradients: [UInt: Gradient] = [:]

  /// Observer of the isHighlighted state of the internal button
  private var highlightStateObserver: NSKeyValueObservation?

  /// The view that contains the optional gradient background of the button
  private var backgroundView = UIView()

  /// The view that implements the overlay
  private var overlayView = UIView()

  /// The button responding to user interaction
  private var button = UIButton(type: .custom)

  /// The layer that implements the gradient
  private var gradientLayer = CAGradientLayer()

  public var isHighlighted: Bool {
    get {
      return self.button.isHighlighted
    }
    set {
      self.button.isHighlighted = newValue
      self.update()
    }
  }

  public var isEnabled: Bool {
    get {
      return self.button.isEnabled
    }
    set {
      self.button.isEnabled = newValue
      self.update()
    }
  }

  public var isSelected: Bool {
    get {
      return self.button.isSelected
    }
    set {
      self.button.isSelected = newValue
      self.update()
    }
  }

  public var state: UIControl.State {
    return self.button.state
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
    self.style()
    self.update()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
    self.style()
    self.update()
  }

  // MARK: Public methods

  /**
   Set the opacity of the button in a given state.
   Default values are 1.0 for all the states

   - parameter opacity: the opacity
   - parameter state: the state
   */
  public func setOpacity(_ opacity: CGFloat, for state: UIControl.State) {
    self.opacities[state.rawValue] = opacity
    self.update()
  }

  /**
   Set the opacity of the overlay in a given state.
   Default values are 0.0 for normal/disabled states and 0.07 for highlighted

   - parameter opacity: the opacity
   - parameter state: the state
   */
  public func setOverlayOpacity(_ opacity: CGFloat, for state: UIControl.State) {
    self.overlayOpacities[state.rawValue] = opacity
    self.update()
  }

  /**
   Set the background color for a specific state
   There is no default values

   - parameter color: the color
   - parameter state: the state
   */
  public func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
    // don't pass trough the usual update cycle to avoid doing extra expensive operations
    let image = color.flatMap { UIImage.pixelImage(of: $0) }
    self.button.setBackgroundImage(image, for: state)
  }

  /**
   Set the gradient to use for for a state
   There is no default values (no gradient)

   - parameter gradient: the gradient
   - parameter state: the state
   */
  public func setGradient(_ gradient: Gradient?, for state: UIControl.State) {
    self.gradients[state.rawValue] = gradient

    // forward to highlighted and disabled if not explicitly set
    if self.gradients[UIControl.State.highlighted.rawValue] == nil {
      self.gradients[UIControl.State.highlighted.rawValue] = gradient
    }

    if self.gradients[UIControl.State.disabled.rawValue] == nil {
      self.gradients[UIControl.State.disabled.rawValue] = gradient
    }

    self.update()
  }

  // Add action to execute on the specified event
  public func on(_ event: UIControl.Event, _ action: @escaping (UIButton) -> Void) {
    self.button.on(event, action)
  }

  // MARK: Setup

  private func setup() {
    self.addSubview(self.backgroundView)
    self.addSubview(self.button)
    self.addSubview(self.overlayView)

    self.gradientLayer.masksToBounds = true
    self.backgroundView.isUserInteractionEnabled = false
    self.backgroundView.layer.addSublayer(self.gradientLayer)
    self.overlayView.isUserInteractionEnabled = false

    // we need to observe changes of the isHighlighted state of the button because
    // it is managed automatically by user touches. For the isEnabled state it is
    // not necessary since it is always set manually
    self.highlightStateObserver = self.button.observe(
      \.isHighlighted,
      options: [],
      changeHandler: { [weak self] _, _ in
        self?.update()
      }
    )
  }

  // MARK: Style

  private func style() {
    // this is to avoid that the change of the uibutton's opacity when highlighted/disabled
    // happens together with the change of the Button's overlay, obtaining a wrong opacity
    self.button.adjustsImageWhenHighlighted = false
    self.button.adjustsImageWhenDisabled = false
  }

  // MARK: Update

  private func update() {
    self.updateOpacity()
    self.updateOverlay()
    self.updateGradient()
  }

  private func updateOpacity() {
    self.backgroundView.alpha = self.opacities[self.state.rawValue] ?? 1.0
    self.button.alpha = self.opacities[self.state.rawValue] ?? 1.0
  }

  private func updateOverlay() {
    self.overlayView.alpha = self.overlayOpacities[self.state.rawValue] ?? 1.0
    self.overlayView.backgroundColor = self.overlayColors[self.state.rawValue] ?? UIColor.clear
  }

  private func updateGradient() {
    guard let gradient = self.gradients[self.state.rawValue] else {
      self.gradientLayer.colors = nil
      return
    }

    gradient.apply(to: self.gradientLayer)
  }

  // MARK: Layout

  override open func layoutSubviews() {
    super.layoutSubviews()

    self.backgroundView.frame = self.bounds
    self.button.frame = self.bounds
    self.overlayView.frame = self.bounds

    CATransaction.withDisabledActions {
      self.gradientLayer.frame = self.bounds

      self.updateCornerRadius()
    }
  }

  private func updateCornerRadius() {
    self.overlayView.layer.cornerRadius = self.layer.cornerRadius
    self.gradientLayer.cornerRadius = self.layer.cornerRadius
    self.button.layer.cornerRadius = self.layer.cornerRadius
    self.button.layer.masksToBounds = true
  }

  override open func sizeThatFits(_ size: CGSize) -> CGSize {
    return self.button.sizeThatFits(size)
  }

  override open var intrinsicContentSize: CGSize {
    return self.button.intrinsicContentSize
  }

  open func setAttributedTitle(_ title: NSAttributedString?, for state: UIControl.State) {
    self.button.setAttributedTitle(title?.adapted(), for: state)
  }
}

// MARK: - Public interface to UIButton's methods and properties

public extension Button {
  // MARK: - Button title

  var titleLabel: UILabel? {
    return self.button.titleLabel
  }

  func title(for state: UIControl.State) -> String? {
    return self.button.title(for: state)
  }

  func setTitle(_ title: String?, for state: UIControl.State) {
    self.button.setTitle(title, for: state)
  }

  func attributedTitle(for state: UIControl.State) -> NSAttributedString? {
    return self.button.attributedTitle(for: state)
  }

  func titleColor(for state: UIControl.State) -> UIColor? {
    return self.button.titleColor(for: state)
  }

  func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
    self.button.setTitleColor(color, for: state)
  }

  func titleShadowColor(for state: UIControl.State) -> UIColor? {
    return self.button.titleShadowColor(for: state)
  }

  func setTitleShadowColor(_ color: UIColor?, for state: UIControl.State) {
    self.button.setTitleShadowColor(color, for: state)
  }

  var reversesTitleShadowWhenHighlighted: Bool {
    get {
      return self.button.reversesTitleShadowWhenHighlighted
    }
    set {
      self.button.reversesTitleShadowWhenHighlighted = newValue
    }
  }

  // MARK: - Button image

  var adjustsImageWhenHighlighted: Bool {
    get {
      return self.button.adjustsImageWhenHighlighted
    }
    set {
      self.button.adjustsImageWhenHighlighted = newValue
    }
  }

  var adjustsImageWhenDisabled: Bool {
    get {
      return self.button.adjustsImageWhenDisabled
    }
    set {
      self.button.adjustsImageWhenDisabled = newValue
    }
  }

  func backgroundImage(for state: UIControl.State) -> UIImage? {
    return self.button.backgroundImage(for: state)
  }

  func setBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
    self.button.setBackgroundImage(image, for: state)
  }

  func image(for state: UIControl.State) -> UIImage? {
    return self.button.image(for: state)
  }

  func setImage(_ image: UIImage?, for state: UIControl.State) {
    self.button.setImage(image, for: state)
  }

  var imageView: UIImageView? {
    return self.button.imageView
  }

  // MARK: - Button's edge insets

  var contentEdgeInsets: UIEdgeInsets {
    get {
      return self.button.contentEdgeInsets
    }
    set {
      self.button.contentEdgeInsets = newValue
    }
  }

  var titleEdgeInsets: UIEdgeInsets {
    get {
      return self.button.titleEdgeInsets
    }
    set {
      self.button.titleEdgeInsets = newValue
    }
  }

  var imageEdgeInsets: UIEdgeInsets {
    get {
      return self.button.imageEdgeInsets
    }
    set {
      self.button.imageEdgeInsets = newValue
    }
  }

  // MARK: - Button's current state

  var currentTitle: String? {
    return self.button.currentTitle
  }

  var currentAttributedTitle: NSAttributedString? {
    return self.button.currentAttributedTitle
  }

  var currentTitleColor: UIColor {
    return self.button.currentTitleColor
  }

  var currentTitleShadowColor: UIColor? {
    return self.button.currentTitleShadowColor
  }

  var currentImage: UIImage? {
    return self.button.currentImage
  }

  var currentBackgroundImage: UIImage? {
    return self.button.currentBackgroundImage
  }

  // MARK: - Dimensions

  func backgroundRect(forBounds bounds: CGRect) -> CGRect {
    return self.button.backgroundRect(forBounds: bounds)
  }

  func contentRect(forBounds bounds: CGRect) -> CGRect {
    return self.button.contentRect(forBounds: bounds)
  }

  func titleRect(forContentRect rect: CGRect) -> CGRect {
    return self.button.titleRect(forContentRect: rect)
  }

  func imageRect(forContentRect rect: CGRect) -> CGRect {
    return self.button.imageRect(forContentRect: rect)
  }
}

// MARK: - Content alignment

public extension Button {
  var contentVerticalAlignment: UIControl.ContentVerticalAlignment {
    get {
      return self.button.contentVerticalAlignment
    }
    set {
      self.button.contentVerticalAlignment = newValue
    }
  }

  var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment {
    get {
      return self.button.contentHorizontalAlignment
    }
    set {
      self.button.contentHorizontalAlignment = newValue
    }
  }

  var effectiveContentHorizontalAlignment: UIControl.ContentHorizontalAlignment {
    return self.button.effectiveContentHorizontalAlignment
  }
}

// MARK: Helpers

private extension UIImage {
  /// Creates a 1x1 image with the given color
  static func pixelImage(of color: UIColor) -> UIImage? {
    UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
    var colorImage: UIImage?

    if let context = UIGraphicsGetCurrentContext() {
      context.setFillColor(color.cgColor)
      context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
      colorImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
    }

    return colorImage
  }
}
