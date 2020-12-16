// TabbarVC.swift
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
import Tempura

class TabbarVC: ViewController<TabbarView>, CustomRouteInspectables {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return self.children.first?.preferredStatusBarStyle ?? .darkContent
  }

  lazy var homeVC = HomeNC(store: self.store)
  lazy var settingsVC = SettingsNC(store: self.store)

  /// Array of the main VC for each tab
  private lazy var vc: [TabbarVM.Tab: UIViewController] = [
    .home: self.homeVC,
    .settings: self.settingsVC
  ]

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // Present the first when the view is loaded
    guard let viewModel = self.viewModel,
          let newVC = self.vc[viewModel.selectedTab]
    else {
      return
    }
    self.add(newVC, frame: self.rootView.frame)
  }

  override func setupInteraction() {
    self.rootView.didSelectCell = { [unowned self] newTab in
      self.handleTap(on: newTab)
    }
  }

  override func willUpdate(new: TabbarVM?) {
    super.willUpdate(new: new)

    guard let model = new else {
      return
    }

    self.changeTab(to: model.selectedTab)
  }

  func handleTap(on newTab: TabbarVM.Tab) {
    guard let oldTab = self.viewModel?.selectedTab else {
      return
    }

    if oldTab != newTab {
      self.changeTab(to: newTab)
    } else {
      if let navigationController = self.vc[newTab] as? UINavigationController {
        navigationController.popViewController(animated: true)
      }
    }
  }

  func changeTab(to newTab: TabbarVM.Tab) {
    guard let oldTab = self.viewModel?.selectedTab,
          oldTab != newTab
    else {
      return
    }

    if let newVC = self.vc[newTab] {
      // remove the current child
      self.vc[oldTab]?.remove()

      let traitCollectionDidChange = self.traitCollection != newVC.traitCollection
      self.add(newVC, frame: self.rootView.frame)
      self.dispatch(Logic.Accessibility.PostNotification(notification: .screenChanged, argument: nil))

      if traitCollectionDidChange {
        // Post a `UIContentSizeCategory.didChangeNotification` to trigger the update for subviews that adopt the
        // `AdaptableTextContainer` protocol if trait collection did change.
        NotificationCenter.default.post(name: UIContentSizeCategory.didChangeNotification, object: nil)
      }

      self.dispatch(Logic.Shared.UpdateSelectedTab(tab: newTab))
    }
  }

  var nextRouteControllers: [UIViewController] {
    guard
      let model = self.viewModel,
      let vc = self.vc[model.selectedTab]
    else {
      return []
    }

    return [vc]
  }
}

// MARK: - Helper for containment api

@nonobjc extension UIViewController {
  /// Add a view controller as child of the tabbar
  ///
  /// - parameter child: the child vc to add
  /// - parameter frame: the available frame for the child vc
  func add(_ child: UIViewController, frame: CGRect? = nil) {
    addChild(child)

    if let frame = frame {
      child.view.frame = frame
    }
    child.additionalSafeAreaInsets.bottom = TabbarView.tabBarHeight

    view.addSubview(child.view)
    view.sendSubviewToBack(child.view)
    child.didMove(toParent: self)

    self.setNeedsStatusBarAppearanceUpdate()
  }

  /// Remove a vc previously added from the children
  func remove() {
    willMove(toParent: nil)
    view.removeFromSuperview()
    removeFromParent()
  }
}
