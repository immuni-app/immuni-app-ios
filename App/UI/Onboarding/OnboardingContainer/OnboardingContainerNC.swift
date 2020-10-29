// OnboardingContainerNC.swift
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
import Katana
import Models
import Tempura
import UIKit

class OnboardingContainerNC: UINavigationController {
  let store: PartialStore<AppState>
  var accessoryView: OnboardingContainerAccessoryView?

  var currentViewController: UIViewController? { self.viewControllers.last }

  init(with store: PartialStore<AppState>, navigationContext: NavigationContext) {
    self.store = store
    let vc = Self.viewController(for: navigationContext, using: store)
    super.init(rootViewController: vc)
    self.setup()
  }

  required init?(coder aDecoder: NSCoder) {
    AppLogger.fatalError("init(coder:) has not been implemented")
  }

  /// - warning: use for test purposes only
  override init(rootViewController: UIViewController) {
    self.store = Store<AppState, AppDependencies>()
    super.init(rootViewController: rootViewController)
    self.setup()
  }

  func pushViewController(using navigationContext: NavigationContext, animated: Bool = true) {
    let vc = Self.viewController(for: navigationContext, using: self.store)
    self.pushViewController(vc, animated: animated)
  }

  // MARK: Navigation

  var routeIdentifier: RouteElementIdentifier {
    return Screen.onboardingStep.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .show(Screen.sensitiveDataCover): .presentModally { [unowned self] _ in
        let vc = SensitiveDataCoverVC(store: self.store)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        return vc
      },

      .show(Screen.onboardingStep): .custom { _, _, animated, context, completion in
        let navContext = context as? OnboardingContainerNC.NavigationContext ?? AppLogger.fatalError("Invalid Context")
        self.pushViewController(using: navContext, animated: animated)
        completion()
      },

      .show(Screen.permissionTutorial): .presentModally { context in
        let localState = context as? PermissionTutorialLS ?? AppLogger.fatalError("Invalid context")
        return PermissionTutorialVC(store: self.store, localState: localState)
      },

      .show(Screen.permissionOverlay): .presentModally { context in
        let localState = context as? OnboardingPermissionOverlayLS ?? AppLogger.fatalError("Invalid Context")
        let vc = OnboardingPermissionOverlayVC(store: self.store, localState: localState)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve

        return vc
      },

      .show(Screen.alert): .custom { [weak self] _, _, animated, context, completion in
        let content = context as? Alert.Model ?? AppLogger.fatalError("Invalid context")
        let vc = UIAlertController(content: content)
        self?.recursivePresent(vc, animated: false, completion: completion)
      },

      .hide(Screen.permissionTutorial): .dismissModally(behaviour: .hard),
      .hide(Screen.permissionOverlay): .dismissModally(behaviour: .hard)
    ]
  }
}

// MARK: Lifecycle

extension OnboardingContainerNC {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupAccessoryView()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    guard let accessoryView = self.accessoryView, accessoryView.frame != .zero else {
      return
    }

    accessoryView.frame = self.view.bounds
    accessoryView.layoutIfNeeded()

    let additionalBottomArea = self.view.frame.height
      - accessoryView.nextButton.frame.origin.y
      // we remove just the additional space between the "bottom" and the next button.
      // the original safe area bottom should be taken into account to prevent to count it
      // twice
      - self.view.safeAreaInsets.bottom

    self.currentViewController?.additionalSafeAreaInsets = .init(
      top: 0,
      left: 0,
      bottom: additionalBottomArea,
      right: 0
    )
  }
}

// MARK: Accessory View

private extension OnboardingContainerNC {
  func setup() {
    self.isNavigationBarHidden = true
    self.delegate = self
  }

  func setupAccessoryView() {
    let accessoryView = OnboardingContainerAccessoryView(frame: self.view.bounds)
    self.view.addSubview(accessoryView)
    self.accessoryView = accessoryView
    self.setupAccessoryViewInteractions()
  }

  private func setupAccessoryViewInteractions() {
    self.accessoryView?.userDidTapNext = { [weak self] in
      self?.handleTapNext()
    }

    self.accessoryView?.userDidTapBack = { [weak self] in
      self?.handleTapBack()
    }
  }

  private func handleTapNext() {
    guard let vc = self.viewControllers.last as? OnboardingViewController else {
      AppLogger.fatalError("OnboardingContainer only manages VC conforming to OnboardingViewController")
    }

    vc.handleNext()
  }

  private func handleTapBack() {
    guard let vc = self.viewControllers.last as? OnboardingViewController else {
      AppLogger.fatalError("OnboardingContainer only manages VC conforming to OnboardingViewController")
    }

    vc.handleBack()
  }
}

// MARK: Helpers

private extension OnboardingContainerNC {
  static func viewController(
    for context: NavigationContext,
    using store: PartialStore<AppState>
  ) -> OnboardingViewController {
    switch context.child {
    case .region:
      return OnboardingRegionVC(store: store, localState: .init(isUpdatingRegion: false, currentRegion: nil))

    case .updateRegion(let currentUserProvince):
      return OnboardingRegionVC(
        store: store,
        localState: .init(isUpdatingRegion: true, currentRegion: currentUserProvince.region)
      )

    case .province(let region):
      return OnboardingProvinceVC(
        store: store,
        localState: OnboardingProvinceLS(isUpdatingProvince: false, selectedRegion: region, currentProvince: nil)
      )

    case .updateCountry(let dummyIngestionWindowDuration, let currentCountries, let countryList):
      return CountriesOfInterestVC(
        store: store,
        localState: CountriesOfInterestLS(
          dummyIngestionWindowDuration: dummyIngestionWindowDuration,
          currentCountries: currentCountries,
          countryList: countryList
        )
      )

    case .updateProvince(let selectedRegion, let currentUserProvince):
      return OnboardingProvinceVC(
        store: store,
        localState: OnboardingProvinceLS(
          isUpdatingProvince: true,
          selectedRegion: selectedRegion,
          currentProvince: currentUserProvince
        )
      )

    case .exposureNotificationPermissions:
      return OnboardingPermissionVC(
        store: store,
        localState: OnboardingPermissionLS(permissionType: .exposureNotification, canBeDismissed: false)
      )

    case .fixExposureNotificationPermissions:
      return OnboardingPermissionVC(
        store: store,
        localState: OnboardingPermissionLS(permissionType: .exposureNotification, canBeDismissed: true)
      )

    case .bluetoothOff:
      return OnboardingPermissionVC(
        store: store,
        localState: OnboardingPermissionLS(permissionType: .bluetoothOff, canBeDismissed: false)
      )

    case .pinAdvice:
      return OnboardingAdviceVC(
        store: store,
        localState: OnboardingAdviceLS(adviceType: .pin)
      )

    case .communicationAdvice:
      return OnboardingAdviceVC(
        store: store,
        localState: OnboardingAdviceLS(adviceType: .communication)
      )

    case .fixBluetoothOff:
      return OnboardingPermissionVC(
        store: store,
        localState: OnboardingPermissionLS(permissionType: .bluetoothOff, canBeDismissed: true)
      )

    case .fixPushNotificationPermissions:
      return OnboardingPermissionVC(
        store: store,
        localState: OnboardingPermissionLS(permissionType: .pushNotifications, canBeDismissed: true)
      )

    case .pushNotificationPermissions:
      return OnboardingPermissionVC(
        store: store,
        localState: OnboardingPermissionLS(permissionType: .pushNotifications, canBeDismissed: false)
      )

    case .onboardingCompleted:
      return ConfirmationVC(store: store, localState: .onboardingCompleted)
    }
  }
}

// MARK: OnboardingContainer

extension OnboardingContainerNC: OnboardingContainer {
  func setNeedsRefreshControls() {
    guard let vc = self.currentViewController else {
      return
    }

    self.handleControlRefresh(using: vc)
  }

  func handleControlRefresh(using viewController: UIViewController) {
    guard let currentVC = viewController as? OnboardingViewController else {
      return
    }

    self.accessoryView?.model = OnboardingContainerAccessoryVM(
      shouldShowBackButton: currentVC.shouldShowBackButton,
      shouldShowNextButton: currentVC.shouldShowNextButton,
      shouldNextButtonBeEnabled: currentVC.shouldNextButtonBeEnabled,
      nextButtonTitle: currentVC.nextButtonTitle,
      shouldShowGradient: currentVC.shouldShowGradient
    )
  }
}

// MARK: UINavigationControllerDelegate

extension OnboardingContainerNC: UINavigationControllerDelegate {
  func navigationController(
    _ navigationController: UINavigationController,
    willShow viewController: UIViewController,
    animated: Bool
  ) {
    UIView.update(shouldAnimate: animated) {
      self.handleControlRefresh(using: viewController)
    }
  }
}

// MARK: Models

extension OnboardingContainerNC {
  struct NavigationContext {
    let child: ChildType
  }
}

extension OnboardingContainerNC.NavigationContext {
  enum ChildType: Equatable {
    // onboarding
    case region
    case province(region: Region)
    case exposureNotificationPermissions
    case bluetoothOff
    case pushNotificationPermissions
    case onboardingCompleted
    case pinAdvice
    case communicationAdvice

    // fix permissions
    case fixPushNotificationPermissions
    case fixExposureNotificationPermissions
    case fixBluetoothOff

    // settings
    case updateRegion(currentUserProvince: Province)
    case updateProvince(selectedRegion: Region, currentUserProvince: Province)
    case updateCountry(dummyIngestionWindowDuration: Double, currentCountries: [CountryOfInterest], countryList: [String: String])
  }
}

/// Protocol used to forward events originated from the main container.
/// VCs pushed in the OnboardingContainer must conform to this protocol
protocol OnboardingViewController: UIViewController {
  /// Handles the next button tap
  func handleNext()

  /// Handles the back button
  func handleBack()

  /// Whether the next button should be enabled
  var shouldNextButtonBeEnabled: Bool { get }

  /// Whether the next button should be shown
  var shouldShowNextButton: Bool { get }

  /// Whether the back button should be visible
  var shouldShowBackButton: Bool { get }

  /// Whether the view is scrollable and should show bottom gradient.
  var shouldShowGradient: Bool { get }

  /// The next button title
  var nextButtonTitle: String { get }

  /// The onboarding container
  var onboardingContainer: OnboardingContainer? { get }
}

extension OnboardingViewController {
  var onboardingContainer: OnboardingContainer? { self.navigationController as? OnboardingContainer }

  func handleBack() {
    self.navigationController?.popViewController(animated: true)
  }
}

/// Protocol used from onboarding children to interact with the main onboarding container
protocol OnboardingContainer {
  /// Tells the onboarding container that the controls' status need to be refreshed
  func setNeedsRefreshControls()
}
