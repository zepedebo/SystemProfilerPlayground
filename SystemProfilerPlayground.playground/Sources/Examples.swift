import Foundation

// Simplest
public func Simple() {
    let lsProc = Process()
    let lsStdout = Pipe()
    lsProc.launchPath = "/bin/ls"
    lsProc.standardOutput = lsStdout
    lsProc.launch()
    lsProc.waitUntilExit()
    let lsResultData = lsStdout.fileHandleForReading.readDataToEndOfFile();
    let lsResultText = String(data: lsResultData, encoding: String.Encoding.utf8)
    print(lsResultText)
}

public func Pipes() {
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
    
    guard FileManager.default.fileExists(atPath: lsTask.launchPath!) && FileManager.default.fileExists(atPath: wcTask.launchPath!) else
    {
        print("Missing executable")
        exit(0)
    }
    
    lsTask.launch()
    wcTask.launch()
    
    
    lsTask.waitUntilExit()
    wcTask.waitUntilExit()
    
    print("ls terminated with \(lsTask.terminationStatus), wc terminated with \(wcTask.terminationStatus)")
    
    let data = wcOutPipe.fileHandleForReading.readDataToEndOfFile()
    let stringData = String(data: data, encoding: String.Encoding.utf8)
    
    print("File count = \(stringData?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))")
    
}

public func GetUUIDPlainText() {
    let spProc = Process()
    
    spProc.launchPath = "/usr/sbin/system_profiler"
    spProc.arguments = ["SPHardwareDataType"]
    
    let pipe = Pipe()
    spProc.standardOutput = pipe
    
    spProc.launch()
    spProc.waitUntilExit()
    
    let spData = pipe.fileHandleForReading.readDataToEndOfFile()
    let spText = String(data:spData, encoding: String.Encoding.utf8)
    
    let lines = spText?.components(separatedBy: "\n")
    
    for line in lines! {
        let parts = line.components(separatedBy: ":")
        if parts.count > 1 && parts[0].contains("Hardware UUID") {
            print(parts[1])
        }
    }    
}

public func GetUUIDXml() {
    let spProc = Process()
    
    spProc.launchPath = "/usr/sbin/system_profiler"
    spProc.arguments = ["-xml", "SPHardwareDataType"]
    
    let pipe = Pipe()
    spProc.standardOutput = pipe
    
    spProc.launch()
    spProc.waitUntilExit()
    
    let spData = pipe.fileHandleForReading.readDataToEndOfFile()
    let dict: AnyObject? = try? PropertyListSerialization.propertyList(from: spData, options: [], format: nil) as AnyObject
    
    //let a = dict as! NSArray
    let hardwareInfo = (dict as! NSArray)[0] as! NSDictionary
    
    let items = (hardwareInfo["_items"] as! NSArray)[0]
    if let result = (items as! NSDictionary)["platform_UUID"] as? String {
        print( result)
    }
}

public func getItemsFromSystemProfiler(dataTypeString: String) -> Array<NSDictionary>? {
    let task = Process()


    task.launchPath = "/usr/sbin/system_profiler"
    task.arguments = ["-xml", dataTypeString]


    let pipe = Pipe()
    task.standardOutput = pipe

    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let dict: AnyObject = try! PropertyListSerialization.propertyList(from: data, options: [], format: nil) as AnyObject


    guard let a = dict as? NSArray else {
        return nil
    }

    guard let d = a[0] as? NSDictionary else {
        return nil
    }

//    var systemProfilerInfo: Array<NSDictionary>? = nil
//
//    if let n = d["_items"] as? NSArray {
//        systemProfilerInfo = (n as! Array<NSDictionary>) as Array<NSDictionary>?
//    } else {
//        systemProfilerInfo = nil
//    }
//    return systemProfilerInfo

    return (d["_items"] as? Array<NSDictionary>)

}

public func mapExample() {
    
}

public func filterExample() {
    let ni = getItemsFromSystemProfiler(dataTypeString: "SPNetworkDataType")
    
    let inames = (ni ?? []).filter{
        return $0["ip_address"] != nil
    }
    
    for device in inames {
        
        print("\(device["interface"] ?? "NA")")
        
    }

}

public func reduceExample() {
    
}


