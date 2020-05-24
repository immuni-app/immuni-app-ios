// QuestionUITests.swift
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

class QuestionUITests: AppViewTestCase, ViewTestCase {
  typealias V = QuestionView

  var questionVM: QuestionVM {
    let mocked = FAQ.mockedQuestion
    return QuestionVM(question: mocked.title, answer: mocked.content, isHeaderVisible: false)
  }

  var scrolledVM: QuestionVM {
    let mocked = FAQ.mockedQuestion
    return QuestionVM(question: mocked.title, answer: mocked.content, isHeaderVisible: true)
  }

  func testQuestion() {
    self.uiTest(
      testCases: [
        "question_view": self.questionVM
      ],
      context: UITests.Context<V>()
    )
  }

  func testQuestionScrolled() {
    let context = UITests.Context<V>(hooks: [
      UITests.Hook.viewDidLayoutSubviews: { view in
        if view.contentCollectionCanScroll {
          view.scrollView.contentOffset = CGPoint(x: 0, y: view.scrollView.contentSize.height - view.scrollView.frame.height)
        } else {
          view.scrollView.contentOffset = .zero
        }
      }
    ])

    self.uiTest(
      testCases: [
        "question_scrolled": self.scrolledVM
      ],
      context: context
    )
  }

  func scrollViewsToTest(in view: QuestionView, identifier: String) -> [String: UIScrollView] {
    return [
      "collection": view.scrollView
    ]
  }
}

extension QuestionView {
  var contentCollectionCanScroll: Bool {
    return self.scrollView.contentSize.height > self.frame.height
  }
}

extension FAQ {
  // swiftlint:disable line_length
  static let mockedQuestion: FAQ =
    FAQ(
      title: "How does Immuni’s proximity tracing work?",
      content:
      """
      Immuni proximity tracing system aims to alert users after they have been exposed to a potential risk of infection.

      The system is based on <b>Bluetooth Low Energy</b> technology and doesn’t use any kind of geolocalization whatsoever—not even GPS data. The app doesn’t (and can’t) collect any personal data of the user, such as their name, surname, birth date, address, telephone number, or email address. Therefore, Immuni is able to determine that contact has taken place between two users (referred to as an exposure event), without knowing who those users are and where the contact occurred. It only knows that a contact occurred, how long it lasted, and roughly what distance separated the two users.

      <b>Here below is a simplified explanation of how the system works:
      Alice and Marco install the Immuni app. Their smartphones start sending a continuous Bluetooth Low Energy signal that contains a proximity identifier. When Alice gets in close proximity to Marco, their smartphones mutually store the other’s proximity identifier, taking note of that exposure event. Their phones also note how long the event lasted and the approximate distance between the two devices.</b>
      Afterwards, Marco tests positive for COVID-19. Thanks to the help of a healthcare professional, Marco is able to transfer some cryptographic keys to a server, used to derive his proximity identifier.
      On a regular basis, the app downloads all the new cryptographic keys sent to the server by the users who tested positive for the virus. The app uses these keys to derive their proximity identifiers and checks if any of those identifiers correspond to those stored in Alice’s or Marco’s device memory from previous days. As such, Alice’s app will find Marco’s proximity identifier, it will check the length and the distance of the contact to evaluate the risk of an infection and, if necessary, it will inform Alice and provide recommended actions.

      Proximity identifiers are generated randomly, and they don’t contain any information about the device or the user. Moreover, they change several times per hour to protect your privacy even more.
      """
    )
}
