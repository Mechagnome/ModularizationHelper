import Foundation
import Alliances
import SwiftUI
import Combine
import BaseUI

public class ModularizationHelper: AlliancesApp {
    
    enum Key: String {
        case remark
    }
    
    public static var bundleID: String { "ModularizationHelper.Alliances.Mechagnome" }
    
    public var name: String { "组件化助手" }
    public var remark: String? { configuration.settings[Key.remark.rawValue] as? String }
    public var canRun: Bool { false }
    
    public var core: AlliancesUICore = .init()
    public var tasks: [AlliancesApp] = []
    public var configuration: AlliancesConfiguration
    
    private var cancellables = Set<AnyCancellable>()
    
    required public init(_ configuration: AlliancesConfiguration) {
        self.configuration = configuration
        tasks.append(PublicHelper(configuration))
        tasks.append(ImportHelper(configuration))
        tasks.append(XibHelper(configuration))
        tasks.append(MoveHelper(configuration))
    }
    
    public func run() throws { }
    
    func getSettings() -> AnyView {
        cancellables = Set<AnyCancellable>()
        
        let item = SettingsInputItem(name: "备注", default: remark ?? "", placeholder: "请输入备注")
        item.value.sink { [weak self] value in
            self?.configuration.settings[Key.remark.rawValue] = value
            self?.reload()
        }.store(in: &cancellables)
        
        return .init(SettingsController(items: [item]))
    }
    
}
