import Foundation
import Alliances
import SwiftUI
import Combine
import BaseUI

public class ModularizationHelper: AlliancesApp {
    
    enum Key: String {
        case remark
        case `public`
        case `import`
        case xib
        case move
    }
    
    public static var appInfo: AppInfo {
        .init(id: "ModularizationHelper.Alliances.Mechagnome", name: "组件化助手", summary: "")
    }
    
    public var name: String { "组件化助手" }
    public var remark: String? { getSettings(for: .remark) as? String }
    public var canRun: Bool { false }
    
    public var core: AlliancesUICore = .init()
    public var tasks: [AlliancesApp] = []
    public var configuration: AlliancesConfiguration
    public var settingsView: AnyView? {
        return getSettings()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    required public init(_ configuration: AlliancesConfiguration) {
        self.configuration = configuration
        updateTasks()
    }
    
    public func run() throws { }
    
    func updateTasks() {
        tasks = []
        if (getSettings(for: .public) as? Bool) ?? true {
            tasks.append(PublicHelper(configuration))
        }
        if (getSettings(for: .import) as? Bool) ?? true {
            tasks.append(ImportHelper(configuration))
        }
        if (getSettings(for: .xib) as? Bool) ?? true {
            tasks.append(XibHelper(configuration))
        }
        if (getSettings(for: .move) as? Bool) ?? true {
            tasks.append(MoveHelper(configuration))
        }
    }
    
    func getSettings() -> AnyView {
        cancellables = Set<AnyCancellable>()
        
        let item1 = SettingsInputItem(name: "备注：", default: remark ?? "", placeholder: "请输入备注")
        item1.value.sink { [weak self] value in
            self?.configuration.settings[Key.remark.rawValue] = value
            self?.updateTasks()
            self?.reload()
        }.store(in: &cancellables)
        
        
        let item2 = SettingsBoolItem(name: "子插件选择：", default: (getSettings(for: .public) as? Bool) ?? true, description: "插入 public")
        item2.value.sink { [weak self] value in
            self?.setSettings(value: value, for: .public)
            self?.updateTasks()
            self?.reload()
        }.store(in: &cancellables)
        
        let item3 = SettingsBoolItem(name: "", default: (getSettings(for: .import) as? Bool) ?? true, description: "插入 import")
        item3.value.sink { [weak self] value in
            self?.setSettings(value: value, for: .import)
            self?.updateTasks()
            self?.reload()
        }.store(in: &cancellables)
        
        let item4 = SettingsBoolItem(name: "", default: (getSettings(for: .xib) as? Bool) ?? true, description: "更新 xib 模块")
        item4.value.sink { [weak self] value in
            self?.setSettings(value: value, for: .xib)
            self?.updateTasks()
            self?.reload()
        }.store(in: &cancellables)
        
        let item5 = SettingsBoolItem(name: "", default: (getSettings(for: .move) as? Bool) ?? true, description: "拷贝有效代码")
        item5.value.sink { [weak self] value in
            self?.setSettings(value: value, for: .move)
            self?.updateTasks()
            self?.reload()
        }.store(in: &cancellables)
        
        return .init(SettingsController(items: [item1, item2, item3, item4, item5]))
    }
    
    private func setSettings(value: Any, for key: Key) {
        configuration.settings[key.rawValue] = value
    }
    
    private func getSettings(for key: Key) -> Any? {
        configuration.settings[key.rawValue]
    }
}
