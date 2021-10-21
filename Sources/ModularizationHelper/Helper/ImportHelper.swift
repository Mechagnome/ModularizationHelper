import Foundation
import Combine
import SwiftUI
import Files
import Alliances
import BaseUI
import SwiftyJSON
import SourceKittenFramework

public final class ImportHelper: AlliancesApp {
    
    enum Key: String {
        case path
        case scanPath
        case module
    }
    
    public static var appInfo: AppInfo {
        .init(id: "ImportHelper.ModularizationHelper.Alliances.Mechagnome", name: "插入 import")
    }

    public var name: String { "插入 import" }
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
        guard let path = configuration.settings[Key.path.rawValue] as? String,
        let scanPath = configuration.settings[Key.scanPath.rawValue] as? String,
        let module = configuration.settings[Key.module.rawValue] as? String else {
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
        addImport(dir: path, scanObjectDir: scanPath, module: module)
        progress = 1
    }
    
    func getSettings() -> AnyView {
        cancellables = Set<AnyCancellable>()
        
        let path = configuration.settings[Key.path.rawValue] as? String ?? ""
        let item1 = SettingsInputItem(name: "需要 import 的路径：", default: path, placeholder: "请设置需要 import 的路径")
        item1.value.sink { [weak self] value in
            self?.configuration.settings[Key.path.rawValue] = value
        }.store(in: &cancellables)
        
        let scanPath = configuration.settings[Key.scanPath.rawValue] as? String ?? ""
        let item2 = SettingsInputItem(name: "扫描 class 的路径：", default: scanPath, placeholder: "请设置扫描 class 的路径")
        item2.value.sink { [weak self] value in
            self?.configuration.settings[Key.scanPath.rawValue] = value
        }.store(in: &cancellables)
        
        let module = configuration.settings[Key.module.rawValue] as? String ?? ""
        let item3 = SettingsInputItem(name: "新模块：", default: module, placeholder: "请设置 import 的模块名称")
        item3.value.sink { [weak self] value in
            self?.configuration.settings[Key.module.rawValue] = value
        }.store(in: &cancellables)
        
        return .init(SettingsController(items: [item1, item2, item3]))
    }
}

extension ImportHelper {
    
    func addImport(dir: String, scanObjectDir: String, module: String) {
        let contains = ScanObject.scan(dir: scanObjectDir)
        let files = CodeHelper.getAllFile(at: dir)
        
        for (idx, file) in files.enumerated() {
            addImport(file: file, module: module, contains: contains)
            progress = Double(idx + 1) / Double(files.count)
        }
    }
    
    func addImport(file: String, module: String, contains: [String]) {
        guard let data = FileManager.default.contents(atPath: file),
              let code = String(data: data, encoding: .utf8) else {
            print("Failed to read file: \(file)")
            return
        }
        let url = URL(fileURLWithPath: file)
        
        for keyword in contains {
            guard code.contains(keyword), code.contains("import \(module)") == false else { continue }
            let res = code as NSString
            let range = res.range(of: "import")
            if range.location != NSNotFound {
                let first = res.substring(to: range.location)
                let last = res.substring(from: range.location)
                let newCode = first + "import \(module)\n" + last
                
                guard let newData = newCode.data(using: .utf8) else {
                    print("Failed to convert to data, file: \(file)")
                    return
                }
                do {
                    try newData.write(to: url)
                } catch {
                    print("Error to write file: \(file)")
                }
            }
        }
    }
}
