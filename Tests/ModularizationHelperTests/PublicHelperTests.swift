import XCTest
import Stem
import Alliances
@testable import ModularizationHelper

final class PublicHelperTests: XCTestCase {
    
    func test() throws {
        let file = try FilePath.Folder(sanbox: .cache).file(name: "PublicHelperTestsCode.swift")
        try file.delete()
        try file.create(with: code.data(using: .utf8))
        try PublicHelper(AlliancesConfiguration(folder: .init(sanbox: .cache))).addPublic(file: file.url.path)
        let fileCode = try file.read()
        try file.delete()
        assert(fileCode == newCode)
    }
    
    let code = """
// MARK: - Add public
protocol Animal {
    var name: String { get }
}

enum AnimalType {
    case cat
    case dog
}

class Dog {

    @IBOutlet weak var image: UIImageView
    
    @IBInspectable var num: Int = 0
    
    class Foo {

    }
    
    func f0() {
        
    }
    
    @objc
    func f1() {
        
    }
    
    @discardableResult
    func f2() -> Bool {
        return true
    }
    
    @IBAction func f3(_ sender: Any) {
        
    }
}

struct Cat {
    
    public func f1() {
        
    }
}

// MARK: - DONOT add public
internal class Pig {
    
    internal var n1: Int
}

private struct Fish {
    
    private func f1() {
        
    }
}

private extension Cat {
    
    func f2() {
        
    }
}
"""
    
    let newCode = """
// MARK: - Add public
public protocol Animal {
    var name: String { get }
}

public enum AnimalType {
    case cat
    case dog
}

public class Dog {

    @IBOutlet public weak var image: UIImageView
    
    @IBInspectable public var num: Int = 0
    
    public class Foo {

    }
    
    public func f0() {
        
    }
    
    @objc
    public func f1() {
        
    }
    
    @discardableResult
    public func f2() -> Bool {
        return true
    }
    
    @IBAction public func f3(_ sender: Any) {
        
    }
}

public struct Cat {
    
    public func f1() {
        
    }
}

// MARK: - DONOT add public
internal class Pig {
    
    internal var n1: Int
}

private struct Fish {
    
    private func f1() {
        
    }
}

private extension Cat {
    
    func f2() {
        
    }
}
"""
}
