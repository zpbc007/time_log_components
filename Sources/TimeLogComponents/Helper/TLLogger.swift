//
//  TLLogger.swift
//
//
//  Created by zhaopeng on 2024/6/2.
//

import CocoaLumberjackSwift
import CocoaLumberjackSwiftSupport

public struct TLLogger {
    let context: String
    
    func debug(_ message: String) {
        self.log(message, flag: .debug)
    }
    
    func info(_ message: String) {
        self.log(message, flag: .info)
    }
    
    func warning(_ message: String) {
        self.log(message, flag: .warning)
    }
    
    func error(_ message: String) {
        self.log(message, flag: .error)
    }
    
    private func log(_ message: String, flag: DDLogFlag) {
        DDLog.log(
            asynchronous: true,
            message: .init(
                "(\(context)) \(message)",
                level: DDDefaultLogLevel,
                flag: flag
            )
        )
    }
}

extension TLLogger {
    private class LogFormatter: NSObject, DDLogFormatter {
        enum LogFlag: String {
            case error
            case warning
            case info
            case debug
            case verbose
            
            static func create(_ fromLevel: DDLogFlag) -> String {
                switch fromLevel {
                case .error:
                    return LogFlag.error.rawValue
                case .warning:
                    return LogFlag.warning.rawValue
                case .info:
                    return LogFlag.info.rawValue
                case .debug:
                    return LogFlag.debug.rawValue
                case .verbose:
                    return LogFlag.verbose.rawValue
                default:
                    return "\(fromLevel)"
                }
            }
        }
        private var dateFormatter: DateFormatter
        
        override init() {
            self.dateFormatter = DateFormatter()
            self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            super.init()
        }
        
        func format(message logMessage: DDLogMessage) -> String? {
            let timestamp = dateFormatter.string(from: logMessage.timestamp)
            let logFlag = LogFlag.create(logMessage.flag)
            let logText = logMessage.message
            
            
            return "ZP_TL [\(timestamp)] \(logFlag) \(logText)"
        }
    }
    
    public static func initLogger() {
        let formatter = LogFormatter()
        
        #if !DEBUG
            let fileLogger: DDFileLogger = DDFileLogger() // File Logger
            fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
            fileLogger.logFileManager.maximumNumberOfLogFiles = 7
            fileLogger.logFormatter = formatter
            
            DDLog.add(fileLogger)
        #endif
        
        let consoleLogger = DDOSLogger.sharedInstance
        consoleLogger.logFormatter = formatter
        
        DDLog.add(consoleLogger)
    }
}

