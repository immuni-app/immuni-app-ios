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
    var textFieldCunVM: TextFieldCunVM { TextFieldCunVM() }
    var textFieldHealthCardVM: TextFieldHealthCardVM { TextFieldHealthCardVM() }
    var pickerFieldSymptomsDateVM: PickerSymptomsDateVM = PickerSymptomsDateVM(isEnabled: true)
    var asymptomaticCheckBoxVM: AsymptomaticCheckBoxVM = AsymptomaticCheckBoxVM(isSelected: false, isEnabled: true)

    /// True if it's not possible to execute a new request.
    let isLoading: Bool
}

extension GreenCertificateVM {
    init?(state _: AppState?, localState: GreenCertificateLS) {
        isLoading = localState.isLoading
        self.asymptomaticCheckBoxVM.isSelected = localState.asymptomaticCheckBoxIsChecked
        self.pickerFieldSymptomsDateVM.isEnabled = localState.symptomsDateIsEnabled
    }
}

// MARK: - View

class GreenCertificateView: UIView, ViewControllerModellableView {
    typealias VM = GreenCertificateVM

    private static let horizontalSpacing: CGFloat = 30.0
    static let orderLeftMargin: CGFloat = UIDevice.getByScreen(normal: 70, narrow: 50)

    private let backgroundGradientView = GradientView()
    private let title = UILabel()

    private var backButton = ImageButton()
    let scrollView = UIScrollView()
    private let headerView = GreenCertificateHeaderView()

    private let containerQr = UIView()
    
    private var qrCode = UIImageView()
    let borderQrCode = UIView()


//    private var actionButtonAutonomous = ButtonWithInsets()

    var didTapBack: Interaction?
//    var didTapVerifyCode: CustomInteraction<Bool?>?
//    var didTapHealthWorkerMode: Interaction?
    var didTapDiscoverMore: Interaction?

//    var didChangeCunTextValue: CustomInteraction<String>?
//    var didChangeHealthCardTextValue: CustomInteraction<String>?
//    var didChangeSymptomsDateValue: CustomInteraction<String>?
//    var didChangeCheckBoxValue: CustomInteraction<Bool?>?

    // MARK: - Setup

    func setup() {
        addSubview(containerQr)

        containerQr.addSubview(borderQrCode)
        borderQrCode.addSubview(qrCode)
//        containerQr.addSubview(qrCode)
//        containerQr.addSubview()
//        containerQr.addSubview()
//        containerQr.addSubview()
//        containerQr.addSubview()
//        containerQr.addSubview()
//        containerQr.addSubview()


        addSubview(backgroundGradientView)
        addSubview(scrollView)
        addSubview(title)
        addSubview(backButton)
        scrollView.addSubview(headerView)

        scrollView.addSubview(containerQr)

        backButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapBack?()
           }
//        actionButtonAutonomous.on(.touchUpInside) { [weak self] _ in
//            self?.didTapVerifyCode?(self?.pickerFieldSymptomsDate.model?.isEnabled)
//           }
//        actionButtonCallCenter.on(.touchUpInside) { [weak self] _ in
//            self?.didTapHealthWorkerMode?()
//           }
        headerView.didTapDiscoverMore = { [weak self] in
            self?.didTapDiscoverMore?()
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
        Self.Style.title(title)
        Self.Style.container(containerQr)
        Self.Style.containerBorder(borderQrCode)

        
        let r = self.generateQRCode(from: "NCFOXN%TSMAHN-H5L486Q-LCBYUN+CWI47-5Y8EN6QBL53+LZEB$ZJ*DJH75*84T*K.UKO KKFRV4C%47DK4V:6S16S45B.3A9J.6ANEBWD1UCIC2K%4HCW4C 1A CWHC2.9G58QWGNO37QQG UZ$UBZP/BEMWIIOH%HMI*5O0I172Y5SX5Q.+HU1CQKQD1UACR96IDESM-FLX6WDDGAQZ1AUMJHE0ZKNL-K31J/7I*2VUWUE08NA9T141 LXRL QE4OB$DVX A/DSU0AM361309JLU1")
               
        Self.Style.imageContent(qrCode, image: r!)
       
        SharedStyle.navigationBackButton(backButton)
//        SharedStyle.primaryButton(actionButtonAutonomous, title: L10n.UploadData.Verify.button)
//        SharedStyle.primaryButton(actionButtonCallCenter, title: L10n.UploadData.Verify.button)
    }

    // MARK: - Update

    func update(oldModel _: VM?) {
        guard let model = self.model else {
            return
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
        
        containerQr.pin
          .below(of: headerView)
          .marginTop(25)
          .horizontally(25)
          .height(420)
        
        borderQrCode.pin
          .below(of: headerView)
          .marginTop(140)
          .hCenter()
          .width(260)
          .height(260)
        
        qrCode.pin
          .below(of: headerView)
          .marginTop(170)
          .hCenter()
          .width(200)
          .height(200)
    
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: containerQr.frame.maxY)
    }
}

// MARK: - Style

private extension GreenCertificateView {
    enum Style {
        
        static func container(_ view: UIView) {
          view.backgroundColor = Palette.white
          view.layer.cornerRadius = SharedStyle.cardCornerRadius
          view.addShadow(.cardLightBlue)
        }
        
        static func containerBorder(_ view: UIView) {
          view.backgroundColor = Palette.purple
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

        static func title(_ label: UILabel) {
            let content = "Green Certificate"
            TempuraStyles.styleShrinkableLabel(
                label,
                content: content,
                style: TextStyles.navbarSmallTitle.byAdding(
                    .color(Palette.grayDark),
                    .alignment(.center)
                ),
                numberOfLines: 1
            )
        }
        static func iconAutonomous(_ view: UIImageView) {
            view.image = Asset.Settings.UploadData.smartPhone.image
            view.contentMode = .scaleAspectFit
        }
        static func iconCallCenter(_ view: UIImageView) {
            view.image = Asset.Settings.UploadData.callCenter.image
            view.contentMode = .scaleAspectFit
        }
        
        static func titleAutonomous(_ label: UILabel) {
            let content = L10n.Settings.Setting.LoadDataAutonomousFormCard.title
            
            let textStyle = TextStyles.pBold.byAdding(
                .color(Palette.purple),
                .alignment(.left)
            )

            TempuraStyles.styleStandardLabel(
                label,
                content: content,
                style: textStyle
            )
        }
        static func titleCallCenter(_ label: UILabel) {
            let content = L10n.Settings.Setting.LoadDataAutonomousCallCenter.title
            let textStyle = TextStyles.pBold.byAdding(
                .color(Palette.purple),
                .alignment(.left)
            )

            TempuraStyles.styleStandardLabel(
                label,
                content: content,
                style: textStyle
            )
        }

        static func choice(_ label: UILabel) {
            let content = L10n.Settings.Setting.LoadDataAutonomous.choice

            let textStyle = TextStyles.p.byAdding(
                .color(Palette.grayNormal),
                .alignment(.center)
            )

            TempuraStyles.styleStandardLabel(
                label,
                content: content,
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
