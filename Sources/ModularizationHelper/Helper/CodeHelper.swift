import Foundation
import Files

struct CodeHelper {
    
    static func directoryExists(path: String) -> Bool {
        var isDirectory: ObjCBool = true
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) {
            return isDirectory.boolValue
        } else {
            return false
        }
    }
    
    static func fileExists(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    static func getAllFile(at dir: String, suffixList: [String] = ["swift"]) -> [String] {
        guard directoryExists(path: dir) else {
            if fileExists(path: dir) {
                for suffix in suffixList {
                    if dir.hasSuffix(suffix) {
                        return [dir]
                    }
                }
            }
            return []
        }
        
        var filePaths: [String] = []
        do {
            let list = try FileManager.default.contentsOfDirectory(atPath: dir)
            for fileName in list {
                var isDir: ObjCBool = true
                let fullPath = "\(dir)/\(fileName)"
                
                if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir) {
                    if isDir.boolValue {
                        filePaths.append(contentsOf: getAllFile(at: fullPath, suffixList: suffixList))
                    } else {
                        for suffix in suffixList {
                            if fullPath.hasSuffix(suffix) {
                                filePaths.append(fullPath)
                                continue
                            }
                        }
                    }
                }
            }
        } catch {
            print("Get file path error: \(error)")
        }
        return filePaths
    }
    
    static func getCode(by filePath: String) -> String {
        do {
            let file = try Files.File(path: filePath)
            let code = try file.readAsString()
            return code
        } catch {
            print(error)
        }
        return ""
    }
    
    static func writeCode(to filePath: String, code: String) {
        do {
            let file = try Files.File(path: filePath)
            try file.write(code)
        } catch {
            print(error)
        }
    }
    
    static func match(code: String, pattern: String) -> Int {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        if let results = regex?.matches(in: code, options: [], range: NSRange(location: 0, length: code.count)), results.count != 0 {
            return results.count
        }
        return 0
    }
    
    static func match(code: String, pattern: String, format: ((String) -> String)? = nil) -> [String] {
        var resultList: [String] = []
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        if let results = regex?.matches(in: code, options: [], range: NSRange(location: 0, length: code.count)), results.count != 0 {
            for result in results {
                var value = (code as NSString).substring(with: result.range)
                if let format = format {
                    value = format(value)
                }
                resultList.append(value)
            }
        }
        return resultList
    }
}
