// Logger.swift
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

import Logging

public enum Log {
  /// Whether the logger should act as production. In production no logs are registered
  public static var isProduction: Bool = true

  /**
   Creates a logger
   - parameter label: the label associated with the ogger
   - parameter logLevel: the level assiciated with the logger
   */
  public static func logger(for label: String, logLevel: Logger.Level) -> Logger {
    return Logger(label: label) { label in
      var handler = SwitchLogHandler(label: label)
      handler.logLevel = logLevel
      return handler
    }
  }
}

/// A protocol that helps syntethizing helper functions for logging.
/// The idea is to create a namespace with a logger variable, and then conform to the procotol.
/// The syntax will be `AppLogger.warn` instead of `AppLogger.logger.warn`
public protocol LoggerProvider {
  /// The logger to use when logging events
  static var logger: Logger { get }
}

public extension LoggerProvider {
  /**
   Appropriate for messages that contain information only when debugging a program.

   - parameter level: The log level to log `message` at. For the available log levels, see `Logger.Level`.
   - parameter message: The message to be logged. `message` can be used with any string interpolation literal.
   - parameter metadata: One-off metadata to attach to this log message
   - parameter file: The file this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#file`).
   - parameter function: The function this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#function`).
   - parameter line: The line this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#line`).
   */
  static func trace(
    _ message: @autoclosure () -> Logger.Message,
    metadata: @autoclosure () -> Logger.Metadata? = nil,
    file: String = #file,
    function: String = #function,
    line: UInt = #line
  ) {
    Self.logger.log(level: .trace, message(), metadata: metadata(), file: file, function: function, line: line)
  }

  /**
   Appropriate for messages that contain information normally of use only when debugging a program.

   - parameter level: The log level to log `message` at. For the available log levels, see `Logger.Level`.
   - parameter message: The message to be logged. `message` can be used with any string interpolation literal.
   - parameter metadata: One-off metadata to attach to this log message
   - parameter file: The file this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#file`).
   - parameter function: The function this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#function`).
   - parameter line: The line this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#line`).
   */
  static func debug(
    _ message: @autoclosure () -> Logger.Message,
    metadata: @autoclosure () -> Logger.Metadata? = nil,
    file: String = #file,
    function: String = #function,
    line: UInt = #line
  ) {
    Self.logger.log(level: .debug, message(), metadata: metadata(), file: file, function: function, line: line)
  }

  /**
   Appropriate for informational messages.

   - parameter level: The log level to log `message` at. For the available log levels, see `Logger.Level`.
   - parameter message: The message to be logged. `message` can be used with any string interpolation literal.
   - parameter metadata: One-off metadata to attach to this log message
   - parameter file: The file this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#file`).
   - parameter function: The function this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#function`).
   - parameter line: The line this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#line`).
   */
  static func info(
    _ message: @autoclosure () -> Logger.Message,
    metadata: @autoclosure () -> Logger.Metadata? = nil,
    file: String = #file,
    function: String = #function,
    line: UInt = #line
  ) {
    Self.logger.log(level: .info, message(), metadata: metadata(), file: file, function: function, line: line)
  }

  /**
   Appropriate for conditions that are not error conditions, but that may require special handling.

   - parameter level: The log level to log `message` at. For the available log levels, see `Logger.Level`.
   - parameter message: The message to be logged. `message` can be used with any string interpolation literal.
   - parameter metadata: One-off metadata to attach to this log message
   - parameter file: The file this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#file`).
   - parameter function: The function this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#function`).
   - parameter line: The line this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#line`).
   */
  static func notice(
    _ message: @autoclosure () -> Logger.Message,
    metadata: @autoclosure () -> Logger.Metadata? = nil,
    file: String = #file,
    function: String = #function,
    line: UInt = #line
  ) {
    Self.logger.log(level: .notice, message(), metadata: metadata(), file: file, function: function, line: line)
  }

  /**
   Appropriate for messages that are not error conditions, but more severe than `notice`.

   - parameter level: The log level to log `message` at. For the available log levels, see `Logger.Level`.
   - parameter message: The message to be logged. `message` can be used with any string interpolation literal.
   - parameter metadata: One-off metadata to attach to this log message
   - parameter file: The file this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#file`).
   - parameter function: The function this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#function`).
   - parameter line: The line this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#line`).
   */
  static func warning(
    _ message: @autoclosure () -> Logger.Message,
    metadata: @autoclosure () -> Logger.Metadata? = nil,
    file: String = #file,
    function: String = #function,
    line: UInt = #line
  ) {
    Self.logger.log(level: .warning, message(), metadata: metadata(), file: file, function: function, line: line)
  }

  /**
   Appropriate for error conditions.

   - parameter level: The log level to log `message` at. For the available log levels, see `Logger.Level`.
   - parameter message: The message to be logged. `message` can be used with any string interpolation literal.
   - parameter metadata: One-off metadata to attach to this log message
   - parameter file: The file this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#file`).
   - parameter function: The function this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#function`).
   - parameter line: The line this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#line`).
   */
  static func error(
    _ message: @autoclosure () -> Logger.Message,
    metadata: @autoclosure () -> Logger.Metadata? = nil,
    file: String = #file,
    function: String = #function,
    line: UInt = #line
  ) {
    Self.logger.log(level: .error, message(), metadata: metadata(), file: file, function: function, line: line)
  }

  /**
   Appropriate for critical error conditions that usually require immediate attention.

   When a `critical` message is logged, the logging backend (`LogHandler`) is free to perform
   more heavy-weight operations to capture system state (such as capturing stack traces) to facilitate
   debugging.

   - parameter level: The log level to log `message` at. For the available log levels, see `Logger.Level`.
   - parameter message: The message to be logged. `message` can be used with any string interpolation literal.
   - parameter metadata: One-off metadata to attach to this log message
   - parameter file: The file this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#file`).
   - parameter function: The function this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#function`).
   - parameter line: The line this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#line`).
   */
  static func critical(
    _ message: @autoclosure () -> Logger.Message,
    metadata: @autoclosure () -> Logger.Metadata? = nil,
    file: String = #file,
    function: String = #function,
    line: UInt = #line
  ) {
    Self.logger.log(level: .critical, message(), metadata: metadata(), file: file, function: function, line: line)
  }

  /**
   Logs a fatal error. This method both logs a critical event, and then crashes

   - parameter level: The log level to log `message` at. For the available log levels, see `Logger.Level`.
   - parameter message: The message to be logged. `message` can be used with any string interpolation literal.
   - parameter metadata: One-off metadata to attach to this log message
   - parameter file: The file this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#file`).
   - parameter function: The function this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#function`).
   - parameter line: The line this log message originates from
        (there's usually no need to pass it explicitly as it defaults to `#line`).
   */
  static func fatalError(
    _ message: @autoclosure () -> Logger.Message,
    metadata: @autoclosure () -> Logger.Metadata? = nil,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
  ) -> Never {
    Self.critical(message(), metadata: metadata(), file: "\(file)", function: "\(function)", line: line)
    let mex: String = "\(message()). File: \(file). Function: \(function). Line: \(line)"
    Swift.fatalError(mex, file: file, line: line)
  }
}

/// Logger that switches between no logs, and stout logging according to `Log.isProduction`
private struct SwitchLogHandler: LogHandler {
  private var productionLogHandler: LogHandler
  private var label: String

  fileprivate init(label: String) {
    self.label = label
    self.productionLogHandler = StreamLogHandler.standardOutput(label: self.label)
  }

  func log(
    level: Logger.Level,
    message: Logger.Message,
    metadata: Logger.Metadata?,
    file: String,
    function: String,
    line: UInt
  ) {
    guard !Log.isProduction else {
      return
    }

    self.productionLogHandler
      .log(
        level: level,
        message: "[\(self.label)]: \(message)",
        metadata: metadata,
        file: file,
        function: function,
        line: line
      )
  }

  subscript(metadataKey key: String) -> Logger.Metadata.Value? {
    get {
      guard !Log.isProduction else {
        return nil
      }

      return self.productionLogHandler.metadata[key]
    }
    set(newValue) {
      guard !Log.isProduction else {
        return
      }

      self.productionLogHandler.metadata[key] = newValue
    }
  }

  var metadata: Logger.Metadata {
    get { self.productionLogHandler.metadata }
    set { self.productionLogHandler.metadata = newValue }
  }

  var logLevel: Logger.Level {
    get { self.productionLogHandler.logLevel }
    set { self.productionLogHandler.logLevel = newValue }
  }
}

/// Leverages `Log` to log events for the lib
public enum LibLogger: LoggerProvider {
  public static var logger: Logger { Log.logger(for: "lib.extensions", logLevel: .debug) }
}
