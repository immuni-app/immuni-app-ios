// OTP.swift
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

import Extensions
import Foundation

/// Struct that represents an OTP. An OTP
/// is a 10-characters code that is used to authorize the upload
/// of TEKs. The code has 9 randomly generated digit. The last charater, instead,
/// is a control character
public struct OTP {
    /// The default length of the OTP
    public static let defaultLength = 10

    /// The prefix if otp is cun type
    public static let prefixCun = "CUN-"

    /// The caracters of the code
    let characters: [Character]

    /// type of otp code
    var otpType: OtpType = .otp

    /// Generates a new random, valid OTP with the given length
    public init(length: Int = Self.defaultLength) {
        let characters = (0 ..< length - 1).compactMap { _ in Self.alphabet.randomElement() }
        assert(characters.count == length - 1)
        let checkDigit = Self.checkDigit(for: characters)
        self.characters = characters + [checkDigit]
    }

    /// Generates a new valid CUN with the given string
    public init(code: String) {
        characters = Array(code)
        otpType = .cun
    }
}

enum OtpType {
    case otp
    case cun
}

extension OTP: RawRepresentable {
    public var rawValue: String {
        if otpType == .cun {
            return Self.prefixCun + String(characters)
        }
        return String(characters)
    }

    public init?(rawValue: String) {
        guard rawValue.count > 2 else {
            return nil
        }

        let allCharacters = Array(rawValue)

        var characters = allCharacters
        let checkDigit = characters.removeLast()

        guard Self.verify(checkDigit: checkDigit, for: characters) else {
            return nil
        }

        self.characters = allCharacters
    }
}

public extension OTP {
    /// Returns an array of strings with the code parts of the given OTP.
    /// To simplify the readability, the code is splitted into 3 parts.
    /// Output will look like: ["AAA", "BBBB", "CCC"].
    var codeParts: [String] {
        let fixedPartSize = Self.defaultLength / 3
        let first = characters.prefix(fixedPartSize)
        let last = characters.suffix(fixedPartSize)
        let middle = characters.dropLast(fixedPartSize).dropFirst(fixedPartSize)

        return [first, middle, last].map { String($0) }
    }

    func verifyCode() -> Bool {
        
        var characters = self.characters
        let checkDigit = characters.removeLast()
        
        var sum = 0
        for (index, char) in characters.enumerated() {
            if index % 2 != 0 {
                if let value = Self.evenMap[char] {
                    sum += value
                } else { return false }
            }
            if index % 2 == 0 {
                if let value = Self.oddMap[char] {
                    sum += value
                } else { return false }
            }
        }

        let index = sum % Self.checkDigitMap.count
        let calculated = Self.checkDigitMap[index]

        guard let _ = calculated else { return false }

        return calculated == checkDigit
    }
}

private extension OTP {
    /// Verifies that the given check digit is valid for the given code
    private static func verify(checkDigit: Character, for code: [Character]) -> Bool {
        let calculated = Self.checkDigit(for: code)
        return calculated == checkDigit
    }

    /// Calculates the check digit for the given code
    private static func checkDigit(for code: [Character]) -> Character {
        let sum = code.enumerated().reduce(0) { previous, item -> Int in
            let map = (item.offset + 1).isMultiple(of: 2) ? Self.evenMap : Self.oddMap
            let current = map[item.element] ?? LibLogger.fatalError("Broken OTP algorithm")
            return previous + current
        }

        let index = sum % Self.checkDigitMap.count
        let checkDigit = Self.checkDigitMap[index] ?? LibLogger.fatalError("Invalid digit code")
        return checkDigit
    }

    static let alphabet: [Character] = [
        "A", "E", "F", "H", "I", "J", "K", "L", "Q", "R", "S", "U", "W",
        "X", "Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    ]

    static var checkDigitMap: [Int: Character] {
        let values = Self.alphabet.enumerated().map { ($0.offset, $0.element) }
        return Dictionary(uniqueKeysWithValues: values)
    }

    static let evenMap: [Character: Int] = [
        "0": 0,
        "1": 1,
        "2": 2,
        "3": 3,
        "4": 4,
        "5": 5,
        "6": 6,
        "7": 7,
        "8": 8,
        "9": 9,
        "A": 0,
        "B": 1,
        "C": 2,
        "D": 3,
        "E": 4,
        "F": 5,
        "G": 6,
        "H": 7,
        "I": 8,
        "J": 9,
        "K": 10,
        "L": 11,
        "M": 12,
        "N": 13,
        "O": 14,
        "P": 15,
        "Q": 16,
        "R": 17,
        "S": 18,
        "T": 19,
        "U": 20,
        "V": 21,
        "W": 22,
        "X": 23,
        "Y": 24,
        "Z": 25,
    ]

    static let oddMap: [Character: Int] = [
        "0": 1,
        "1": 0,
        "2": 5,
        "3": 7,
        "4": 9,
        "5": 13,
        "6": 15,
        "7": 17,
        "8": 19,
        "9": 21,
        "A": 1,
        "B": 0,
        "C": 5,
        "D": 7,
        "E": 9,
        "F": 13,
        "G": 15,
        "H": 17,
        "I": 19,
        "J": 21,
        "K": 2,
        "L": 4,
        "M": 18,
        "N": 20,
        "O": 11,
        "P": 3,
        "Q": 6,
        "R": 8,
        "S": 12,
        "T": 14,
        "U": 16,
        "V": 10,
        "W": 22,
        "X": 25,
        "Y": 24,
        "Z": 23,
    ]
}
