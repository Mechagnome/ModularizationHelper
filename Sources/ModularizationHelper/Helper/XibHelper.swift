import Foundation
import Combine
import SwiftUI
import Files
import Alliances
import BaseUI
import SwiftyJSON
import SourceKittenFramework

public final class XibHelper: AlliancesApp {
    
    enum Key: String {
        case path
        case scanPath
        case module
        case oldModule
    }
    
    public static var bundleID: String { "XibHelper.ModularizationHelper.Alliances.Mechagnome" }
    
    public var name: String { "更新 xib 模块" }
    public var remark: String? { nil }
    
    public var core: AlliancesUICore = .init()
    public var tasks: [AlliancesApp] = []
    public var configuration: AlliancesConfiguration
    
    private var cancellables = Set<AnyCancellable>()
    
    required public init(_ configuration: AlliancesConfiguration) {
        self.configuration = configuration
    }
    
    public func run() throws {
        guard let path = configuration.settings[Key.path.rawValue] as? String,
        let scanPath = configuration.settings[Key.scanPath.rawValue] as? String,
        let module = configuration.settings[Key.module.rawValue] as? String,
        let oldModule = configuration.settings[Key.module.rawValue] as? String else {
            // 参数未设置
            show(view: getSettings())
            return
        }
        
        guard CodeHelper.directoryExists(path: path), CodeHelper.directoryExists(path: scanPath) else {
            // 参数不合法，目录不存在
            show(view: getSettings())
            return
        }
        
        progress = 0
        updateXib(dir: path, scanObjectDir: scanPath, module: module, oldModule: oldModule)
        progress = 1
    }
    
    func getSettings() -> AnyView {
        cancellables = Set<AnyCancellable>()
        
        let path = configuration.settings[Key.path.rawValue] as? String ?? ""
        let item1 = SettingsInputItem(name: "需要更新 xib 的路径", default: path, placeholder: "请设置需要更新 xib 的路径")
        item1.value.sink { [weak self] value in
            self?.configuration.settings[Key.path.rawValue] = value
        }.store(in: &cancellables)
        
        let scanPath = configuration.settings[Key.scanPath.rawValue] as? String ?? ""
        let item2 = SettingsInputItem(name: "扫描 class 的路径", default: scanPath, placeholder: "请设置扫描 class 的路径")
        item2.value.sink { [weak self] value in
            self?.configuration.settings[Key.scanPath.rawValue] = value
        }.store(in: &cancellables)
        
        let module = configuration.settings[Key.module.rawValue] as? String ?? ""
        let item3 = SettingsInputItem(name: "新模块", default: module, placeholder: "请设置需要更新的模块名称")
        item3.value.sink { [weak self] value in
            self?.configuration.settings[Key.module.rawValue] = value
        }.store(in: &cancellables)
        
        let oldModule = configuration.settings[Key.oldModule.rawValue] as? String ?? ""
        let item4 = SettingsInputItem(name: "旧模块", default: oldModule, placeholder: "请设置需要被替换的模块名称")
        item4.value.sink { [weak self] value in
            self?.configuration.settings[Key.oldModule.rawValue] = value
        }.store(in: &cancellables)
        
        return .init(SettingsController(items: [item1, item2, item3, item4]))
    }
}

extension XibHelper {
    
    func updateXib(dir: String, scanObjectDir: String, module: String, oldModule: String) {
        let contains = ScanObject.scan(dir: scanObjectDir)
        let files = CodeHelper.getAllFile(at: dir)
        for (idx, file) in files.enumerated() {
            updateXib(file: file, contains: contains, module: module, oldModule: oldModule)
            progress = Double(idx + 1) / Double(files.count)
        }
    }
    
    func updateXib(file: String, contains: [String], module: String, oldModule: String) {
        var code = CodeHelper.getCode(by: file)
        for customClass in contains {
            code = code.replacingOccurrences(of: "customClass=\"\(customClass)\" customModule=\"\(oldModule)\" customModuleProvider=\"target\"",
                                             with: "customClass=\"\(customClass)\" customModule=\"\(module)\"")
            code = code.replacingOccurrences(of: "customClass=\"\(customClass)\" customModule=\"\(oldModule)\"",
                                             with: "customClass=\"\(customClass)\" customModule=\"\(module)\"")
        }
        CodeHelper.writeCode(to: file, code: code)
    }
}
