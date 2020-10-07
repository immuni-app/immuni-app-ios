// OnboardingCountryVC.swift
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
import Models
import Tempura

final class OnboardingCountryVC: ViewControllerWithLocalState<OnboardingCountryView> {
    
  override func setupInteraction() {
    
    self.rootView.userDidTapClose = { [weak self] in
         self?.store.dispatch(Hide(Screen.updateCountry, animated: true))
       }
    
    self.rootView.userDidTapComplete = { [weak self] in
        guard let countries = self!.localState.currentCountries else {
            return
             }
        self!.store.dispatch(Logic.Settings.CompleteUpdateCountries(newCountries: countries))
       }
    

    self.rootView.userDidScroll = { [weak self] scrollOffset in
      if scrollOffset > 0 {
        self?.localState.isHeaderVisible = true
      } else if scrollOffset < -20 {
        self?.localState.isHeaderVisible = false
      }
    }

    self.rootView.userDidSelectCountry = { [weak self] countryOfInterest in
        
        let country = Country(countryId: countryOfInterest!.0, countryHumanReadableName: countryOfInterest!.1)
        let isSelected = countryOfInterest!.2
        let isDisable = countryOfInterest!.3
        
        guard !isDisable else {
            return
        }
        if self?.localState.currentCountries != nil {
            
            // Remove country if it's selected
          
            if self!.localState.currentCountries!.contains(CountrySelection(country: country, selectionDate: Date()))
            {
                self!.localState.currentCountries!.remove(at: self!.localState.currentCountries!.firstIndex(of: CountrySelection(country: country, selectionDate: Date()))!)
                }
            else{
                self?.localState.currentCountries?.append(CountrySelection(country: country, selectionDate: Date()))
            }
        }
        else{
            self?.localState.currentCountries = []
            self?.localState.currentCountries?.append(CountrySelection(country: country, selectionDate: Date()))
        }

      self?.onboardingContainer?.setNeedsRefreshControls()
    }
  }
}

extension OnboardingCountryVC: OnboardingViewController {
    
  func handleNext() {}
    
  var nextButtonTitle: String {
     L10n.Settings.UpdateProvince.updateProvince
  }
    
  var shouldNextButtonBeEnabled: Bool {
    return false
  }

  var shouldShowBackButton: Bool {
    return true
  }

  var shouldShowNextButton: Bool {
    true
  }

  var shouldShowGradient: Bool {
    true
  }
}

struct OnboardingCountryLS: LocalState {
    
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  var isHeaderVisible: Bool

  
  // var currentCountries: [Country]
  /// The currently selected Country.
  var currentCountries: [CountrySelection]?
    
  var countryList: [String:String]
    
    init( currentCountries: [CountrySelection]?, countryList: [String:String]) {
    self.isHeaderVisible = false
    self.currentCountries = currentCountries!
    self.countryList = countryList

  }
}

