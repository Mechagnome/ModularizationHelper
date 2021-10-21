import XCTest
import Stem
import Alliances
@testable import ModularizationHelper

final class MoveHelperTests: XCTestCase {
    
    func test() throws {
        let sourceFile = try FilePath.Folder(sanbox: .cache).file(name: "MoveHelperTestsSourceCode.swift")
        try sourceFile.delete()
        try sourceFile.create(with: sourceFileCode.data(using: .utf8))
        
        let targetFile = try FilePath.Folder(sanbox: .cache).file(name: "MoveHelperTestsTargetCode.swift")
        try targetFile.delete()
        try targetFile.create(with: "".data(using: .utf8))
        
        let file = try FilePath.Folder(sanbox: .cache).file(name: "MoveHelperTestsCode.swift")
        try file.delete()
        try file.create(with: normalCode.data(using: .utf8))
        
        try MoveHelper(AlliancesConfiguration(folder: .init(sanbox: .cache))).moveCode(sourceFile: sourceFile.url.path, targetFile: targetFile.url.path, scanDir: file.url.path, patternPrefix: "let ", patternSuffix: "=")
        
        let targetCode = try targetFile.read()
        
        try sourceFile.delete()
        try targetFile.delete()
        try file.delete()
        
        assert(sourceFileCode == targetCode)
    }
    
    let sourceFileCode = """
static let event_click = Event("event_click")
"""
    
    let normalCode = """
    func f1() {
        event(.event_click)
    }
"""
}


