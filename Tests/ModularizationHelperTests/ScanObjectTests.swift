import XCTest
import Stem
@testable import ModularizationHelper

final class ScanObjectTests: XCTestCase {
    
    func test() throws {
        let file = try FilePath.Folder(sanbox: .cache).file(name: "ScanObjectTestsCode.swift")
        try file.delete()
        try file.create(with: code.data(using: .utf8))
        let objects = ScanObject.scan(file: file.url.path)
        try file.delete()
        assert(objects == ["Animal", "AnimalType", "Dog", "Cat"])
    }
    
    let code = """
public protocol Animal {
    
}

public enum AnimalType {
    case cat
    case dog
}

public class Dog {

    public class Foo {

    }
}

public struct Cat {
    
}
"""
}
