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

    var greenCertificate: String?

    enum StatusGreenCertificate: Int {
      case active
      case inactive

      var title: String {
        switch self {
        case .active:
          return "Attivo"
        case .inactive:
          return "Non Attivo"
        }
      }
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
    
    private var backButton = ImageButton()
    let scrollView = UIScrollView()
    private let headerView = GreenCertificateHeaderView()

    private let container = UIView()
    
    private var showQr = true

    private var qrCode = UIImageView()
    private var actionButton = ButtonWithInsets()
    private var stateLabel = UILabel()

    var lineView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1.0))
    
    var didTapBack: Interaction?

    var didTapDiscoverMore: Interaction?
    var didTapGenerate: Interaction?


    // MARK: - Setup

    func setup() {
        addSubview(container)

        container.addSubview(lineView)
        container.addSubview(stateLabel)
        container.addSubview(qrCode)

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
            self?.didTapGenerate?()
           }

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
        Self.Style.title(title, text: "Green certificato")
        Self.Style.inactiveLabel(inactiveLabel, text: "Nessun certificato attivo")
        Self.Style.container(container)
        
        lineView.layer.borderWidth = 1.0
        lineView.layer.borderColor = Palette.grayExtraWhite.cgColor
        
        Self.Style.actionButton(actionButton, icon: UIImage(systemName: "qrcode.viewfinder"))
        
        SharedStyle.navigationBackButton(backButton)
    }

    // MARK: - Update

    func update(oldModel: VM?) {
        guard let model = self.model else {
            return
        }

        if let greenCertificate = model.greenCertificate {
          let qr = self.generateQRCode(from: greenCertificate)
          Self.Style.imageContent(qrCode, image: qr!)
          addSubview(qrCode)
          scrollView.addSubview(qrCode)
          inactiveLabel.removeFromSuperview()
          Self.Style.stateLabel(stateLabel,text: "Attivo", color: Palette.purple)
        }
        else{
          addSubview(inactiveLabel)
          scrollView.addSubview(inactiveLabel)
          qrCode.removeFromSuperview()
          Self.Style.stateLabel(stateLabel,text: "Non attivo", color: Palette.grayPurple)
        }
        
//        showQr = model.status == .active
//        if showQr {
//            addSubview(qrCode)
//            scrollView.addSubview(qrCode)
//            inactiveLabel.removeFromSuperview()
//        }
//        else {
//            addSubview(inactiveLabel)
//            scrollView.addSubview(inactiveLabel)
//            qrCode.removeFromSuperview()
//        }
        Self.Style.stateLabel(stateLabel,text: model.status == .active ? "Attivo" : "Non attivo", color: model.status == .active ? Palette.purple : Palette.grayPurple)
        
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
          .height(430)
        
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
        
        if showQr {
        
        qrCode.pin
          .below(of: headerView)
          .marginTop(100)
          .hCenter()
          .width(container.frame.width*0.9)
          .height(container.frame.width*0.9)
        }
        else {
            inactiveLabel.pin
              .below(of: headerView)
              .marginTop(220)
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
}

// MARK: - Style

private extension GreenCertificateView {
    enum Style {
        
        static func actionButton(
          _ button: ButtonWithInsets,
          icon: UIImage? = nil,
          tintColor: UIColor = Palette.white,
          backgroundColor: UIColor = Palette.primary,
          cornerRadius: CGFloat = 28,
          shadow: UIView.Shadow = .cardPrimary
        ) {
          
          let text = "Recupera Digital Green\nCertificate"
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
          button.imageEdgeInsets = .init(top: 0, left: -70, bottom: 0, right: 0)

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
            TempuraStyles.styleShrinkableLabel(
                label,
                content: text,
                style: TextStyles.pSemibold.byAdding(
                    .color(Palette.grayDark),
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
            
//            imageView.layer.masksToBounds = false
//            imageView.layer.borderWidth = 20
//            imageView.layer.borderColor = Palette.purple.cgColor
//            imageView.layer.cornerRadius = imageView.bounds.width / 2
        }
    }
}
