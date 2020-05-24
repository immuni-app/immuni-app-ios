// FaqUITests.swift
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

import Models
import TempuraTesting
import XCTest

@testable import Immuni

class FaqUITests: AppViewTestCase, ViewTestCase {
  typealias V = FaqView

  func testFaq() {
    self.uiTest(
      testCases: [
        "faq_view": FaqVM(faqs: [], isPresentedModally: false, isHeaderVisible: false),
        "faq_empty": FaqVM(faqs: FAQ.mockedFaqs, isPresentedModally: false, isHeaderVisible: false),
        "faq_modal": FaqVM(faqs: FAQ.mockedFaqs, isPresentedModally: true, isHeaderVisible: false),
        "faq_view_with_header": FaqVM(faqs: [], isPresentedModally: false, isHeaderVisible: true),
        "faq_modal_with_header": FaqVM(faqs: FAQ.mockedFaqs, isPresentedModally: true, isHeaderVisible: true)
      ],
      context: UITests.Context<V>()
    )
  }

  func scrollViewsToTest(in view: FaqView, identifier: String) -> [String: UIScrollView] {
    return [
      "collection": view.collection
    ]
  }
}

extension FAQ {
  static let mockedFaqs: [FAQ] = [
    FAQ(title: "What is Immuni?", content: ""),
    FAQ(title: "How does Immuni’s proximity tracing work?", content: ""),
    FAQ(title: "Does the app track my location?", content: ""),
    FAQ(title: "How’s my privacy protected?", content: ""),
    FAQ(title: "Is the code open source?", content: ""),
    FAQ(title: "Why is Immuni important?", content: ""),
    FAQ(title: "Is it really necessary that everybody uses the app? What happens if not enough people do?", content: ""),
    FAQ(title: "What should I do to make sure I’m using the app correctly?", content: ""),
    FAQ(title: "Does this app make medical diagnoses or provide medical advice?", content: ""),
    FAQ(title: "What devices and operating systems are supported?", content: ""),
    FAQ(title: "How were Immuni and Bending Spoons selected among the available options?", content: ""),
    FAQ(title: "Is Bending Spoons getting paid for Immuni?", content: ""),
    FAQ(title: "Are the instructions and advice that the app provides reliable?", content: ""),
    FAQ(title: "I don’t have a smartphone compatible with Immuni—what should I do?", content: ""),
    FAQ(title: "Is the app going to drain my smartphone’s battery?", content: ""),
    FAQ(title: "Where can I download Immuni?", content: ""),
    FAQ(title: "Can minors use the app?", content: ""),
    FAQ(title: "Can I access my profile from multiple devices?", content: ""),
    FAQ(title: "Is Immuni run by the government?", content: ""),
    FAQ(title: "Do I need to pay to use Immuni?", content: ""),
    FAQ(title: "Can I choose not to use the app?", content: ""),
    FAQ(title: "Immuni tells me I may have COVID-19, but I feel fine. What should I do?", content: ""),
    FAQ(title: "I was somewhere or with someone that I would like to keep private. Does Immuni compromise this?", content: ""),
    FAQ(title: "Can I change the language of the app?", content: ""),
    FAQ(title: "Do I need to sign up with my email address and password?", content: ""),
    FAQ(title: "Does Immuni need to be in the foreground to work? Can I use other apps?", content: ""),
    FAQ(title: "Do I need to keep my smartphone’s Bluetooth turned on all the time?", content: ""),
    FAQ(title: "I often keep my phone on airplane mode. Is this OK?", content: ""),
    FAQ(title: "How much data traffic does Immuni consume?", content: ""),
    FAQ(title: "I need help with the app. Who should I contact?", content: ""),
    FAQ(title: "The app prompted me to update it: what happens if I don’t do so?", content: ""),
    FAQ(title: "Can I use the app without internet connection?", content: ""),
    FAQ(title: "What personal information does Immuni gather? Who can access and use my data?", content: ""),
    FAQ(title: """
    With which other sites or apps does Immuni share my data? Does it sell my data? Is my data used for advertising purposes?
    """, content: ""),
    FAQ(title: "How can I provide feedback to improve the app?", content: "")
  ]
}
