//
//  Accessibility.swift
//  SourceTool
//
//  Created by Ray Jiang on 2021/9/29.
//

import Foundation

enum Accessibility {
    case `open`
    case `public`
    case `internal`
    case `private`
    case `fileprivate`
    
    init(_ value: String) {
        switch value {
        case "source.lang.swift.accessibility.open":
            self = .open
        case "source.lang.swift.accessibility.public":
            self = .public
        case "source.lang.swift.accessibility.internal":
            self = .internal
        case "source.lang.swift.accessibility.private":
            self = .private
        case "source.lang.swift.accessibility.fileprivate":
            self = .fileprivate
        default:
            self = .internal
        }
    }
    
    var isPrivate: Bool {
        switch self {
        case .private, .fileprivate:
            return true
        default:
            return false
        }
    }
}
