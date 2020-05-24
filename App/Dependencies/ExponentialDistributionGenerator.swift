// ExponentialDistributionGenerator.swift
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

/// Protocol used to test the logic where a random generator is required
protocol ExponentialDistributionGenerator {
  /// Generates a random number using an exponential distribution with the given mean.
  static func exponentialRandom(with mean: Double) -> Double
}

/// Double conformance to `UniformDistributionGenerator`
extension Double: ExponentialDistributionGenerator {
  /// Given that Swift doesn't have native support for such method, the calculation
  /// is performed leveraging the inverse transform sampling
  ///
  /// -seeAlso: https://en.wikipedia.org/wiki/Exponential_distribution#Computational_methods
  static func exponentialRandom(with mean: Double) -> Double {
    let random = Self.randomNumberBetweenZeroAndOne()
    return log(random) * -mean
  }
}
