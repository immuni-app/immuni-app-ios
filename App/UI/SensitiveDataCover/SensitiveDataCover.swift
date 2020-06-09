// SensitiveDataCover.swift
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

/// This screen is a blur cover of the app's screen and is meant to be used when the app becomes inactive or goes to background
/// while it's presenting sensitive data.
/// This is done to avoid a possible low-level malware to access the screenshots that are stored by the OS to implement the
/// multi-tasking functionality.
class SensitiveDataCoverVC: ViewController<AppSetupView> {}
