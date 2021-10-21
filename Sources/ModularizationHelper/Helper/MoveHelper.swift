import Foundation
import Combine
import SwiftUI
import Files
import Alliances
import BaseUI
import SwiftyJSON
import SourceKittenFramework

public final class MoveHelper: AlliancesApp {
    
    enum Key: String {
        case sourceFile
        case targetFile
        case scanDir
        case patternPrefix
        case patternSuffix
    }
    
    public static var appInfo: AppInfo {
        .init(id: "MoveHelper.ModularizationHelper.Alliances.Mechagnome", name: "拷贝有效代码")
    }
    
    public var name: String { "拷贝有效代码" }
    public var remark: String? { nil }
    
    public var core: AlliancesUICore = .init()
    public var tasks: [AlliancesApp] = []
    public var configuration: AlliancesConfiguration
    public var settingsView: AnyView? {
        return getSettings()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    required public init(_ configuration: AlliancesConfiguration) {
        self.configuration = configuration
    }
    
    public func run() throws {
        guard let sourceFile = configuration.settings[Key.sourceFile.rawValue] as? String,
        let targetFile = configuration.settings[Key.targetFile.rawValue] as? String,
        let scanDir = configuration.settings[Key.scanDir.rawValue] as? String,
        let patternPrefix = configuration.settings[Key.patternPrefix.rawValue] as? String,
        let patternSuffix = configuration.settings[Key.patternSuffix.rawValue] as? String else {
            // 参数未设置
            show(view: getSettings())
            return
        }
        
        guard CodeHelper.fileExists(path: sourceFile), CodeHelper.fileExists(path: targetFile), CodeHelper.directoryExists(path: scanDir) else {
            // 参数不合法，目录不存在
            show(view: getSettings())
            return
        }
        
        progress = 0
        moveCode(sourceFile: sourceFile, targetFile: targetFile, scanDir: scanDir, patternPrefix: patternPrefix, patternSuffix: patternSuffix)
        progress = 1
    }
    
    func getSettings() -> AnyView {
        cancellables = Set<AnyCancellable>()
        
        let sourceFile = configuration.settings[Key.sourceFile.rawValue] as? String ?? ""
        let item1 = SettingsInputItem(name: "待拷贝文件：", default: sourceFile, placeholder: "请设置待拷贝文件路径")
        item1.value.sink { [weak self] value in
            self?.configuration.settings[Key.sourceFile.rawValue] = value
        }.store(in: &cancellables)
        
        let targetFile = configuration.settings[Key.targetFile.rawValue] as? String ?? ""
        let item2 = SettingsInputItem(name: "拷贝至文件：", default: targetFile, placeholder: "请设置拷贝至文件路径")
        item2.value.sink { [weak self] value in
            self?.configuration.settings[Key.targetFile.rawValue] = value
        }.store(in: &cancellables)
        
        let scanDir = configuration.settings[Key.scanDir.rawValue] as? String ?? ""
        let item3 = SettingsInputItem(name: "扫描文件夹：", default: scanDir, placeholder: "请设置扫描文件夹路径")
        item3.value.sink { [weak self] value in
            self?.configuration.settings[Key.scanDir.rawValue] = value
        }.store(in: &cancellables)
        
        let patternPrefix = configuration.settings[Key.patternPrefix.rawValue] as? String ?? ""
        let item4 = SettingsInputItem(name: "匹配规则 - 起：", default: patternPrefix, placeholder: "请设置匹配规则 - 起")
        item3.value.sink { [weak self] value in
            self?.configuration.settings[Key.patternPrefix.rawValue] = value
        }.store(in: &cancellables)
        
        let patternSuffix = configuration.settings[Key.patternSuffix.rawValue] as? String ?? ""
        let item5 = SettingsInputItem(name: "匹配规则 - 始：", default: patternSuffix, placeholder: "请设置匹配规则 - 始")
        item3.value.sink { [weak self] value in
            self?.configuration.settings[Key.patternSuffix.rawValue] = value
        }.store(in: &cancellables)
        
        return .init(SettingsController(items: [item1, item2, item3, item4, item5]))
    }
}

extension MoveHelper {
    
    /// 拷贝有效代码，如打点、Notification.name
    /// - Parameters:
    ///   - sourceFile: 待拷贝文件，同时也是匹配规则文件
    ///   - targetFile: 拷贝至文件
    ///   - scanDir: 扫描文件夹，检查代码是否用到
    ///   - patternPrefix: 匹配规则 - 起
    ///   - patternSuffix: 匹配规则 - 始
    func moveCode(sourceFile: String, targetFile: String, scanDir: String, patternPrefix: String, patternSuffix: String) {
        let pattern = "(\(patternPrefix)).*(\(patternSuffix))"
        let sourceCode = CodeHelper.getCode(by: sourceFile)
        var lineList = sourceCode.components(separatedBy: "\n")
        
        let valueList = CodeHelper.match(code: sourceCode, pattern: pattern) { value in
            var value = value.replacingOccurrences(of: patternPrefix, with: "")
            value = value.replacingOccurrences(of: patternSuffix, with: "")
            value = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return value
        }
        
        // Main
        let files = CodeHelper.getAllFile(at: scanDir)
        var useList = Set<String>()
        for (idx, file) in files.enumerated() {
            let code = CodeHelper.getCode(by: file)
            for value in valueList {
                if code.contains(".\(value)") {
                    useList.insert(value)
                }
            }
            progress = Double(idx + 1) / Double(files.count)
        }
        
        lineList = lineList.filter {
            let value = CodeHelper.match(code: $0, pattern: pattern) { value in
                var value = value.replacingOccurrences(of: patternPrefix, with: "")
                value = value.replacingOccurrences(of: patternSuffix, with: "")
                value = value.trimmingCharacters(in: .whitespacesAndNewlines)
                return value
            }.first ?? ""
            if value.isEmpty {
                return true
            } else {
                return useList.contains(value)
            }
        }
        
        CodeHelper.writeCode(to: targetFile, code: lineList.joined(separator: "\n"))
    }
}
