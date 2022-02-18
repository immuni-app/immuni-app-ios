// SuggestionsInstructionCell.swift
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

import BonMot
import Extensions
import Foundation
import Tempura

struct SuggestionsInstructionCellVM: ViewModel {
  enum Instruction {
    case ministerialDecree
    case washHands
    case useNapkins
    case socialDistance
    case wearMask
    case contactDoctor
    case stayHome
    case limitMovements
    case distance
    case checkSymptoms
    case isolate
    case contactAuthorities
  }

  let instruction: Instruction
    
  var url: String? {
    switch self.instruction {
      case .stayHome:
        return L10n.Suggestions.Instruction.StayHome.url
      case .ministerialDecree, .washHands, .useNapkins, .socialDistance, .wearMask, .contactDoctor,
            .limitMovements, .distance, .checkSymptoms, .isolate, .contactAuthorities:
        return nil
      }
    }

  var title: String {
    switch self.instruction {
    case .ministerialDecree:
      return L10n.Suggestions.Instruction.ministerialDecree
    case .washHands:
      return L10n.Suggestions.Instruction.washHands
    case .useNapkins:
      return L10n.Suggestions.Instruction.useNapkins
    case .socialDistance:
      return L10n.Suggestions.Instruction.socialDistance
    case .wearMask:
      return L10n.Suggestions.Instruction.Mask.title
    case .contactDoctor:
      return L10n.Suggestions.Instruction.ContactDoctor.title
    case .stayHome:
      return L10n.Suggestions.Instruction.StayHome.title
    case .checkSymptoms:
      return L10n.Suggestions.Instruction.CheckSymptoms.title
    case .isolate:
      return L10n.Suggestions.Instruction.Isolate.title
    case .contactAuthorities:
      return L10n.Suggestions.Instruction.phoneContact
    case .distance:
      return L10n.Suggestions.Instruction.distance
    case .limitMovements:
      return L10n.Suggestions.Instruction.limitMovement
    }
  }

  var icon: UIImage {
    switch self.instruction {
    case .ministerialDecree:
      return Asset.Suggestions.ministry.image
    case .washHands:
      return Asset.Suggestions.washHands.image
    case .useNapkins:
      return Asset.Suggestions.useNapkins.image
    case .socialDistance:
      return Asset.Suggestions.socialDistance.image
    case .wearMask:
      return Asset.Suggestions.mask.image
    case .contactDoctor:
      return Asset.Suggestions.contactDoctor.image
    case .stayHome:
      return Asset.Suggestions.home.image
    case .checkSymptoms:
      return Asset.Suggestions.checkSymptoms.image
    case .isolate:
      return Asset.Suggestions.isolate.image
    case .contactAuthorities:
      return Asset.Suggestions.emergency.image
    case .distance:
      return Asset.Suggestions.socialDistance.image
    case .limitMovements:
      return Asset.Suggestions.limitMovements.image
    }
  }

  var subtitle: String? {
    switch self.instruction {
    case .ministerialDecree, .washHands, .useNapkins, .socialDistance, .contactAuthorities, .distance,
            .limitMovements, .stayHome:
      return nil
    case .checkSymptoms:
      return L10n.Suggestions.Instruction.CheckSymptoms.message
    case .isolate:
      return L10n.Suggestions.Instruction.Isolate.message
    case .contactDoctor:
      return L10n.Suggestions.Instruction.ContactDoctor.message
    case .wearMask:
      return L10n.Suggestions.Instruction.Mask.message
    }
  }

  var hasSubtitle: Bool {
    return self.subtitle != nil
  }
}

class SuggestionsInstructionCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = SuggestionsInstructionCellVM

  private static let imageSize: CGFloat = 40
  private static let contentInset: CGFloat = 20
  private static let imageToMessage: CGFloat = 15
  private static let titleToSubtitle: CGFloat = 15
  private static let totalHorizontalMargin: CGFloat =
    2 * SuggestionsView.cellContainerInset + SuggestionsInstructionCell.imageSize +
    SuggestionsInstructionCell.imageToMessage + 2 * SuggestionsInstructionCell.contentInset

  let container = UIView()
  let message = UITextView()
  let subtitle = UILabel()
  let icon = UIImageView()
    
  var didTapDiscoverMoreStayHome: Interaction?

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
    self.style()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
    self.style()
  }

  func setup() {
    self.contentView.addSubview(self.container)
    self.container.addSubview(self.message)
    self.container.addSubview(self.icon)
    self.container.addSubview(self.subtitle)
      
    let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
    self.message.addGestureRecognizer(gesture)
  }

  func style() {
    Self.Style.container(self.container)
    Self.Style.shadow(self.contentView)
  }

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.title(self.message, content: model.title)
    Self.Style.subtitle(self.subtitle, content: model.subtitle ?? "")
    Self.Style.icon(self.icon, icon: model.icon)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.container.pin
      .top()
      .bottom()
      .horizontally(SuggestionsView.cellContainerInset)

    self.message.pin
      .left(Self.imageSize + Self.contentInset + Self.imageToMessage)
      .right(Self.contentInset)
      .sizeToFit(.width)
      .top(SuggestionsView.cellContainerInset)

    self.icon.pin
      .size(Self.imageSize)
      .left(Self.contentInset)
      .vCenter(to: self.message.edge.vCenter)

    self.subtitle.pin
      .horizontally(Self.contentInset)
      .sizeToFit(.width)
      .bottom(SuggestionsView.cellContainerInset)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth = size.width - SuggestionsInstructionCell.totalHorizontalMargin
    let titleSize = self.message.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))

    if self.model?.hasSubtitle ?? false {
      let subtitleWidth = size.width - 2 * (SuggestionsView.cellContainerInset + SuggestionsInstructionCell.contentInset)
      let subtitleSize = self.subtitle.sizeThatFits(CGSize(width: subtitleWidth, height: CGFloat.infinity))
      return CGSize(
        width: size.width,
        height: titleSize.height + subtitleSize.height + 2 * SuggestionsView.cellContainerInset
          + SuggestionsInstructionCell.titleToSubtitle
      )
    } else {
      return CGSize(width: size.width, height: titleSize.height + 2 * SuggestionsView.cellContainerInset)
    }
  }
}
extension SuggestionsInstructionCell {
  @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {

    guard self.model?.instruction == .stayHome else { return }
    self.didTapDiscoverMoreStayHome?()
  }
}
private extension SuggestionsInstructionCell {
  enum Style {
    static func container(_ view: UIView) {
      view.backgroundColor = Palette.white
      view.layer.cornerRadius = SharedStyle.cardCornerRadius
      view.layer.masksToBounds = true
    }

    static func shadow(_ view: UIView) {
      view.layer.masksToBounds = false
      view.addShadow(.cardLightBlue)
    }

    static func icon(_ view: UIImageView, icon: UIImage) {
      view.image = icon
      view.contentMode = .scaleAspectFit
    }

    static func title(_ textView: UITextView, content: String) {
        
      textView.isSelectable = false
      textView.isEditable = false
      textView.isScrollEnabled = false
      textView.backgroundColor = .clear
      textView.linkTextAttributes = [.foregroundColor: Palette.primary]
        
      let boldStyle = TextStyles.pSemibold.byAdding(
          // note: it looks like that by removing this parameter
          // (which shouldn't be necessary) the calculation of
          // the height breaks
        .lineBreakMode(.byWordWrapping),
        .color(Palette.grayDark)
      )
        
      let linkStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.primary),
        .underline(.single, Palette.primary)
      )
        
      let textStyle = TextStyles.p.byAdding(
        .color(Palette.grayDark),
        .alignment(.left),
        .xmlRules([
            .style("b", boldStyle),
            .style("l", linkStyle)
            ])
      )
      textView.attributedText = content.styled(with: textStyle).adapted()

    }

    static func subtitle(_ label: UILabel, content: String) {
      let paragraphs = content.components(separatedBy: "\n\n")

      let textStyle = TextStyles.p.byAdding(
        .color(Palette.grayNormal),
        .alignment(.left)
      )

      if paragraphs.count == 1 {
        TempuraStyles.styleStandardLabel(
          label,
          content: content,
          style: textStyle
        )
      } else {
        // by design we want the line that split the paragraphs of this cell to be smaller
        let font = UIFont.euclidCircularBMedium(size: 8)
        let paragraphLineStyle = StringStyle(
          .font(font),
          .adapt(.control)
        )

        let composable: [Composable] = paragraphs.flatMap {
          ([
            $0.styled(with: textStyle),
            "\n\n".styled(with: paragraphLineStyle)
          ]) as [Composable]
        }
        label.numberOfLines = 0
        label.attributedText = NSAttributedString.composed(of: composable.dropLast()).adapted()
      }
    }
  }
}
