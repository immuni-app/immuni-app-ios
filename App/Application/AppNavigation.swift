// AppNavigation.swift
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

enum Screen: String, CaseIterable {
  // app setup
  case appSetup
  case welcome
  case forceUpdate

  // onboarding
  case onboardingStep

  // main
  case tabBar
  case sensitiveDataCover

  // common
  case loading
  case permissionTutorial
  case permissionOverlay
  case confirmation
  case alert
  case shareText
  case privacy
  case mailComposer

  // home
  case home
  case fixActiveService
  case suggestions
  case greenCertificate
  case generateGreenCertificate
  case greenCertificateVaccineDetail
  case greenCertificateRecoveryDetail
  case greenCertificateTestDetail
  case greenCertificateExemptionDetail

  // settings
  case settings
  case uploadData
  case confirmUpload
  case customerSupport
  case updateProvince
  case updateCountry
  case faq
  case question
  case chooseDataUploadMode
  case uploadDataAutonomous
}

// MARK: - Root

extension AppDelegate {
  func installRoot(identifier: RouteElementIdentifier, context: Any?, completion: @escaping () -> Void) -> Bool {
    guard let rootScreen = Screen(rawValue: identifier) else {
      return false
    }

    let mainViewController: UIViewController

    switch rootScreen {
    case .appSetup:
      mainViewController = AppSetupVC(store: self.store)

    case .forceUpdate:
      let localState = context as? ForceUpdateLS ?? AppLogger.fatalError("Invalid context")
      mainViewController = ForceUpdateVC(store: self.store, localState: localState)

    case .tabBar:
      mainViewController = TabbarVC(store: self.store)

    case .welcome:
      mainViewController = WelcomeVC(store: self.store, localState: WelcomeLS())

    case .onboardingStep:
      let navigationContext = context as? OnboardingContainerNC.NavigationContext ?? AppLogger.fatalError("Invalid context")
      mainViewController = OnboardingContainerNC(with: self.store, navigationContext: navigationContext)
    
    case .chooseDataUploadMode:
      mainViewController = HomeNC(store: self.store)
    
    case .greenCertificate:
      mainViewController = HomeNC(store: self.store)

    default:
      AppLogger.fatalError("Root screen not handled: \(rootScreen.rawValue)")
    }

    self.window?.rootViewController = mainViewController
    completion()
    return true
  }
}

// MARK: - App Setup

extension AppSetupVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.appSetup.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [:]
  }
}

// MARK: Welcome

extension WelcomeVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.welcome.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .show(Screen.privacy): .presentModally { [unowned self] _ in
        let vc = PrivacyVC(store: self.store, localState: .init(kind: .onboarding))
        vc.modalPresentationStyle = .fullScreen
        return vc
      },

      .show(Screen.permissionTutorial): .presentModally { context in
        let localState = context as? PermissionTutorialLS ?? AppLogger.fatalError("Invalid context")
        return PermissionTutorialVC(store: self.store, localState: localState)
      },
        
      .hide(Screen.permissionTutorial): .dismissModally(behaviour: .hard),
      .hide(Screen.privacy): .dismissModally(behaviour: .hard)
    ]
  }
}

// MARK: Force Update

extension ForceUpdateVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.forceUpdate.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .show(Screen.permissionTutorial): .presentModally { context in
        let localState = context as? PermissionTutorialLS ?? AppLogger.fatalError("Invalid context")
        return PermissionTutorialVC(store: self.store, localState: localState)
      }
    ]
  }
}

// MARK: - Onboarding

extension OnboardingContainerNC: RoutableWithConfiguration {
  // the routeIdentifier and the navigationConfiguration are defined
  // in the main class body. This is because we need to subclass and change these properties
  // (see UpdateProvinceNC) but this is not possible if variables are defined within an extension
}

// MARK: Onboarding Privacy

extension PrivacyVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.privacy.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .show(Screen.onboardingStep): .presentModally { context in
        let navigationContext = context as? OnboardingContainerNC.NavigationContext ?? AppLogger.fatalError("Invalid context")
        let vc = OnboardingContainerNC(with: self.store, navigationContext: navigationContext)
        vc.modalPresentationStyle = .fullScreen
        return vc
      },

      .hide(Screen.onboardingStep): .dismissModally(behaviour: .hard)
    ]
  }
}

// MARK: - Tab Bar

extension TabbarVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.tabBar.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      // Sensitive Data Cover
      .show(Screen.sensitiveDataCover): .presentModally { [unowned self] _ in
        let vc = SensitiveDataCoverVC(store: self.store)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        return vc
      },

      // Loading
      .show(Screen.loading): .presentModally { [unowned self] context in
        let ls = context as? LoadingLS ?? AppLogger.fatalError("Invalid context")
        let vc = LoadingVC(store: self.store, localState: ls)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        return vc
      },
      .hide(Screen.loading): .dismissModally(behaviour: .soft),

      // Confirm Upload
      .show(Screen.confirmUpload): .presentModally { [unowned self] context in
        let localState = context as? ConfirmUploadLS ?? AppLogger.fatalError("invalid context")
        let vc = ConfirmUploadVC(store: self.store, localState: localState)
        vc.isModalInPresentation = true
        return vc
      },
      .hide(Screen.confirmUpload): .dismissModally(behaviour: .hard),

      // Customer Support
      .show(Screen.customerSupport): .presentModally { [unowned self] context in
        CustomerSupportVC(store: self.store, localState: CustomerSupportLS())
      },
      .hide(Screen.customerSupport): .dismissModally(behaviour: .hard),

      // Alert
      .show(Screen.alert): .custom { [weak self] _, _, animated, context, completion in
        let content = context as? Alert.Model ?? AppLogger.fatalError("Invalid context")
        let vc = UIAlertController(content: content)
        self?.recursivePresent(vc, animated: false, completion: completion)
      },

      // Update Country
      .show(Screen.updateCountry): .presentModally { context in
        let countriesOfInterestLS = context as? CountriesOfInterestLS ?? AppLogger.fatalError("invalid context")
        return CountriesOfInterestVC(
          store: self.store,
          localState: countriesOfInterestLS
        )
      },

      // Share Text
      .show(Screen.shareText): .custom { [weak self] _, _, animated, context, completion in
        let text = context as? String ?? AppLogger.fatalError("Invalid context")
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        self?.recursivePresent(vc, animated: animated, completion: completion)
      },

      // Permission Tutorial
      .show(Screen.permissionTutorial): .presentModally { context in
        let localState = context as? PermissionTutorialLS ?? AppLogger.fatalError("Invalid context")
        return PermissionTutorialVC(store: self.store, localState: localState)
      },
      .hide(Screen.permissionTutorial): .dismissModally(behaviour: .hard),

      // Suggestions
      .show(Screen.suggestions): .presentModally { [unowned self] context in
        SuggestionsVC(store: self.store, localState: SuggestionsLS())
      },
      .hide(Screen.suggestions): .dismissModally(behaviour: .hard),

      // Mail composer
      .show(Screen.mailComposer): .presentModally { context in
        let context = context as? MessageComposerContext ?? AppLogger
          .fatalError("MessageComposer should be invoked with a context of type MessageComposerContext")
        return MessageComposer(context: context)
      }
    ]
  }
}

// MARK: SensitiveDataCover

extension SensitiveDataCoverVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.sensitiveDataCover.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .hide(Screen.sensitiveDataCover): .dismissModally(behaviour: .soft)
    ]
  }
}

// MARK: - Common

// MARK: Confirmation

extension ConfirmationVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.confirmation.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .hide(Screen.confirmation): .dismissModally(behaviour: .soft)
    ]
  }
}

// MARK: Loading

extension LoadingVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.loading.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .hide(Screen.loading): .dismissModally(behaviour: .soft)
    ]
  }
}

// MARK: Permission Tutorial

extension PermissionTutorialVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.permissionTutorial.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .show(Screen.faq): .presentModally { _ in
        FaqVC(store: self.store, localState: FAQLS(isPresentedModally: true))
      },
      .show(Screen.loading): .presentModally { [unowned self] context in
        let ls = context as? LoadingLS ?? AppLogger.fatalError("Invalid context")
        let vc = LoadingVC(store: self.store, localState: ls)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        return vc
      },
      .show(Screen.alert): .custom { [weak self] _, _, animated, context, completion in
        let content = context as? Alert.Model ?? AppLogger.fatalError("Invalid context")
        let vc = UIAlertController(content: content)
        self?.recursivePresent(vc, animated: false, completion: completion)
      },

      .hide(Screen.loading): .dismissModally(behaviour: .soft),
      .hide(Screen.faq): .dismissModally(behaviour: .hard)
    ]
  }
}

// MARK: Permission Overlay

extension OnboardingPermissionOverlayVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.permissionOverlay.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [:]
  }
}

// MARK: - Home

extension HomeVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.home.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .show(Screen.fixActiveService): .presentModally { context in
        let navigationContext = context as? OnboardingContainerNC.NavigationContext ?? AppLogger.fatalError("Invalid context")

        return FixActiveService(with: self.store, navigationContext: navigationContext)
      },
      .show(Screen.confirmation): .presentModally { context in
        let localState = context as? ConfirmationLS ?? AppLogger.fatalError("Invalid context")
        return ConfirmationVC(store: self.store, localState: localState)
      },


      .hide(Screen.fixActiveService): .dismissModally(behaviour: .hard)
    ]
  }
}

// MARK: Fix Service

class FixActiveService: OnboardingContainerNC {
  override var routeIdentifier: RouteElementIdentifier {
    return Screen.fixActiveService.rawValue
  }

  override var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .show(Screen.fixActiveService): .custom { _, _, animated, context, completion in
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

      .hide(Screen.permissionTutorial): .dismissModally(behaviour: .hard),
      .hide(Screen.permissionOverlay): .dismissModally(behaviour: .hard)
    ]
  }
}

// MARK: Suggestions

extension SuggestionsVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.suggestions.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [:]
  }
}

// MARK: - Settings

extension SettingsNC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.settings.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .show(Screen.uploadData): .push { context in
        let ls = context as? UploadDataLS ?? AppLogger.fatalError("invalid context")
        return UploadDataVC(store: self.store, localState: ls)
      },
      .show(Screen.uploadDataAutonomous): .push { context in
        let ls = context as? UploadDataAutonomousLS ?? AppLogger.fatalError("invalid context")
        return UploadDataAutonomousVC(store: self.store, localState: ls)
                },
      .show(Screen.chooseDataUploadMode): .push { _ in
        return ChooseDataUploadModeVC(store: self.store, localState: ChooseDataUploadModeLS())
                },
      .show(Screen.faq): .push { _ in
        FaqVC(store: self.store, localState: FAQLS(isPresentedModally: false))
      },

      .show(Screen.updateProvince): .presentModally { context in
        let province = context as? Province ?? AppLogger.fatalError("Invalid context")
        return UpdateProvinceNC(
          with: self.store,
          navigationContext: .init(child: .updateRegion(currentUserProvince: province))
        )
      },

      .show(Screen.updateCountry): .presentModally { context in
        let countriesOfInterestLS = context as? CountriesOfInterestLS ?? AppLogger.fatalError("Invalid context")
        return CountriesOfInterestVC(
          store: self.store,
          localState: countriesOfInterestLS
        )
      },

      .show(Screen.privacy): .presentModally { context in
        PrivacyVC(store: self.store, localState: .init(kind: .settings))
      },

      .hide(Screen.uploadData): .pop,
      .hide(Screen.faq): .pop,
      .hide(Screen.updateProvince): .dismissModally(behaviour: .hard),
      .hide(Screen.privacy): .dismissModally(behaviour: .hard),
      .hide(Screen.chooseDataUploadMode): .pop,
      .hide(Screen.uploadDataAutonomous): .pop

    ]
  }
}

// MARK: - Home

extension HomeNC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.home.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .show(Screen.uploadData): .push { context in
        let ls = context as? UploadDataLS ?? AppLogger.fatalError("invalid context")
        return UploadDataVC(store: self.store, localState: ls)
      },
        
      .show(Screen.uploadDataAutonomous): .push { context in
        let ls = context as? UploadDataAutonomousLS ?? AppLogger.fatalError("invalid context")
        return UploadDataAutonomousVC(store: self.store, localState: ls)
        },
        
      .show(Screen.chooseDataUploadMode): .push { _ in
          return ChooseDataUploadModeVC(store: self.store, localState: ChooseDataUploadModeLS())
        },

      .show(Screen.greenCertificate): .push { _ in
        return GreenCertificateVC(store: self.store, localState: GreenCertificateLS())
          },
      .show(Screen.greenCertificateVaccineDetail): .presentModally { context in
        let ls = context as? GreenCertificateVaccineDetailLS ?? AppLogger.fatalError("invalid context")
        return GreenCertificateVaccineDetailVC(store: self.store, localState: ls)
          },
      .show(Screen.greenCertificateRecoveryDetail): .presentModally { context in
        let ls = context as? GreenCertificateRecoveryDetailLS ?? AppLogger.fatalError("invalid context")
        return GreenCertificateRecoveryDetailVC(store: self.store, localState: ls)
        },
      .show(Screen.greenCertificateTestDetail): .presentModally { context in
        let ls = context as? GreenCertificateTestDetailLS ?? AppLogger.fatalError("invalid context")
        return GreenCertificateTestDetailVC(store: self.store, localState: ls)
        },
      .show(Screen.greenCertificateExemptionDetail): .presentModally { context in
        let ls = context as? GreenCertificateExemptionDetailLS ?? AppLogger.fatalError("invalid context")
        return GreenCertificateExemptionDetailVC(store: self.store, localState: ls)
        },
      .show(Screen.generateGreenCertificate): .push { _ in
        return GenerateGreenCertificateVC(store: self.store, localState: GenerateGreenCertificateLS())
          },
      .hide(Screen.uploadData): .pop,
      .hide(Screen.chooseDataUploadMode): .pop,
      .hide(Screen.uploadDataAutonomous): .pop,
      .hide(Screen.greenCertificate): .pop,
      .hide(Screen.generateGreenCertificate): .pop,
      .hide(Screen.greenCertificateVaccineDetail): .dismissModally(behaviour: .hard),
      .hide(Screen.greenCertificateRecoveryDetail): .dismissModally(behaviour: .hard),
      .hide(Screen.greenCertificateTestDetail): .dismissModally(behaviour: .hard),
      .hide(Screen.greenCertificateExemptionDetail): .dismissModally(behaviour: .hard),
      
    ]
  }
}

// MARK: Upload Data

extension UploadDataVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.uploadData.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [:]
  }
}
extension UploadDataAutonomousVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.uploadDataAutonomous.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [:]
  }
}
extension ChooseDataUploadModeVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.chooseDataUploadMode.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [:]
  }
}

extension GreenCertificateVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.greenCertificate.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [:]
  }
}
extension GenerateGreenCertificateVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.generateGreenCertificate.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [:]
  }
}
extension GreenCertificateVaccineDetailVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.greenCertificateVaccineDetail.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [:]
  }
}
extension GreenCertificateRecoveryDetailVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.greenCertificateRecoveryDetail.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [:]
  }
}
extension GreenCertificateTestDetailVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.greenCertificateTestDetail.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [:]
  }
}
extension GreenCertificateExemptionDetailVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.greenCertificateExemptionDetail.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [:]
  }
}
extension ConfirmUploadVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.confirmUpload.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
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

      .show(Screen.confirmation): .presentModally { context in
        let localState = context as? ConfirmationLS ?? AppLogger.fatalError("Invalid context")
        return ConfirmationVC(store: self.store, localState: localState)
      },

      .hide(Screen.permissionTutorial): .dismissModally(behaviour: .hard),
      .hide(Screen.permissionOverlay): .dismissModally(behaviour: .hard)
    ]
  }
}

// MARK: Customer Support

extension CustomerSupportVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.customerSupport.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .show(Screen.faq): .presentModally { _ in
        FaqVC(store: self.store, localState: FAQLS(isPresentedModally: true))
      },
      .hide(Screen.faq): .dismissModally(behaviour: .hard)
    ]
  }
}

// MARK: Update Province

class UpdateProvinceNC: OnboardingContainerNC {
  override var routeIdentifier: RouteElementIdentifier {
    return Screen.updateProvince.rawValue
  }

  override var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .show(Screen.onboardingStep): .custom { _, _, animated, context, completion in
        let navContext = context as? OnboardingContainerNC.NavigationContext ?? AppLogger.fatalError("Invalid Context")
        self.pushViewController(using: navContext, animated: animated)
        completion()
      }
    ]
  }
}

// MARK: Update Country

extension CountriesOfInterestVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.updateCountry.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .hide(Screen.updateCountry): .dismissModally(behaviour: .hard)
    ]
  }
}

// MARK: FAQ

extension FaqVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.faq.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .show(Screen.question): .presentModally { [unowned self] context in
        let localState = context as? QuestionLS ?? AppLogger.fatalError("invalid context")
        let vc = QuestionVC(store: self.store, localState: localState)
        return vc
      },

      .hide(Screen.question): .dismissModally(behaviour: .hard)
    ]
  }
}

extension QuestionVC: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.question.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [:]
  }
}
