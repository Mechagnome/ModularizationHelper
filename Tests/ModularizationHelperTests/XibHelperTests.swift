import XCTest
import Stem
import Alliances
@testable import ModularizationHelper

final class XibHelperTests: XCTestCase {
    
    func test() throws {
        let file = try FilePath.Folder(sanbox: .cache).file(name: "XibHelperTestsCode.swift")
        try file.delete()
        try file.create(with: code.data(using: .utf8))
        try XibHelper(AlliancesConfiguration(folder: .init(sanbox: .cache))).updateXib(file: file.url.path, contains: ["FollowButton"], module: "BaseUI", oldModule: "Project")
        let fileCode = try file.read()
        try file.delete()
        assert(fileCode == newCode)
    }
    
    let code = """
<button opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="SWp-hr-VCi" customClass="FollowButton" customModule="Project" customModuleProvider="target">
"""
    
    let newCode = """
<button opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="SWp-hr-VCi" customClass="FollowButton" customModule="BaseUI">
"""
}
