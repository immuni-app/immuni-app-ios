// WelcomeView.swift
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

import Tempura

// MARK: - View Model

struct WelcomeVM: Equatable {
  static let numberOfPages: Int = 4

  /// The index of the currently visible page.
  let currentPage: Int

  var isFinalPage: Bool { self.currentPage == Self.numberOfPages - 1 }

  var mainButtonCopy: String {
    if self.isFinalPage {
      return L10n.WelcomeView.goNext
    } else {
      return L10n.WelcomeView.nextPageTitle
    }
  }

  func shouldUpdatePage(oldModel: Self?) -> Bool {
    return self.currentPage != oldModel?.currentPage
  }
}

extension WelcomeVM: ViewModelWithLocalState {
  init?(state: AppState?, localState: WelcomeLS) {
    self.currentPage = localState.currentPage
  }
}

// MARK: - View

class WelcomeView: UIView, ViewControllerModellableView {
  static var horizontalSpacing: CGFloat = UIDevice.getByScreen(normal: 30.0, narrow: 12.0)

  // MARK: - Interactions

  var didTapNext: Interaction?
  var didScrollToPage: CustomInteraction<Int>?
  var didTapDiscoverMore: Interaction?

  // MARK: - Subviews

  let scrollView = UIScrollView()

  let welcomeViewPageOne = WelcomePageView()
  let welcomeViewPageTwo = WelcomePageView()
  let welcomeViewPageThree = WelcomePageView()
  let welcomeViewPageFour = WelcomePageView()

  let pageControl = UIPageControl()
  var discoverMoreButton = TextButton()
  var nextButton = ButtonWithInsets()

  lazy var pages: [WelcomePageView] = {
    [
      self.welcomeViewPageOne,
      self.welcomeViewPageTwo,
      self.welcomeViewPageThree,
      self.welcomeViewPageFour
    ]
  }()

  // MARK: - Setup

  func setup() {
    self.addSubview(self.scrollView)
    self.addSubview(self.pageControl)
    self.addSubview(self.discoverMoreButton)
    self.addSubview(self.nextButton)

    self.pages.forEach { self.scrollView.addSubview($0) }

    self.scrollView.delegate = self
    self.pageControl.isEnabled = false

    self.nextButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapNext?()
    }

    self.discoverMoreButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapDiscoverMore?()
    }

    self.welcomeViewPageOne.model = WelcomePageVM.pageOneVM
    self.welcomeViewPageTwo.model = WelcomePageVM.pageTwoVM
    self.welcomeViewPageThree.model = WelcomePageVM.pageThreeVM
    self.welcomeViewPageFour.model = WelcomePageVM.pageFourVM
  }

  // MARK: - Style

  func style() {
    Self.Style.root(self)
    Self.Style.scroll(self.scrollView)
    Self.Style.pageControl(self.pageControl)
    Self.Style.discoverMore(self.discoverMoreButton)

    self.pageControl.accessibilityElementsHidden = true
  }

  // MARK: - Update

  func update(oldModel: WelcomeVM?) {
    guard let model = self.model, model != oldModel else { return }

    SharedStyle.primaryButton(self.nextButton, title: model.mainButtonCopy)

    if model.shouldUpdatePage(oldModel: oldModel) {
      self.scrollTo(page: model.currentPage, animated: oldModel != nil)
    }
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.nextButton.pin
      .horizontally(Self.horizontalSpacing)
      .maxWidth(315)
      .height(55)
      .bottom(self.safeAreaInsets.bottom + UIDevice.getByScreen(normal: 30, short: 20))
      .justify(.center)

    self.discoverMoreButton.pin
      .horizontally(Self.horizontalSpacing)
      .above(of: self.nextButton)
      .marginBottom(UIDevice.getByScreen(normal: 25, narrow: 10))
      .sizeToFit(.width)

    self.pageControl.pin
      .width(80)
      .hCenter()
      .above(of: self.discoverMoreButton)
      .marginBottom(UIDevice.getByScreen(normal: 20, narrow: 10))
      .sizeToFit(.width)

    self.scrollView.pin.all()

    for (index, page) in self.pages.enumerated() {
      page.pin
        .top()
        .above(of: self.pageControl)
        .marginBottom(UIDevice.getByScreen(normal: 20, narrow: 10))
        .width(self.frame.width)
        .start(self.frame.width * CGFloat(index))
    }

    self.updateAfterLayout()
  }

  private func updateAfterLayout() {
    self.scrollView.contentSize = CGSize(
      width: self.frame.width * CGFloat(WelcomeVM.numberOfPages),
      height: self.frame.height
    )
  }

  func playCurrentPage() {
    guard let model = self.model else {
      return
    }
    self.pages[model.currentPage].playAnimation()
  }

  func pauseAllPages() {
    for page in self.pages { page.pauseAnimation() }
  }
}

// MARK: - Style

private extension WelcomeView {
  enum Style {
    static func root(_ view: UIView) {
      view.backgroundColor = Palette.white
    }

    static func scroll(_ scrollView: UIScrollView) {
      scrollView.backgroundColor = Palette.white
      scrollView.isPagingEnabled = true
      scrollView.showsHorizontalScrollIndicator = false
      scrollView.showsVerticalScrollIndicator = false
    }

    static func pageControl(_ pageControl: UIPageControl) {
      pageControl.numberOfPages = WelcomeVM.numberOfPages
      pageControl.currentPageIndicatorTintColor = Palette.primary
      pageControl.pageIndicatorTintColor = Palette.grayNormal.withAlphaComponent(0.2)
    }

    static func discoverMore(_ button: TextButton) {
      let textStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.primary),
        .alignment(.center)
      )

      button.contentHorizontalAlignment = .center
      button.contentVerticalAlignment = .bottom
      button.titleLabel?.numberOfLines = 0
      button.attributedTitle = L10n.WelcomeView.discoverMore.styled(with: textStyle)
    }
  }
}

// MARK: - ScrollView Delegate

extension WelcomeView: UIScrollViewDelegate {
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard !decelerate else {
      return
    }
    self.scrollViewDidEndScroll(scrollView)
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.scrollViewDidEndScroll(scrollView)
  }
}

// MARK: - Private Helpers

extension WelcomeView {
  private func scrollViewDidEndScroll(_ scrollView: UIScrollView) {
    let page = Int(scrollView.contentOffset.x / self.frame.width)
    self.didScrollToPage?(page)
  }

  func scrollTo(page: Int, animated: Bool) {
    var frame: CGRect = self.frame
    frame.origin.x = frame.size.width * CGFloat(page)
    frame.origin.y = 0
    self.scrollView.scrollRectToVisible(frame, animated: animated)

    self.pauseAllPages()
    self.playCurrentPage()

    UIView.update(shouldAnimate: animated) {
      self.pageControl.currentPage = page
    }
  }
}
