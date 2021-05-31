// GreenCertificateView.swift
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

struct GreenCertificateVM: ViewModelWithLocalState {

    /// True if it's not possible to execute a new request.
    let isLoading: Bool
    
    var state: CardView = .qr

    var greenCertificate: String?

    enum StatusGreenCertificate: Int {
      case active
      case inactive

    }

    /// The currently status.
    var status: StatusGreenCertificate

}

extension GreenCertificateVM {
    init?(state : AppState?, localState: GreenCertificateLS) {
        isLoading = localState.isLoading
        self.status = .inactive
        self.greenCertificate = state?.user.greenCertificate
    }
}

// MARK: - View

class GreenCertificateView: UIView, ViewControllerModellableView {
    typealias VM = GreenCertificateVM

    private static let horizontalSpacing: CGFloat = 30.0
    static let orderLeftMargin: CGFloat = UIDevice.getByScreen(normal: 70, narrow: 50)
    static let tabBarHeight: CGFloat = 69

    private let backgroundGradientView = GradientView()
    private let title = UILabel()
    private let inactiveLabel = UILabel()
    private let inactiveImage = UIImageView()

    private var backButton = ImageButton()
    private var qrTab = UIImageView()
    private var dataTab = UIImageView()
    let scrollView = UIScrollView()
    private let headerView = GreenCertificateHeaderView()

    private let container = UIView()
    
    private var qrCode = UIImageView()
    private var actionButton = ButtonWithInsets()
    private var deleteButton = ButtonWithInsets()
    private var stateLabel = UILabel()
    private var nameLabel = UILabel()
    private var surnameLabel = UILabel()

    var lineView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1.0))
    
    var didTapBack: Interaction?

    var didTapDiscoverMore: Interaction?
    var didTapRetriveGreenCertificate: Interaction?
    var didTapDeleteGreenCertificate: Interaction?


    // MARK: - Setup

    func setup() {
        addSubview(container)

        container.addSubview(lineView)
        container.addSubview(stateLabel)
        container.addSubview(qrCode)
        container.addSubview(deleteButton)

        addSubview(actionButton)
        addSubview(backgroundGradientView)
        addSubview(scrollView)
        addSubview(title)
        addSubview(backButton)
        scrollView.addSubview(actionButton)
        scrollView.addSubview(headerView)

        scrollView.addSubview(container)

        backButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapBack?()
           }
        actionButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapRetriveGreenCertificate?()
           }
        deleteButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapDeleteGreenCertificate?()
           }
        
        container.addGestureRecognizer(createSwipeGestureRecognizer(for: .left))
        container.addGestureRecognizer(createSwipeGestureRecognizer(for: .right))

       }
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        // Current Frame
        var frame = container.frame

        switch sender.direction {
          case .up:
            frame.origin.y -= 100.0
          case .down:
            frame.origin.y += 100.0
          case .left:
            model?.state = .data
            frame.origin.x -= 100.0
          case .right:
            model?.state = .qr
            frame.origin.x += 100.0
          default:
            break
        }
    }
    private func createSwipeGestureRecognizer(for direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        // Initialize Swipe Gesture Recognizer
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))

        // Configure Swipe Gesture Recognizer
        swipeGestureRecognizer.direction = direction

        return swipeGestureRecognizer
    }
    // MARK: - Style
    
    func generateQRCode(from string: String) -> UIImage? {

      // Get data from the string
      let data = string.data(using: String.Encoding.ascii)
      // Get a QR CIFilter
      guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil}
      // Input the data
      qrFilter.setValue(data, forKey: "inputMessage")
      // Get the output image
      guard let qrImage = qrFilter.outputImage else { return nil}
      // Scale the image
      let transform = CGAffineTransform(scaleX: 10, y: 10)
      let scaledQrImage = qrImage.transformed(by: transform)
      // Do some processing to get the UIImage
      let context = CIContext()
      guard let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) else { return nil}
      return UIImage(cgImage: cgImage)
     }

    func style() {
        Self.Style.background(self)
        Self.Style.backgroundGradient(backgroundGradientView)
        Self.Style.scrollView(scrollView)
        Self.Style.title(title, text: L10n.HomeView.GreenCertificate.title)
        Self.Style.inactiveLabel(inactiveLabel, text: L10n.HomeView.GreenCertificate.notPresentQrLabel)
        Self.Style.imageContent(inactiveImage, image: Asset.Home.inactive.image)
        Self.Style.container(container)
        SharedStyle.primaryButton(
          deleteButton,
          title: L10n.HomeView.GreenCertificate.deleteButton,
          icon: Asset.Home.trash.image,
          spacing: 8,
          tintColor: Palette.white,
          backgroundColor: Palette.grayDark,
          insets: UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 20),
          cornerRadius: 21,
          shadow: .grayDark
        )
        
        Self.Style.stateLabel(nameLabel, text: "Mario", color: Palette.purple)
        Self.Style.stateLabel(surnameLabel, text: "Rossi", color: Palette.purple)
        
        lineView.layer.borderWidth = 1.0
        lineView.layer.borderColor = Palette.grayExtraWhite.cgColor
        
        Self.Style.actionButton(actionButton, icon: Asset.Home.qr.image)
        
        SharedStyle.navigationBackButton(backButton)
    }

    // MARK: - Update

    func update(oldModel: VM?) {
        guard let model = self.model else {
            return
        }
        if let greenCertificate = model.greenCertificate {
            
          let dataDecoded: Data? = Data(base64Encoded: greenCertificate, options: .ignoreUnknownCharacters)
          if let dataDecoded = dataDecoded{
            let decodedimage = UIImage(data: dataDecoded)
            Self.Style.imageContent(qrCode, image: decodedimage!)
          }
            switch model.state {
              case .data:
                addSubview(nameLabel)
                scrollView.addSubview(nameLabel)
                addSubview(surnameLabel)
                scrollView.addSubview(surnameLabel)
                qrCode.removeFromSuperview()
                deleteButton.removeFromSuperview()
                Self.Style.imageContent(dataTab, image: Asset.Tabbar.settingsSelected.image)
                Self.Style.imageContent(qrTab, image: Asset.Tabbar.settingsUnselected.image)
              case .qr:
                addSubview(qrCode)
                addSubview(deleteButton)
                scrollView.addSubview(qrCode)
                scrollView.addSubview(deleteButton)
                surnameLabel.removeFromSuperview()
                nameLabel.removeFromSuperview()
                Self.Style.imageContent(qrTab, image: Asset.Tabbar.settingsSelected.image)
                Self.Style.imageContent(dataTab, image: Asset.Tabbar.settingsUnselected.image)
            }
          addSubview(qrTab)
          addSubview(dataTab)
          scrollView.addSubview(qrTab)
          scrollView.addSubview(dataTab)
          inactiveLabel.removeFromSuperview()
          inactiveImage.removeFromSuperview()
          Self.Style.stateLabel(stateLabel,text: L10n.HomeView.GreenCertificate.activeLabel, color: Palette.purple)
        }
        else{
          container.addSubview(inactiveLabel)
          scrollView.addSubview(inactiveLabel)
          container.addSubview(inactiveImage)
          scrollView.addSubview(inactiveImage)
          qrCode.removeFromSuperview()
          nameLabel.removeFromSuperview()
          surnameLabel.removeFromSuperview()
          deleteButton.removeFromSuperview()
          qrTab.removeFromSuperview()
          dataTab.removeFromSuperview()
          Self.Style.stateLabel(stateLabel,text: L10n.HomeView.GreenCertificate.inactiveLabel, color: Palette.grayPurple)
        }
        
        setNeedsLayout()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundGradientView.pin.all()

        backButton.pin
            .left(Self.horizontalSpacing)
            .top(universalSafeAreaInsets.top + 20)
            .sizeToFit()

        title.pin
            .vCenter(to: backButton.edge.vCenter)
            .horizontally(Self.horizontalSpacing + backButton.intrinsicContentSize.width + 5)
            .sizeToFit(.width)

        scrollView.pin
            .horizontally()
            .below(of: title)
            .marginTop(5)
            .bottom(universalSafeAreaInsets.bottom)

        headerView.pin
            .horizontally()
            .sizeToFit(.width)
            .top(30)
        
        container.pin
          .below(of: headerView)
          .marginTop(20)
          .horizontally(25)
          .height(UIDevice.getByScreen(normal: 540, short: 500))
        
        stateLabel.pin
          .minHeight(25)
          .marginTop(40)
          .below(of: headerView)
          .sizeToFit(.width)
          .horizontally(25)

        lineView.pin
          .below(of: headerView)
          .marginTop(80)
          .hCenter()
          .width(container.frame.width)
          .height(1)
        
        if model?.greenCertificate != nil {
        
            qrCode.pin
              .below(of: headerView)
              .marginTop(100)
              .hCenter()
              .width(container.frame.width*0.9)
              .height(container.frame.width*0.9)
            
            deleteButton.pin
              .hCenter()
              .size(self.buttonSize(for: self.bounds.width))
              .minHeight(25)
              .below(of: qrCode)
              .marginTop(20)
            
            nameLabel.pin
                .minHeight(25)
                .below(of: headerView)
                .marginTop(100)
                .sizeToFit(.width)
                .horizontally(25)
                
            surnameLabel.pin
                .minHeight(25)
                .below(of: nameLabel)
                .marginTop(20)
                .sizeToFit(.width)
                .horizontally(25)
            
            qrTab.pin
                .marginRight(15)
                .hCenter()
                .below(of: lineView)
                .marginTop(UIDevice.getByScreen(normal: 430, short: 350))
                .sizeToFit()
            
            dataTab.pin
                .marginLeft(15)
                .hCenter()
                .below(of: lineView)
                .marginTop(UIDevice.getByScreen(normal: 430, short: 350))
                .sizeToFit()
        }
        else {
            inactiveImage.pin
              .below(of: headerView)
              .marginTop(150)
              .hCenter()
              .width(200)
              .height(200)
            
            inactiveLabel.pin
              .below(of: inactiveImage)
              .marginTop(-40)
              .horizontally(Self.horizontalSpacing + backButton.intrinsicContentSize.width + 5)
              .sizeToFit(.width)
        }
        actionButton.pin
            .horizontally(45)
            .sizeToFit(.width)
            .minHeight(25)
            .below(of: container)
            .marginTop(20)
    
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: actionButton.frame.maxY)
    }
    func buttonSize(for width: CGFloat) -> CGSize {
      let labelWidth = width - 2 * HomeView.cellHorizontalInset - HomeDeactivateServiceCell.iconSize
        - self.deleteButton.insets.horizontal - self.deleteButton.titleEdgeInsets.horizontal
      var buttonSize = self.deleteButton.titleLabel?.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity)) ?? .zero
      buttonSize.width += HomeDeactivateServiceCell.iconSize + HomeDeactivateServiceCell.iconToTitle + self.deleteButton.insets.horizontal
      buttonSize.height = max(buttonSize.height, HomeDeactivateServiceCell.iconSize) + self.deleteButton.insets.vertical

      return buttonSize
    }
}

// MARK: - Style

private extension GreenCertificateView {
    enum Style {
        
        static func actionButton(
          _ button: ButtonWithInsets,
          icon: UIImage? = nil,
          tintColor: UIColor = Palette.white,
          backgroundColor: UIColor = Palette.primary,
          cornerRadius: CGFloat = 25,
          shadow: UIView.Shadow = .cardPrimary
        ) {
          
          let text = L10n.HomeView.GreenCertificate.retriveButton
          let textStyle = TextStyles.pSemibold.byAdding([
            .color(tintColor),
            .alignment(.center)
          ])

          button.setBackgroundColor(backgroundColor, for: .normal)
          button.setAttributedTitle(text.styled(with: textStyle), for: .normal)
          button.setImage(icon, for: .normal)
          button.tintColor = tintColor
          button.insets = UIDevice.getByScreen(normal: .init(deltaX: 25, deltaY: 5), narrow: .init(deltaX: 15, deltaY: 5))

          button.layer.cornerRadius = cornerRadius
          button.titleLabel?.numberOfLines = 2
          button.addShadow(shadow)
          button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 60)

        }
        
        static func container(_ view: UIView) {
          view.backgroundColor = Palette.white
          view.layer.cornerRadius = SharedStyle.cardCornerRadius
          view.addShadow(.cardLightBlue)
        }

        static func background(_ view: UIView) {
            view.backgroundColor = Palette.grayWhite
        }

        static func backgroundGradient(_ gradientView: GradientView) {
            gradientView.isUserInteractionEnabled = false
            gradientView.gradient = Palette.gradientBackgroundBlueOnBottom
        }

        static func scrollView(_ scrollView: UIScrollView) {
            scrollView.backgroundColor = .clear
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            scrollView.showsVerticalScrollIndicator = false
        }

        static func title(_ label: UILabel, text: String) {
            TempuraStyles.styleShrinkableLabel(
                label,
                content: text,
                style: TextStyles.navbarSmallTitle.byAdding(
                    .color(Palette.grayDark),
                    .alignment(.center)
                ),
                numberOfLines: 1
            )
        }
        static func inactiveLabel(_ label: UILabel, text: String) {
            TempuraStyles.styleStandardLabel(
                label,
                content: text,
                style: TextStyles.p.byAdding(
                    .color(Palette.grayNormal),
                    .alignment(.center)
                ),
                numberOfLines: 1
            )
        }
        
        static func stateLabel(_ label: UILabel, text: String, color: UIColor) {
            
            let textStyle = TextStyles.pSemibold.byAdding(
                .color(color),
                .alignment(.center)
            )

            TempuraStyles.styleStandardLabel(
                label,
                content: text,
                style: textStyle
            )
        }
        
        static func imageContent(_ imageView: UIImageView, image: UIImage) {
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
        }
    }
}
enum CardView {
    case qr
    case data
}
