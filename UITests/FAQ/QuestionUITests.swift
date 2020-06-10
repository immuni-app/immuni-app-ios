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
    return QuestionVM(question: FAQ.mockedFAQ.title, answer: FAQ.mockedFAQ.content, isHeaderVisible: false)
  }

  var scrolledVM: QuestionVM {
    return QuestionVM(question: FAQ.mockedFAQ.title, answer: FAQ.mockedFAQ.content, isHeaderVisible: true)
  }

  func testQuestion() {
    self.uiTest(
      testCases: [
        "question_view": self.questionVM
      ],
      context: UITests.Context<V>(renderSafeArea: false)
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
    return self.scrollView.contentSize.height > self.scrollView.frame.height + self.scrollView.contentInset.vertical
  }
}
