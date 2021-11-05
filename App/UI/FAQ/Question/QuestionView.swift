// QuestionView.swift
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

struct QuestionVM: ViewModelWithLocalState {
  /// The question to be shown.
  let question: String
  /// The answer of the question to be shown.
  let answer: String
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  let isHeaderVisible: Bool

  func shouldUpdateHeader(oldVM: Self?) -> Bool {
    return self.isHeaderVisible != oldVM?.isHeaderVisible
  }
}

extension QuestionVM {
  init?(state: AppState?, localState: QuestionLS) {
    self.question = localState.faq.title
    self.answer = localState.faq.content
    self.isHeaderVisible = localState.isHeaderVisible
  }
}

// MARK: - View

class QuestionView: UIView, ViewControllerModellableView {
  typealias VM = QuestionVM

  let scrollView = UIScrollView()
  private let question = UILabel()
  private let answer = UILabel()

  private let headerView = UIView()
  private let headerTitleView = UILabel()
  private var closeButton = ImageButton()

  var didTapClose: Interaction?
  var updateOffsetFromTitle: CustomInteraction<CGFloat>?

  // MARK: - Setup

  func setup() {
    self.addSubview(self.scrollView)
    self.scrollView.addSubview(self.question)
    self.scrollView.addSubview(self.answer)

    self.addSubview(self.headerView)
    self.addSubview(self.closeButton)
    self.headerView.addSubview(self.headerTitleView)

    self.scrollView.delegate = self

    self.closeButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapClose?()
    }
  }

  // MARK: - Style

  func style() {
    Self.Style.background(self)
    Self.Style.scrollView(self.scrollView)
    Self.Style.header(self.headerView)
    SharedStyle.closeButton(self.closeButton)
  }

  // MARK: - Update

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.question(self.question, content: model.question)
    Self.Style.answer(self.answer, content: model.answer)
    Self.Style.headerTitle(self.headerTitleView, content: model.question)

    if model.shouldUpdateHeader(oldVM: oldModel) {
      UIView.update(shouldAnimate: oldModel != nil) {
        self.headerView.alpha = model.isHeaderVisible.cgFloat
      }
    }
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.closeButton.pin
      .top(30 + self.safeAreaInsets.top)
      .right(28)
      .sizeToFit()

    self.headerTitleView.pin
      .left(30)
      .before(of: self.closeButton)
      .vCenter(to: self.closeButton.edge.vCenter)
      .marginRight(15)
      .sizeToFit(.width)

    self.headerView.pin
      .left()
      .top()
      .right()
      .height(self.headerTitleView.frame.maxY + 20)

    self.scrollView.pin
      .horizontally()
      .top(self.safeAreaInsets.top)
      .bottom(self.safeAreaInsets.bottom)

    self.question.pin
      .left(30)
      .right(80)
      .sizeToFit(.width)
      .top(55)

    self.answer.pin
      .horizontally(30)
      .sizeToFit(.width)
      .below(of: self.question)
      .marginTop(25)

    self.scrollView.contentSize = CGSize(width: self.bounds.width, height: self.answer.frame.maxY)
  }
}

// MARK: - Style

private extension QuestionView {
  enum Style {
    static func background(_ view: UIView) {
      view.backgroundColor = Palette.white
    }

    static func scrollView(_ scrollView: UIScrollView) {
      scrollView.backgroundColor = .clear
      scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
      scrollView.showsVerticalScrollIndicator = false
    }

    static func question(_ label: UILabel, content: String) {
      let textStyle = TextStyles.h2.byAdding(
        .color(Palette.grayDark),
        .alignment(.left)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }

    static func answer(_ label: UILabel, content: String) {
      let boldStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.grayDark),
        .alignment(.left)
      )
      let textStyle = TextStyles.p.byAdding(
        .color(Palette.grayNormal),
        .alignment(.left),
        .xmlRules([.style("b", boldStyle)])
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }

    static func header(_ view: UIView) {
      view.backgroundColor = Palette.white
      view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
      view.layer.cornerRadius = 15.0
      view.addShadow(.headerLightBlue)
    }

    static func headerTitle(_ label: UILabel, content: String) {
      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: TextStyles.h4.byAdding(
          .color(Palette.grayDark)
        ),
        numberOfLines: 1
      )
    }
  }
}

// MARK: - UIScrollViewDelegate

extension QuestionView: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offsetFromTitle = scrollView.contentOffset.y - self.question.frame.maxY + self.headerView.frame.height
    self.updateOffsetFromTitle?(offsetFromTitle)
  }
}
