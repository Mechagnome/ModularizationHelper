import Foundation
import Files
import SwiftyJSON
import SourceKittenFramework

final class ScanObject {
    
    static func scan(dir: String) -> [String] {
        var objList: [String] = []
        let files = CodeHelper.getAllFile(at: dir)
        for file in files {
            objList.append(contentsOf: scan(file: file))
        }
        return objList
    }
    
    static func scan(file: String) -> [String] {
        let code = CodeHelper.getCode(by: file)
        guard let res = try? SourceKittenFramework.Structure(file: .init(contents: code)) else { return [] }
        let obj = SwiftObject(json: JSON(res.dictionary))
        return analyse(obj: obj)
    }
}

extension ScanObject {
    
    static private func analyse(obj: SwiftObject) -> [String] {
        var objList: [String] = []
        switch obj.kind {
        case .struct, .class, .enum, .protocol:
            if obj.accessibility == .public || obj.accessibility == .open {
                if let parent = obj.parent,
                   (parent.kind == .struct || parent.kind == .class || parent.kind == .enum) {
                    // 剔除内部类
                } else {
                    objList.append(obj.name)
                }
            }
        default:
            break
        }
        obj.substructure.forEach {
            objList.append(contentsOf: analyse(obj: $0))
        }
        return objList
    }
}
