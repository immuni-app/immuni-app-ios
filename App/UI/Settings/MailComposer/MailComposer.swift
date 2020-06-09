// MailComposer.swift
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
import MessageUI

final class MessageComposer: MFMailComposeViewController {
  convenience init(context: MessageComposerContext) {
    self.init()

    self.mailComposeDelegate = self

    self.setToRecipients([context.recipient])
    self.setSubject(context.subject)
    self.setMessageBody(context.body, isHTML: false)
  }
}

extension MessageComposer: MFMailComposeViewControllerDelegate {
  func mailComposeController(
    _ controller: MFMailComposeViewController,
    didFinishWith result: MFMailComposeResult,
    error: Error?
  ) {
    self.dismiss(animated: true, completion: nil)
  }
}

struct MessageComposerContext {
  /// The email subject
  let subject: String

  /// The body of the email
  let body: String

  /// The recipient of the email
  let recipient: String
}
