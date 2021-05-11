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
    
    enum Tab: Int {
      case active
      case expired

      var title: String {
        switch self {
        case .active:
          return "Attivo"
        case .expired:
          return "Scaduti"
        }
      }
    
    }
    /// The tabbar cells.
    let tabs: [Tab]
    /// The currently selected tab.
    var selectedTab: Tab

    var cellModels: [TabCellVM] {
      return self.tabs.map { tab in
        TabCellVM(tab: tab, isSelected: tab == self.selectedTab)
      }
    }

    func needToReloadIndexPath(oldModel: GreenCertificateVM?) -> [IndexPath] {
      guard let oldModel = oldModel,
            oldModel.selectedTab != self.selectedTab
      else {
        return []
      }

      return [
        self.tabs.firstIndex(of: oldModel.selectedTab).map { IndexPath(row: $0, section: 0) },
        self.tabs.firstIndex(of: self.selectedTab).map { IndexPath(row: $0, section: 0) }
      ]
      .compactMap { $0 }
    }

    func shouldReloadWholeTabbar(oldModel: GreenCertificateVM?) -> Bool {
      guard let oldModel = oldModel else {
        return true
      }

      return self.tabs != oldModel.tabs
    }
}

extension GreenCertificateVM {
    init?(state _: AppState?, localState: GreenCertificateLS) {
        isLoading = localState.isLoading
        self.tabs = [.active, .expired]
        self.selectedTab = .active
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
    private let tempTitle = UILabel()
    
    

    private var backButton = ImageButton()
    let scrollView = UIScrollView()
    private let headerView = GreenCertificateHeaderView()

    private let containerQr = UIView()
    
    private var showQr = true

    private var qrCode = UIImageView()
    let borderQrCode = UIView()
    let borderImageView = UIView()
    private var actionButton = ButtonWithInsets()
    
    var lineView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1.0))
    
    private lazy var collection: UICollectionView = {
      let layout = UICollectionViewFlowLayout()

      layout.scrollDirection = .horizontal

      layout.minimumInteritemSpacing = 0
      layout.minimumLineSpacing = 0

      let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
      collection.delegate = self
      collection.dataSource = self

      collection.register(TabCell.self, forCellWithReuseIdentifier: TabCell.identifierForReuse)
      return collection
    }()
    
    var didSelectCell: ((GreenCertificateVM.Tab) -> Void)?

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

        containerQr.addSubview(lineView)
        containerQr.addSubview(collection)
        containerQr.addSubview(borderImageView)
        borderImageView.addSubview(borderQrCode)
        borderQrCode.addSubview(qrCode)
//        containerQr.addSubview(qrCode)
//        containerQr.addSubview()
//        containerQr.addSubview()
//        containerQr.addSubview()
//        containerQr.addSubview()
//        containerQr.addSubview()
//        containerQr.addSubview()

        addSubview(actionButton)
        addSubview(backgroundGradientView)
        addSubview(scrollView)
        addSubview(title)
        addSubview(tempTitle)
        addSubview(backButton)
        scrollView.addSubview(actionButton)
        scrollView.addSubview(headerView)

        scrollView.addSubview(containerQr)
        
        self.collection.accessibilityTraits = .tabBar

        backButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapBack?()
           }
        actionButton.on(.touchUpInside) { [weak self] _ in
//            self?.didTapVerifyCode?(self?.pickerFieldSymptomsDate.model?.isEnabled)
           }
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
        Self.Style.title(title, text: "Green certificato")
        Self.Style.title(tempTitle, text: "Storico")
        Self.Style.container(containerQr)
        Self.Style.containerBorder(borderQrCode, color: Palette.white, radius: 10)
        Self.Style.containerBorder(borderImageView, color: Palette.purple, radius: 25)
        Self.Style.collection(self.collection)

        
        lineView.layer.borderWidth = 1.0
        lineView.layer.borderColor = Palette.grayExtraWhite.cgColor
        
        let r = self.generateQRCode(from: "NCFOXN%TSMAHN-H5L486Q-LCBYUN+CWI47-5Y8EN6QBL53+LZEB$ZJ*DJH75*84T*K.UKO KKFRV4C%47DK4V:6S16S45B.3A9J.6ANEBWD1UCIC2K%4HCW4C 1A CWHC2.9G58QWGNO37QQG UZ$UBZP/BEMWIIOH%HMI*5O0I172Y5SX5Q.+HU1CQKQD1UACR96IDESM-FLX6WDDGAQZ1AUMJHE0ZKNL-K31J/7I*2VUWUE08NA9T141 LXRL QE4OB$DVX A/DSU0AM361309JLU1")
               
        Self.Style.imageContent(qrCode, image: r!)
        Self.Style.generateButton(actionButton, title: "Genera certificato", icon: UIImage(systemName: "qrcode.viewfinder"))
        SharedStyle.navigationBackButton(backButton)
//        SharedStyle.primaryButton(actionButtonAutonomous, title: L10n.UploadData.Verify.button)
//        SharedStyle.primaryButton(actionButtonCallCenter, title: L10n.UploadData.Verify.button)
    }

    // MARK: - Update

    func update(oldModel: VM?) {
        guard let model = self.model else {
            return
        }
        if model.shouldReloadWholeTabbar(oldModel: oldModel) {
          self.collection.reloadData()
        }
        
        showQr = model.selectedTab == .active
        if showQr {
            addSubview(borderImageView)
            tempTitle.removeFromSuperview()
        }
        else {
            addSubview(tempTitle)
            borderImageView.removeFromSuperview()
            
        }
        
        
        for indexPath in model.needToReloadIndexPath(oldModel: oldModel) {
          let tabCell = self.collection.cellForItem(at: indexPath) as? TabCell
          tabCell?.model = self.model?.cellModels[indexPath.row]
        }
        setNeedsDisplay()
        setNeedsLayout()
        
//        layoutIfNeeded()

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
        
        actionButton.pin
            .horizontally(45)
            .sizeToFit(.width)
            .minHeight(25)
            .below(of: headerView)
            .marginTop(20)
        
        containerQr.pin
          .below(of: actionButton)
          .marginTop(30)
          .horizontally(25)
          .height(420)
        
        collection.pin
          .marginTop(55)
          .below(of: actionButton)
            .width(self.bounds.width/1.2)
          .hCenter()
          .height(Self.tabBarHeight)
        
        lineView.pin
          .below(of: headerView)
          .marginTop(160)
          .hCenter()
          .width(containerQr.frame.width)
          .height(1)
        
        if showQr {
        borderImageView.pin
          .below(of: headerView)
          .marginTop(220)
          .hCenter()
          .width(260)
          .height(260)

        
        borderQrCode.pin
          .below(of: headerView)
          .marginTop(240)
          .hCenter()
          .width(220)
          .height(220)
        
        qrCode.pin
          .below(of: headerView)
          .marginTop(250)
          .hCenter()
          .width(200)
          .height(200)
        }
        else {
            tempTitle.pin
              .below(of: headerView)
              .marginTop(220)
              .horizontally(Self.horizontalSpacing + backButton.intrinsicContentSize.width + 5)
              .sizeToFit(.width)
        }
    
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: containerQr.frame.maxY)
    }
}

// MARK: - Style

private extension GreenCertificateView {
    enum Style {
        
        static func collection(_ collectionView: UICollectionView) {
          collectionView.backgroundColor = .clear
          collectionView.isScrollEnabled = false
          collectionView.bounces = false
          guard let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
          }
          collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
          collectionViewLayout.minimumLineSpacing = 0
        }
        
        static func generateButton(
          _ button: ButtonWithInsets,
          title: String?,
          icon: UIImage? = nil,
          spacing: CGFloat = 15,
          tintColor: UIColor = Palette.white,
          backgroundColor: UIColor = Palette.primary,
          insets: UIEdgeInsets = .primaryButtonInsets,
          cornerRadius: CGFloat = 28,
          shadow: UIView.Shadow = .cardPrimary
        ) {
          let textStyle = TextStyles.pSemibold.byAdding([
            .color(tintColor),
            .alignment(.center)
          ])

          button.setBackgroundColor(backgroundColor, for: .normal)
          button.setAttributedTitle(title?.styled(with: textStyle), for: .normal)
          button.setImage(icon, for: .normal)
          button.tintColor = tintColor
          button.insets = insets
          button.layer.cornerRadius = cornerRadius
          button.titleLabel?.numberOfLines = 0
          button.addShadow(shadow)

          if title != nil && icon != nil {
//            button.titleEdgeInsets = .init(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
            button.imageEdgeInsets = .init(top: 0, left: -60, bottom: 0, right: 60)
          } else {
            button.titleEdgeInsets = insets
          }
        }
        
        static func container(_ view: UIView) {
          view.backgroundColor = Palette.white
          view.layer.cornerRadius = SharedStyle.cardCornerRadius
          view.addShadow(.cardLightBlue)
        }
        
        static func containerBorder(_ view: UIView, color: UIColor, radius: CGFloat) {
          view.backgroundColor = color
          view.layer.cornerRadius = radius
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

// MARK: - UICollectionViewDelegateFlowLayout

extension GreenCertificateView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let tab = self.model?.tabs[indexPath.row] else {
      return
    }

    self.didSelectCell?(tab)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    guard let model = self.model else { return .zero }

    // compute the width of a single cell
    let singleWidth: CGFloat = collectionView.bounds.width / CGFloat(model.tabs.count)
    return CGSize(width: singleWidth, height: TabbarView.tabBarHeight)
  }
}

extension GreenCertificateView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.model?.tabs.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabCell.identifierForReuse, for: indexPath)

    guard let typedCell = cell as? TabCell else {
      AppLogger.fatalError("cell must conform to TabbarCell")
    }

    typedCell.model = self.model?.cellModels[indexPath.row]
    return typedCell
  }
}
