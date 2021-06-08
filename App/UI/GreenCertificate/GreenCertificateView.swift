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
    
    var currentDgc: Int = 0
    var greenCertificates: [GreenCertificate]?

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
        self.greenCertificates = state?.user.greenCertificates
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

    let scrollView = UIScrollView()

    private let container = UIView()
    
    private var qrCode = UIImageView()
    private var actionButton = ButtonWithInsets()
    private var deleteButton = ButtonWithInsets()
    private var saveButton = ButtonWithInsets()
    private var swipeLabel = UILabel()
    
    private var nameLabel = UILabel()
    private var nameLabelEn = UILabel()
    private var name = UILabel()
    
    private var birthLabel = UILabel()
    private var birthLabelEn = UILabel()
    private var birth = UILabel()
    
    private var idLabel = UILabel()
    private var idLabelEn = UILabel()
    private var id = UILabel()
    private var discoverMore = TextButton()


    var lineView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1.0))
    
    var didTapBack: Interaction?

    var didTapDiscoverMore: CustomInteraction<GreenCertificate>?
    var didTapRetriveGreenCertificate: Interaction?
    var didTapDeleteGreenCertificate: CustomInteraction<Int>?
    var didTapSaveGreenCertificate: CustomInteraction<Int>?


    // MARK: - Setup

    func setup() {
        addSubview(container)

        container.addSubview(lineView)
        container.addSubview(qrCode)
        container.addSubview(deleteButton)

        addSubview(actionButton)
        addSubview(backgroundGradientView)
        addSubview(scrollView)
        addSubview(title)
        addSubview(backButton)
        scrollView.addSubview(actionButton)

        scrollView.addSubview(container)

        backButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapBack?()
           }
        actionButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapRetriveGreenCertificate?()
           }
        deleteButton.on(.touchUpInside) { [weak self] _ in
            if let index = self?.model?.currentDgc {
                self?.didTapDeleteGreenCertificate?(index)
            }
           }
        saveButton.on(.touchUpInside) { [weak self] _ in
            if let index = self?.model?.currentDgc {
                self?.didTapSaveGreenCertificate?(index)
            }

        }
        discoverMore.on(.touchUpInside) { [weak self] _ in
            guard let index = self?.model?.currentDgc, let dgc = self?.model?.greenCertificates?[index] else { return }
            self?.didTapDiscoverMore?(dgc)
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
            if let currentDgc = model?.currentDgc, let length = model?.greenCertificates?.count,
               currentDgc < (length-1){
                model?.currentDgc += 1
            }
            frame.origin.x -= 100.0
          case .right:
            if let currentDgc = model?.currentDgc, currentDgc > 0 {
                model?.currentDgc -= 1
            }
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
    
    func style() {
        Self.Style.discoverMore(discoverMore)
        Self.Style.swipeLabel(swipeLabel,text: L10n.HomeView.GreenCertificate.swipeLabel)
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
          icon: Asset.Home.deleteQr.image,
          spacing: 8,
          tintColor: Palette.purple,
          backgroundColor: UIColor.clear,
          insets: UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 20),
          cornerRadius: 21,
          shadow: .grayDark
        )
        SharedStyle.primaryButton(
          saveButton,
          title: L10n.HomeView.GreenCertificate.saveButton,
          icon: Asset.Home.saveQr.image,
          spacing: 8,
          tintColor: Palette.purple,
          backgroundColor: UIColor.clear,
          insets: UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 20),
          cornerRadius: 21,
          shadow: .grayDark
        )
        
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
        if let greenCertificates = model.greenCertificates, greenCertificates.count > 0, model.currentDgc < greenCertificates.count, model.currentDgc >= 0 {
            
            let dataDecoded: Data? = Data(base64Encoded: greenCertificates[model.currentDgc].greenCertificate, options: .ignoreUnknownCharacters)
          if let dataDecoded = dataDecoded, let decodedimage = UIImage(data: dataDecoded) {
            Self.Style.imageContent(qrCode, image: decodedimage)
          }
            if let oldModel = oldModel, oldModel.currentDgc != model.currentDgc {
                let transition = CATransition()
                transition.type = CATransitionType.push
                transition.subtype = (oldModel.currentDgc < model.currentDgc) ? CATransitionSubtype.fromRight : CATransitionSubtype.fromLeft
                container.layer.add(transition, forKey: nil)
                qrCode.layer.add(transition, forKey: nil)
                deleteButton.layer.add(transition, forKey: nil)
                nameLabel.layer.add(transition, forKey: nil)
                nameLabelEn.layer.add(transition, forKey: nil)
                name.layer.add(transition, forKey: nil)
                birthLabel.layer.add(transition, forKey: nil)
                birthLabelEn.layer.add(transition, forKey: nil)
                birth.layer.add(transition, forKey: nil)
                idLabel.layer.add(transition, forKey: nil)
                idLabelEn.layer.add(transition, forKey: nil)
                id.layer.add(transition, forKey: nil)
                discoverMore.layer.add(transition, forKey: nil)
                lineView.layer.add(transition, forKey: nil)
                swipeLabel.layer.add(transition, forKey: nil)

            }
      
            if greenCertificates.count > 1 {
                addSubview(swipeLabel)
                scrollView.addSubview(swipeLabel)
            }
            else {
                swipeLabel.removeFromSuperview()
            }
            addSubview(qrCode)
            addSubview(deleteButton)
            addSubview(nameLabel)
            addSubview(nameLabelEn)
            addSubview(name)
            addSubview(birthLabel)
            addSubview(birthLabelEn)
            addSubview(birth)
            addSubview(idLabelEn)
            addSubview(idLabel)
            addSubview(id)
            addSubview(discoverMore)
            addSubview(lineView)

            scrollView.addSubview(lineView)
            scrollView.addSubview(discoverMore)
            scrollView.addSubview(qrCode)
            scrollView.addSubview(deleteButton)
            scrollView.addSubview(nameLabel)
            scrollView.addSubview(nameLabelEn)
            scrollView.addSubview(name)
            scrollView.addSubview(birthLabel)
            scrollView.addSubview(birthLabelEn)
            scrollView.addSubview(birth)
            scrollView.addSubview(idLabel)
            scrollView.addSubview(idLabelEn)
            scrollView.addSubview(id)
            Self.Style.value(name, text: greenCertificates[model.currentDgc].name)
            Self.Style.value(birth, text: greenCertificates[model.currentDgc].birth)
            Self.Style.value(id, text: greenCertificates[model.currentDgc].id)
            Self.Style.label(nameLabel,text: L10n.HomeView.GreenCertificate.Label.name)
            Self.Style.label(birthLabel,text: L10n.HomeView.GreenCertificate.Label.date)
            Self.Style.label(idLabel,text: L10n.HomeView.GreenCertificate.Label.id)
            Self.Style.label(nameLabelEn,text: L10n.HomeView.GreenCertificate.Label.nameEn)
            Self.Style.label(birthLabelEn,text: L10n.HomeView.GreenCertificate.Label.dateEn)
            Self.Style.label(idLabelEn,text: L10n.HomeView.GreenCertificate.Label.idEn)
          
          inactiveLabel.removeFromSuperview()
          inactiveImage.removeFromSuperview()
        }
        else{
          container.addSubview(inactiveLabel)
          scrollView.addSubview(inactiveLabel)
          container.addSubview(inactiveImage)
          scrollView.addSubview(inactiveImage)
          qrCode.removeFromSuperview()
          swipeLabel.removeFromSuperview()
          deleteButton.removeFromSuperview()
          nameLabel.removeFromSuperview()
          nameLabelEn.removeFromSuperview()
          name.removeFromSuperview()
          birthLabel.removeFromSuperview()
          birthLabelEn.removeFromSuperview()
          birth.removeFromSuperview()
          idLabel.removeFromSuperview()
          idLabelEn.removeFromSuperview()
          id.removeFromSuperview()
          lineView.removeFromSuperview()
          discoverMore.removeFromSuperview()

          
        }
        
        setNeedsLayout()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        
        var dgcIsPresent = false
        if let greenCertificates = model?.greenCertificates, greenCertificates.count > 0 {
            dgcIsPresent = true
        }

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

        container.pin
          .top(20)
          .horizontally(25)
          .height(dgcIsPresent ? UIDevice.getByScreen(normal: 840, short: 800) : UIDevice.getByScreen(normal: 400, short: 380))
        
        if dgcIsPresent {
        
            qrCode.pin
              .below(of: title)
              .marginTop(60)
              .hCenter()
              .width(container.frame.width*0.94)
              .height(container.frame.width*0.94)
            
            swipeLabel.pin
              .minHeight(25)
              .below(of: qrCode)
              .marginTop(10)
              .sizeToFit(.width)
              .horizontally(25)
        
            nameLabelEn.pin
              .minHeight(25)
              .below(of: qrCode)
              .marginTop(55)
              .sizeToFit(.width)
              .horizontally(25)
              .marginLeft(10)
            
            nameLabel.pin
              .minHeight(25)
              .below(of: nameLabelEn)
              .sizeToFit(.width)
              .horizontally(25)
              .marginLeft(10)
            
            name.pin
              .minHeight(25)
              .below(of: nameLabel)
              .marginTop(5)
              .sizeToFit(.width)
              .horizontally(25)
              .marginLeft(10)
            
            birthLabelEn.pin
              .minHeight(25)
              .below(of: name)
              .marginTop(15)
              .sizeToFit(.width)
              .horizontally(25)
              .marginLeft(10)
            
            birthLabel.pin
              .minHeight(25)
              .below(of: birthLabelEn)
              .sizeToFit(.width)
              .horizontally(25)
              .marginLeft(10)

            birth.pin
              .minHeight(25)
              .below(of: birthLabel)
              .marginTop(5)
              .sizeToFit(.width)
              .horizontally(25)
              .marginLeft(10)

            idLabelEn.pin
              .minHeight(25)
              .below(of: birth)
              .marginTop(15)
              .sizeToFit(.width)
              .horizontally(25)
              .marginLeft(10)
            
            idLabel.pin
              .minHeight(25)
              .below(of: idLabelEn)
              .sizeToFit(.width)
              .horizontally(25)
              .marginLeft(10)

            id.pin
              .minHeight(25)
              .below(of: idLabel)
              .marginTop(5)
              .sizeToFit(.width)
              .horizontally(25)
              .marginLeft(10)
            
            discoverMore.pin
                .below(of: id)
                .marginTop(10)
                .horizontally(30)
                .sizeToFit(.width)
            
            lineView.pin
                .below(of: discoverMore)
                .marginTop(10)
                .hCenter()
                .width(container.frame.width)
                .height(1)

            deleteButton.pin
              .hCenter()
              .size(self.buttonSize(for: self.bounds.width))
              .minHeight(25)
              .below(of: lineView)
              .marginTop(5)
        
        }
        else {
            inactiveImage.pin
              .below(of: title)
              .marginTop(100)
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
      let labelWidth = width - 2 * HomeView.cellHorizontalInset - 35
        - self.deleteButton.insets.horizontal - self.deleteButton.titleEdgeInsets.horizontal
      var buttonSize = self.deleteButton.titleLabel?.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity)) ?? .zero
      buttonSize.width += 45 + HomeDeactivateServiceCell.iconToTitle + self.deleteButton.insets.horizontal
      buttonSize.height = max(buttonSize.height, 30) + self.deleteButton.insets.vertical

      return buttonSize
    }
}

// MARK: - Style

private extension GreenCertificateView {
    enum Style {
        
        static func discoverMore(_ button: TextButton) {
            let textStyle = TextStyles.pBold.byAdding(
                .color(Palette.primary),
                .alignment(.center)
            )
            button.contentHorizontalAlignment = .center
            button.contentVerticalAlignment = .bottom
            button.attributedTitle = L10n.HomeView.GreenCertificate.discoverMore.styled(with: textStyle)
        }
        
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
                numberOfLines: 2
            )
        }
        static func inactiveLabel(_ label: UILabel, text: String) {
            TempuraStyles.styleStandardLabel(
                label,
                content: text,
                style: TextStyles.p.byAdding(
                    .color(Palette.grayNormal),
                    .alignment(.center)
                )
            )
        }
        
        static func swipeLabel(_ label: UILabel, text: String) {
            let textStyle = TextStyles.s.byAdding(
                .color(Palette.grayNormal),
                .alignment(.center)
            )
            TempuraStyles.styleStandardLabel(
                label,
                content: text,
                style: textStyle
            )
        }
        static func label(_ label: UILabel, text: String) {
            let textStyle = TextStyles.p.byAdding(
                .color(Palette.grayNormal),
                .alignment(.left),
                .xmlRules([
                    .style("i", TextStyles.i)
                ])
            )
            TempuraStyles.styleStandardLabel(
                label,
                content: text,
                style: textStyle,
                numberOfLines: 2
            )
        }
        
        static func value(_ label: UILabel, text: String) {
            let textStyle = TextStyles.pSemibold.byAdding(
                .color(Palette.grayDark),
                .alignment(.left)
            )
            TempuraStyles.styleStandardLabel(
                label,
                content: text,
                style: textStyle,
                numberOfLines: 2
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
extension UIImage {

    func addImagePadding(x: CGFloat, y: CGFloat) -> UIImage? {
        let width: CGFloat = size.width + x
        let height: CGFloat = size.height + y
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        let origin: CGPoint = CGPoint(x: (width - size.width) / 2, y: (height - size.height) / 2)
        draw(at: origin)
        let imageWithPadding = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return imageWithPadding
    }
}
