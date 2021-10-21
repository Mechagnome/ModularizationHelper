import Foundation
import SwiftUI
import Combine
import Files
import Alliances
import BaseUI
import SwiftyJSON
import SourceKittenFramework

public final class PublicHelper: AlliancesApp {
    
    enum Key: String {
        case path
    }
    
    public static var appInfo: AppInfo {
        .init(id: "PublicHelper.ModularizationHelper.Alliances.Mechagnome", name: "插入 public")
    }
    
    public var name: String { "插入 public" }
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
        guard let path = configuration.settings["path"] as? String else {
            // 参数未设置
            showSettingsView()
            return
        }
        
        var isDirectory: ObjCBool = true
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
            // 参数不合法
            showSettingsView()
            return
        }
        
        progress = 0
        if isDirectory.boolValue {
            addPublic(dir: path)
        } else {
            addPublic(file: path)
        }
        progress = 1
    }
    
    func getSettings() -> AnyView {
        cancellables = Set<AnyCancellable>()
        
        let path = configuration.settings[Key.path.rawValue] as? String ?? ""
        let item = SettingsInputItem(name: "路径：", default: path, placeholder: "请设置文件/目录路径")
        item.value.sink { [weak self] value in
            self?.configuration.settings[Key.path.rawValue] = value
        }.store(in: &cancellables)
        
        return .init(SettingsController(items: [item]))
    }
}

extension PublicHelper {
    
    func addPublic(dir: String) {
        let files = CodeHelper.getAllFile(at: dir)
        for (idx, file) in files.enumerated() {
            addPublic(file: file)
            progress = Double(idx + 1) / Double(files.count)
        }
    }
    
    func addPublic(file: String) {
        let DEBUG = false
        var code = CodeHelper.getCode(by: file)
        guard let res = try? SourceKittenFramework.Structure(file: .init(contents: code)) else { return }
        if DEBUG {
            print(JSON(res.dictionary).rawString()!)
            analyse(code: &code, json: JSON(res.dictionary))
            print("=====")
            print(code)
        } else {
            analyse(code: &code, json: JSON(res.dictionary))
            CodeHelper.writeCode(to: file, code: code as String)
        }
    }
}

// MARK: - AST 词法分析
private extension PublicHelper {
    
    /// 入口
    func analyse(code: inout String, json: JSON) {
        let obj: SwiftObject
        let kind = Kind(json["key.kind"].stringValue)
        switch kind {
        case .varClass, .varStatic, .varGlobal, .varInstance:
            obj = SwiftProperty(json: json)
        case .funcClass, .funcStatic, .funcInstance, .funcSubscript:
            obj = SwiftFunction(json: json)
        default:
            obj = SwiftObject(json: json)
        }
        analyse(code: &code, obj: obj)
    }
    
    /// 处理对象
    func analyse(code: inout String, obj: SwiftObject) {
        if let obj = obj as? SwiftFunction {
            analyse(code: &code, obj: obj)
        } else if let obj = obj as? SwiftProperty {
            analyse(code: &code, obj: obj)
        } else {
            for subObj in obj.substructure.reversed() {
                analyse(code: &code, obj: subObj)
            }
            
            switch obj.kind {
            case .class, .struct, .enum, .protocol:
                guard obj.implicitInternal, obj.parentIsPrivate == false else { return }
                inset(code: &code, offset: obj.offset, content: "public ")
            default:
                break
            }
        }
    }
    
    /// 处理方法
    func analyse(code: inout String, obj: SwiftFunction) {
        guard obj.implicitInternal, obj.parentIsPrivate == false else { return }
        if let parent = obj.parent, parent.kind == .protocol {
            return
        }
        if obj.name == "deinit" {
            return
        }
        
        let insetOffset = obj.attributes.isEmpty ? obj.offset : obj.attributeOffset
        inset(code: &code, offset: insetOffset, content: "public ")
    }
    
    /// 处理属性
    func analyse(code: inout String, obj: SwiftProperty) {
        guard obj.implicitInternal, obj.parentIsPrivate == false else { return }
        if let parent = obj.parent, parent.kind == .protocol {
            return
        }
        
        let insetOffset = obj.attributes.isEmpty ? obj.offset : obj.attributeOffset
        inset(code: &code, offset: insetOffset, content: "public ")
    }
    
    /// 插入
    func inset(code: inout String, offset: Int, content: String) {
        let prefix = (code as NSString).substring(to: code.count > offset ? offset : code.count-1)
        var count = CodeHelper.match(code: prefix, pattern: "[^\\x00-\\xff]") * 2
        if prefix.contains("©") {
            count += 1
        }
        code.insert(contentsOf: content, at: code.index(code.startIndex, offsetBy: offset - count))
    }
}
