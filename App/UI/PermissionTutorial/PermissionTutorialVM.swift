// PermissionTutorialVM.swift
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
import Katana
import Tempura

struct PermissionTutorialVM {
  /// A struct containing all the info meant to be shown in the view.
  let content: Content
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  let isHeaderVisible: Bool
  /// Whether the animatable content should play. This is used to stop animated content while scrolling to improve performances.
  let shouldAnimateContent: Bool

  /// Check whether the view has animated content.
  var hasAnimatedContent: Bool {
    return self.content.items.contains { guard case .animationContent = $0 else { return false }; return true }
  }

  func shouldReloadCollection(oldVM: Self?) -> Bool {
    guard let oldVM = oldVM else {
      return true
    }

    return self.content != oldVM.content
  }

  func shouldUpdateAnimations(oldVM: Self?) -> Bool {
    // not needed if there is no animation cell
    guard self.hasAnimatedContent else {
      return false
    }

    guard let oldVM = oldVM else {
      return false
    }

    return self.shouldAnimateContent != oldVM.shouldAnimateContent
  }

  func shouldUpdateHeader(oldVM: Self?) -> Bool {
    guard let oldVM = oldVM else {
      return true
    }

    return self.isHeaderVisible != oldVM.isHeaderVisible
  }

  func cellVM(for item: Content.Item) -> ViewModel {
    switch item {
    case .title(let title):
      return ContentCollectionTitleCellVM(content: title)

    case .textualContent(let content, let isDark):
      return ContentCollectionTextCellVM(content: content, useDarkStyle: isDark)

    case .animationContent(let animationAsset):
      return ContentCollectionAnimationCellVM(
        asset: animationAsset,
        shouldPlay: self.shouldAnimateContent
      )

    case .imageContent(let image):
      return ContentCollectionImageCellVM(content: image)

    case .textAndImage(let text, let image, let alignment):
      return ContentCollectionTextAndImageCellVM(textualContent: text, image: image, alignment: alignment)

    case .spacer(let size):
      return ContentCollectionSpacerVM(size: size)

    case .scrollableButton(let description, let buttonTitle):
      return ContentCollectionButtonCellVM(description: description, buttonTitle: buttonTitle)
    }
  }
}

extension PermissionTutorialVM: ViewModelWithLocalState {
  init?(state: AppState?, localState: PermissionTutorialLS) {
    self.content = localState.content
    self.isHeaderVisible = localState.isHeaderVisible
    self.shouldAnimateContent = localState.shouldAnimateContent
  }
}

extension PermissionTutorialVM {
  struct Content: Equatable {
    /// The title of the tutorial
    let title: String

    /// The action button title
    let mainActionTitle: String?

    /// The action to perform on tap of either the main button, or the scrollable button
    /// note: here we assume there is at maximum 1 action
    let action: Dispatchable?

    /// The items to show
    let items: [Item]

    init(title: String, items: [Item], mainActionTitle: String?, action: Dispatchable?) {
      self.mainActionTitle = mainActionTitle
      self.action = action
      self.items = [.title(title)] + items
      self.title = title
    }

    var isActionButtonVisible: Bool {
      self.mainActionTitle != nil
    }

    static func == (lhs: Content, rhs: Content) -> Bool {
      // here we assume the dispatchable should not be considered when calculating the identity

      if lhs.title != rhs.title {
        return false
      }

      if lhs.mainActionTitle != rhs.mainActionTitle {
        return false
      }

      if lhs.items != rhs.items {
        return false
      }

      return true
    }
  }
}

extension PermissionTutorialVM.Content {
  enum Item: Equatable {
    case title(String)
    case textualContent(String, isDark: Bool)
    case animationContent(AnimationAsset)
    case imageContent(UIImage)
    case textAndImage(String, UIImage, ContentCollectionTextAndImageCellVM.Alignment)
    case spacer(ContentCollectionSpacerVM.Size)
    case scrollableButton(description: String, buttonTitle: String)
  }
}

extension PermissionTutorialVM.Content {
  static var notificationInstructions: Self {
    return PermissionTutorialVM.Content(
      title: L10n.PermissionTutorial.Notifications.title,
      items: [
        .spacer(.big),
        .textualContent(L10n.PermissionTutorial.Notifications.first, isDark: true),
        .spacer(.medium),
        .textualContent(L10n.PermissionTutorial.Notifications.second, isDark: true),
        .imageContent(Asset.PermissionTutorial.notification.image),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.Notifications.third, isDark: true),
        .imageContent(Asset.PermissionTutorial.allowNotification.image)
      ],
      mainActionTitle: L10n.PermissionTutorial.Notifications.action,
      action: Logic.Shared.OpenSettings()
    )
  }

  static var bluetoothInstructions: Self {
    return PermissionTutorialVM.Content(
      title: L10n.PermissionTutorial.Bluetooth.title,
      items: [
        .spacer(.big),
        .textualContent(L10n.PermissionTutorial.Bluetooth.first, isDark: true),
        .spacer(.medium),
        .textualContent(L10n.PermissionTutorial.Bluetooth.second, isDark: true),
        .imageContent(Asset.PermissionTutorial.bluetooth.image)
      ],
      mainActionTitle: nil,
      action: nil
    )
  }

  // swiftlint:disable:next identifier_name
  static var exposureNotificationUnauthorizedInstructions: Self {
    if #available(iOS 13.7, *) {
      return Self.exposureNotificationRestrictedOrUnauthorizedV2Instructions
    }

    return PermissionTutorialVM.Content(
      title: L10n.PermissionTutorial.ExposureNotification.Unauthorized.title,
      items: [
        .spacer(.big),
        .textualContent(L10n.PermissionTutorial.ExposureNotification.Unauthorized.first, isDark: true),
        .spacer(.medium),
        .textualContent(L10n.PermissionTutorial.ExposureNotification.Unauthorized.second, isDark: true),
        .imageContent(Asset.PermissionTutorial.covid19ExpositionSetting.image)
      ],
      mainActionTitle: L10n.PermissionTutorial.ExposureNotification.Unauthorized.action,
      action: Logic.Shared.OpenSettings()
    )
  }

  // swiftlint:disable:next identifier_name
  static var exposureNotificationRestrictedInstructions: Self {
    if #available(iOS 13.7, *) {
      return Self.exposureNotificationRestrictedOrUnauthorizedV2Instructions
    }

    return PermissionTutorialVM.Content(
      title: L10n.PermissionTutorial.ExposureNotification.Restricted.title,
      items: [
        .spacer(.big),
        .textualContent(L10n.PermissionTutorial.ExposureNotification.Restricted.first, isDark: true),
        .imageContent(Asset.PermissionTutorial.settings.image),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.ExposureNotification.Restricted.second, isDark: true),
        .imageContent(Asset.PermissionTutorial.privacy.image),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.ExposureNotification.Restricted.third, isDark: true),
        .imageContent(Asset.PermissionTutorial.health.image),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.ExposureNotification.Restricted.fourth, isDark: true),
        .imageContent(Asset.PermissionTutorial.covid19Exposition.image),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.ExposureNotification.Restricted.fifth, isDark: true),
        .imageContent(Asset.PermissionTutorial.covid19ExpositionLog.image)
      ],
      mainActionTitle: nil,
      action: nil
    )
  }

  // Instructions for the iOS 13.7 and 14 settings, when the EN is either restricted
  // or not authorized
  // swiftlint:disable:next identifier_name
  static var exposureNotificationRestrictedOrUnauthorizedV2Instructions: Self {
    return PermissionTutorialVM.Content(
      title: L10n.PermissionTutorial.ExposureNotification.RestrictedOrUnauthorizedV2.title,
      items: [
        .spacer(.big),
        .textualContent(L10n.PermissionTutorial.ExposureNotification.RestrictedOrUnauthorizedV2.first, isDark: true),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.ExposureNotification.RestrictedOrUnauthorizedV2.second, isDark: true),
        .imageContent(Asset.PermissionTutorial.exposureNotification.image),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.ExposureNotification.RestrictedOrUnauthorizedV2.third, isDark: true),
        .imageContent(Asset.PermissionTutorial.exposureNotificationShare.image),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.ExposureNotification.RestrictedOrUnauthorizedV2.fourth, isDark: true),
        .imageContent(Asset.PermissionTutorial.setAsAsctiveRegion.image),
        .scrollableButton(
          description: "",
          buttonTitle: L10n.PermissionTutorial.ExposureNotification.RestrictedOrUnauthorizedV2.action
        ),
        .spacer(.small)
      ],
      mainActionTitle: nil,
      action: Logic.Shared.OpenSettings()
    )
  }

  static var deactivateServiceInstructions: Self {
    if #available(iOS 13.7, *) {
      return Self.deactivateServiceInstructionsV2
    }

    return PermissionTutorialVM.Content(
      title: L10n.PermissionTutorial.DeactivateService.title,
      items: [
        .spacer(.big),
        .textAndImage(
          L10n.PermissionTutorial.DeactivateService.First.message,
          Asset.Settings.UploadData.alert.image,
          .imageBeforeText
        ),
        .spacer(.big),
        .textualContent(L10n.PermissionTutorial.DeactivateService.Second.message, isDark: true),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.DeactivateService.Third.message, isDark: true),
        .spacer(.big),
        .imageContent(Asset.Common.separator.image),
        .spacer(.big),
        .textualContent(L10n.PermissionTutorial.DeactivateService.Fourth.message, isDark: true),
        .spacer(.big),
        .textualContent(L10n.PermissionTutorial.DeactivateService.Fifth.message, isDark: true),
        .spacer(.medium),
        .textualContent(L10n.PermissionTutorial.DeactivateService.Sixth.message, isDark: true),
        .spacer(.small),
        .imageContent(Asset.PermissionTutorial.covid19ExpositionDisabled.image),
        .scrollableButton(description: "", buttonTitle: L10n.PermissionTutorial.DeactivateService.Action.cta),
        .spacer(.small)
      ],
      mainActionTitle: nil,
      action: Logic.Shared.OpenSettings()
    )
  }

  // deactivate service instructions for the settings v2 (ios 13.7 or above)
  static var deactivateServiceInstructionsV2: Self {
    return PermissionTutorialVM.Content(
      title: L10n.PermissionTutorial.DeactivateService.title,
      items: [
        .spacer(.big),
        .textAndImage(
          L10n.PermissionTutorial.DeactivateService.First.message,
          Asset.Settings.UploadData.alert.image,
          .imageBeforeText
        ),
        .spacer(.big),
        .textualContent(L10n.PermissionTutorial.DeactivateService.Second.message, isDark: true),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.DeactivateService.Third.message, isDark: true),
        .spacer(.big),
        .imageContent(Asset.Common.separator.image),
        .spacer(.big),
        .textualContent(L10n.PermissionTutorial.DeactivateService.Fourth.message, isDark: true),
        .spacer(.big),
        .textualContent(L10n.PermissionTutorial.DeactivateService.Fifth.message, isDark: true),
        .spacer(.medium),
        .textualContent(L10n.PermissionTutorial.DeactivateService.Sixth.V2.message, isDark: true),
        .imageContent(Asset.PermissionTutorial.exposureNotification.image),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.DeactivateService.Seventh.V2.message, isDark: true),
        .imageContent(Asset.PermissionTutorial.exposureNotificationShareDeactivated.image),
        .scrollableButton(description: "", buttonTitle: L10n.PermissionTutorial.DeactivateService.Action.cta),
        .spacer(.small)
      ],
      mainActionTitle: nil,
      action: Logic.Shared.OpenSettings()
    )
  }

  static var updateOperatingSystem: Self {
    return PermissionTutorialVM.Content(
      title: L10n.PermissionTutorial.UpdateOs.title,
      items: [
        .spacer(.big),
        .textualContent(L10n.PermissionTutorial.UpdateOs.first, isDark: true),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.UpdateOs.second, isDark: true),
        .imageContent(Asset.PermissionTutorial.settings.image),
        .textualContent(L10n.PermissionTutorial.UpdateOs.third, isDark: true),
        .imageContent(Asset.PermissionTutorial.settingsGeneral.image),
        .textualContent(L10n.PermissionTutorial.UpdateOs.fourth, isDark: true),
        .imageContent(Asset.PermissionTutorial.softwareUpdate.image),
        .textualContent(L10n.PermissionTutorial.UpdateOs.fifth, isDark: true),
        .spacer(.big)
      ],
      mainActionTitle: nil,
      action: nil
    )
  }

  static var cantUpdateOperatingSystem: Self {
    return PermissionTutorialVM.Content(
      title: L10n.PermissionTutorial.CantUpdate.title,
      items: [
        .spacer(.big),
        .textualContent(L10n.PermissionTutorial.CantUpdate.first, isDark: true),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.CantUpdate.second, isDark: true),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.CantUpdate.third, isDark: true),
        .spacer(.small),
        .imageContent(Asset.PermissionTutorial.downloadAndInstall.image),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.CantUpdate.fourth, isDark: true),
        .spacer(.small),
        .imageContent(Asset.PermissionTutorial.installNow.image),
        .spacer(.big)
      ],
      mainActionTitle: nil,
      action: nil
    )
  }

  static func howImmuniWorks(shouldShowFaqButton: Bool) -> Self {
    var items: [Item] = [
      .spacer(.big),
      .animationContent(.hiw1),
      .spacer(.medium),
      .textualContent(L10n.PermissionTutorial.HowImmuniWorks.First.title, isDark: true),
      .spacer(.tiny),
      .textualContent(L10n.PermissionTutorial.HowImmuniWorks.First.message, isDark: true),
      .spacer(.medium),
      .imageContent(Asset.HowImmuniWorks.break.image),
      .spacer(.big),
      .animationContent(.hiw2),
      .spacer(.medium),
      .textualContent(L10n.PermissionTutorial.HowImmuniWorks.Second.title, isDark: true),
      .spacer(.tiny),
      .textualContent(L10n.PermissionTutorial.HowImmuniWorks.Second.message, isDark: true),
      .spacer(.medium),
      .imageContent(Asset.HowImmuniWorks.break.image),
      .spacer(.big),
      .animationContent(.hiw3),
      .spacer(.medium),
      .textualContent(L10n.PermissionTutorial.HowImmuniWorks.Third.title, isDark: true),
      .spacer(.tiny),
      .textualContent(L10n.PermissionTutorial.HowImmuniWorks.Third.message, isDark: true),
      .spacer(.medium),
      .imageContent(Asset.HowImmuniWorks.break.image),
      .spacer(.big),
      .animationContent(.hiw4),
      .spacer(.medium),
      .textualContent(L10n.PermissionTutorial.HowImmuniWorks.Fourth.title, isDark: true),
      .spacer(.tiny),
      .textualContent(L10n.PermissionTutorial.HowImmuniWorks.Fourth.message, isDark: true),
      .spacer(.medium),
      .imageContent(Asset.HowImmuniWorks.break.image),
      .spacer(.big),
      .animationContent(.hiw5),
      .spacer(.medium),
      .textualContent(L10n.PermissionTutorial.HowImmuniWorks.Fifth.title, isDark: true),
      .spacer(.tiny),
      .textualContent(L10n.PermissionTutorial.HowImmuniWorks.Fifth.message, isDark: true),
      .spacer(.medium)
    ]
    var action: Dispatchable?

    if shouldShowFaqButton {
      items.append(contentsOf: [
        .scrollableButton(
          description: L10n.PermissionTutorial.HowImmuniWorks.Action.description,
          buttonTitle: L10n.PermissionTutorial.HowImmuniWorks.Action.cta
        ),
        .spacer(.medium)
      ])
      action = Logic.Settings.ShowFAQs()
    }

    return PermissionTutorialVM.Content(
      title: L10n.PermissionTutorial.HowImmuniWorks.title,
      items: items,
      mainActionTitle: nil,
      action: action
    )
  }

  static var verifyImmuniWorks: Self {
    return PermissionTutorialVM.Content(
      title: L10n.PermissionTutorial.VerifyImmuniWorks.title,
      items: [
        .spacer(.big),
        .textualContent(L10n.PermissionTutorial.VerifyImmuniWorks.first, isDark: false),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.VerifyImmuniWorks.second, isDark: false),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.VerifyImmuniWorks.third, isDark: false),
        .spacer(.big)
      ],
      mainActionTitle: nil,
      action: nil
    )
  }

  static var howToUploadWhenPositive: Self {
    return PermissionTutorialVM.Content(
      title: L10n.PermissionTutorial.HowToUploadPositive.title,
      items: [
        .spacer(.big),
        .textualContent(L10n.PermissionTutorial.HowToUploadPositive.first, isDark: false),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.HowToUploadPositive.second, isDark: false),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.HowToUploadPositive.fourth, isDark: false),
        .spacer(.big)
      ],
      mainActionTitle: nil,
      action: nil
    )
  }

  static var howToUploadWhenPositiveCallCenter: Self {
    return PermissionTutorialVM.Content(
      title: L10n.PermissionTutorial.HowToUploadPositive.title,
      items: [
        .spacer(.big),
        .textualContent(L10n.PermissionTutorial.HowToUploadPositive.first, isDark: false),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.HowToUploadPositive.CallCenter.second, isDark: false),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.HowToUploadPositiveAutonomous.third, isDark: false),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.HowToUploadPositiveAutonomous.fourth, isDark: false),
        .spacer(.big)
      ],
    mainActionTitle: nil,
    action: nil
    )
    }

  static var howToUploadWhenPositiveAutonomous: Self {
    return PermissionTutorialVM.Content(
        title: L10n.PermissionTutorial.HowToUploadPositiveAutonomous.title,
        items: [
          .spacer(.big),
          .textualContent(L10n.PermissionTutorial.HowToUploadPositiveAutonomous.first, isDark: false),
          .spacer(.small),
          .textualContent(L10n.PermissionTutorial.HowToUploadPositiveAutonomous.second, isDark: false),
          .spacer(.small),
          .textualContent(L10n.PermissionTutorial.HowToUploadPositiveAutonomous.third, isDark: false),
          .spacer(.small),
          .textualContent(L10n.PermissionTutorial.HowToUploadPositiveAutonomous.fourth, isDark: false),
          .spacer(.big)
        ],
        mainActionTitle: nil,
        action: nil
      )
    }
    
  static var howToGenerateDigitalGreenCertificate: Self {
    return PermissionTutorialVM.Content(
        title: L10n.HomeView.GenerateGreenCertificate.discoverMoreTitle,
        items: [
          .spacer(.big),
          .textualContent(L10n.HomeView.GenerateGreenCertificate.discoverMore1, isDark: false),
          .spacer(.small),
          .textualContent(L10n.HomeView.GenerateGreenCertificate.discoverMore2, isDark: false),
          .spacer(.small),
          .textualContent(L10n.HomeView.GenerateGreenCertificate.discoverMore3, isDark: false),
          .spacer(.big)
          ],
          mainActionTitle: nil,
          action: nil
        )
      }

  static var whyProvinceRegion: Self {
    return PermissionTutorialVM.Content(
      title: L10n.PermissionTutorial.WhyProvinceRegion.title,
      items: [
        .spacer(.big),
        .textualContent(L10n.PermissionTutorial.WhyProvinceRegion.first, isDark: false),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.WhyProvinceRegion.second, isDark: false),
        .spacer(.small),
        .textualContent(L10n.PermissionTutorial.WhyProvinceRegion.third, isDark: false),
        .spacer(.big)
      ],
      mainActionTitle: nil,
      action: nil
    )
  }
}
