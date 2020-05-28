// WebView.swift
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
import Tempura
import UIKit
import WebKit

// MARK: - View Model

struct WebVM: Equatable {
  /// The url of the page to be shown.
  let url: URL
}

extension WebVM: ViewModelWithLocalState {
  init?(state: AppState?, localState: WebLS) {
    self.url = localState.url
  }
}

class WebView: UIView, ViewControllerModellableView {
  // MARK: - Subviews

  private let activityIndicator = UIActivityIndicatorView()
  private let webView = WKWebView()
  private var closeButton = ImageButton()

  // MARK: - Interactions

  var didTapClose: Interaction?
  var userDidRequestOpenExternalLink: CustomInteraction<URL>?

  // MARK: - Setup

  func setup() {
    self.addSubview(self.webView)
    self.addSubview(self.activityIndicator)
    self.addSubview(self.closeButton)

    self.webView.navigationDelegate = self
    self.webView.configuration.preferences.javaScriptEnabled = false

    self.closeButton.on(.touchUpInside) { [unowned self] _ in
      self.didTapClose?()
    }
  }

  // MARK: - Style

  func style() {
    Self.Style.root(self)
    Self.Style.activityIndicator(self.activityIndicator)
    SharedStyle.closeButton(self.closeButton)
  }

  // MARK: - Update

  func update(oldModel: WebVM?) {
    guard let model = self.model, model != oldModel else { return }

    guard let host = model.url.host, ImmuniSessionProvider.productionHosts.contains(host) else {
      // refuse to load not authorized hosts
      return
    }

    self.webView.load(URLRequest(url: model.url))
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.activityIndicator.pin
      .sizeToFit()
      .center()

    self.webView.pin.all()

    self.closeButton.pin
      .top(self.universalSafeAreaInsets.top + 25)
      .left(30)
      .sizeToFit()
  }
}

// MARK: - Style

extension WebView {
  enum Style {
    static func root(_ view: UIView) {
      view.backgroundColor = Palette.white
    }

    static func activityIndicator(_ view: UIActivityIndicatorView) {
      view.style = UIActivityIndicatorView.Style.medium
    }
  }
}

// MARK: - Delegate

extension WebView: WKNavigationDelegate {
  // swiftlint:disable:next implicitly_unwrapped_optional
  func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    self.activityIndicator.startAnimating()
  }

  // swiftlint:disable:next implicitly_unwrapped_optional
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    self.activityIndicator.stopAnimating()
  }

  func webView(
    _ webView: WKWebView,
    decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
  ) {
    guard navigationAction.navigationType == .linkActivated else {
      // not a link activated by the user
      decisionHandler(.allow)
      return
    }

    if let url = navigationAction.request.url {
      self.userDidRequestOpenExternalLink?(url)
    }

    decisionHandler(.cancel)
  }
}
