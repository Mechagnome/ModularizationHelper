import XCTest
import Stem
import Alliances
@testable import ModularizationHelper

final class ImportHelperTests: XCTestCase {
    
    func test() throws {
        let file = try FilePath.Folder(sanbox: .cache).file(name: "ImportHelperTestsCode.swift")
        try file.delete()
        try file.create(with: code.data(using: .utf8))
        try ImportHelper(AlliancesConfiguration(folder: .init(sanbox: .cache))).addImport(file: file.url.path, module: "Animal", contains: ["Cat"])
        let fileCode = try file.read()
        try file.delete()
        assert(fileCode == newCode)
    }
    
    let code = """
import UIKit

func f1() {
    Cat()
}
"""
    
    let newCode = """
import Animal
import UIKit

func f1() {
    Cat()
}
"""
}
