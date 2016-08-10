//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

let firstTask = Task()
let stdout = Pipe()
firstTask.standardOutput = stdout
firstTask.launchPath = "/bin/ls"
firstTask.currentDirectoryPath = "/Users/steveg"
firstTask.launch()
firstTask.waitUntilExit()
print("\(firstTask.terminationStatus)")
let lsData = stdout.fileHandleForReading.readDataToEndOfFile()
if let lsText = String(data: lsData, encoding: String.Encoding.utf8) {
print("\(lsText)")
let contents = lsText.components(separatedBy: "\n")
    let fullPaths = contents.map(){(a) -> String in firstTask.currentDirectoryPath+"/"+a}
    print("\(fullPaths)")
}




func getItemsFromSystemProfiler(dataTypeString: String) -> Array<NSDictionary>? {
    let task = Task()
    
    var systemProfilerInfo: Array<NSDictionary>? = nil
    
        task.launchPath = "/usr/sbin/system_profiler"
        task.arguments = ["-xml", dataTypeString]
        
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        
        
        //let dict : AnyObject!  = try? PropertyListSerialization.propertyList(data, options: PropertyListSerialization.MutabilityOptions.immutable, format: nil)
        let dict: AnyObject! = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        
        
        let a = dict as! NSArray
        let d = a[0] as! NSDictionary
        if let n = d["_items"] as? NSArray {
            systemProfilerInfo = (n as! Array<NSDictionary>) as Array<NSDictionary>?
        } else {
            systemProfilerInfo = nil
        }
    return systemProfilerInfo
}

