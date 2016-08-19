//: Playground - noun: a place where people can play

import Cocoa


// Basic task demo
let lsTask = Process()
let wcTask = Process()
let lsOutPipe = Pipe()
let wcOutPipe = Pipe()

wcTask.launchPath = "/usr/bin/wc"
wcTask.arguments = ["-l"]
lsTask.launchPath = "/bin/ls"
lsTask.arguments = ["/Users/steveg"]

lsTask.standardOutput = lsOutPipe
wcTask.standardInput = lsOutPipe
wcTask.standardOutput = wcOutPipe

// NOTE: launch throws an exception on bad input but it is an Objective-C exception. Swift won't catch it
// see http://stackoverflow.com/questions/32758811/catching-nsexception-in-swift
lsTask.launch()
wcTask.launch()


lsTask.waitUntilExit()
wcTask.waitUntilExit()

print("ls terminated with \(lsTask.terminationStatus), wc terminated with \(wcTask.terminationStatus)")

let data = wcOutPipe.fileHandleForReading.readDataToEndOfFile()
let stringData = String(data: data, encoding: String.Encoding.utf8)

print("File count = \(stringData?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))")

// Dealing with some results
let i = Int("  23".trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
let f = Float("10.12")

// Collection.map() demo
let firstTask = Process()
let stdout = Pipe()
firstTask.standardOutput = stdout
firstTask.launchPath = "/bin/ls"
firstTask.currentDirectoryPath = "/Users/steveg"
firstTask.launch()
firstTask.waitUntilExit()

let lsData = stdout.fileHandleForReading.readDataToEndOfFile()
if let lsText = String(data: lsData, encoding: String.Encoding.utf8) {
    print("\(lsText)")
    let contents = lsText.components(separatedBy: "\n")
    let fullPaths = contents.map(){(a) -> String in firstTask.currentDirectoryPath+"/"+a}
    // let fullPaths = contents.map(){firstTask.currentDirectoryPath+"/"+$0}

    print("\(fullPaths)")
}


func toNSArray(v: Any?) -> NSArray? {
    return v as? NSArray
}

func toNSDictionary(v: Any?) ->NSDictionary? {
    return v as? NSDictionary
}



func getItemsFromSystemProfiler(dataTypeString: String) -> Array<NSDictionary>? {
    let task = Process()
    
    var systemProfilerInfo: Array<NSDictionary>? = nil
    
    task.launchPath = "/usr/sbin/system_profiler"
    task.arguments = ["-xml", dataTypeString]
    
    
    let pipe = Pipe()
    task.standardOutput = pipe
    
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    
    
    let dict: Any! = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
    
    
    guard let a = dict as? NSArray else {
        return nil
    }
    
    guard let d = a[0] as? NSDictionary else {
        return nil
    }
    

    if let n = d["_items"] as? NSArray {
        systemProfilerInfo = (n as! Array<NSDictionary>) as Array<NSDictionary>?
    } else {
        systemProfilerInfo = nil
    }
    return systemProfilerInfo
}

// NSArray to Array is toll free. NSDictionary to Dictionary is not but that's OK. They work the same.
let d = getItemsFromSystemProfiler(dataTypeString: "SPHardwareDataType")

