import Foundation

//: Simplest
public func simpleProcess() {
    let lsProc = Process()
    let lsStdout = Pipe()
    lsProc.launchPath = "/bin/ls"
    lsProc.arguments = ["-l"]
    lsProc.standardOutput = lsStdout
    
    lsProc.launch()
    lsProc.waitUntilExit()
    let lsResultData = lsStdout
        .fileHandleForReading
        .readDataToEndOfFile();
    let lsResultText = String(data: lsResultData,
                              encoding: String.Encoding.utf8)
    print(lsResultText ?? "No results")
}

public func processWithPipes() {
    let lsProc = Process()
    let lsStdout = Pipe()
    lsProc.launchPath = "/bin/ls"
    lsProc.standardOutput = lsStdout


    let wcProc = Process()
    let wcStdout = Pipe()
    wcProc.launchPath = "/usr/bin/wc"
    wcProc.arguments = ["-l"]
    wcProc.standardInput = lsStdout
    wcProc.standardOutput = wcStdout
    
    // NOTE: launch throws an exception on bad input but it is an Objective-C exception. Swift won't catch it
    // see http://stackoverflow.com/questions/32758811/catching-nsexception-in-swift
    
    guard FileManager.default.fileExists(atPath: lsProc.launchPath!) && FileManager.default.fileExists(atPath: wcProc.launchPath!) else
    {
        print("Missing executable")
        exit(0)
    }
    
    lsProc.launch()
    wcProc.launch()
    
    
    lsProc.waitUntilExit()
    wcProc.waitUntilExit()
    
    print("ls terminated with \(lsProc.terminationStatus), wc terminated with \(wcProc.terminationStatus)")
    
    let data = wcStdout.fileHandleForReading.readDataToEndOfFile()
    let stringData = String(data: data, encoding: String.Encoding.utf8)
    
    print("File count = \(stringData?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? "none found")")
    
}

public func getUUIDPlainText() {
    let spProc = Process()
    
    spProc.launchPath = "/usr/sbin/system_profiler"
    spProc.arguments = ["SPHardwareDataType"]
    
    let pipe = Pipe()
    spProc.standardOutput = pipe
    
    spProc.launch()
    spProc.waitUntilExit()
    
    let spData = pipe.fileHandleForReading.readDataToEndOfFile()
    let spText = String(data:spData, encoding: String.Encoding.utf8)
    
    if let lines = spText?.components(separatedBy: "\n") {    
        for line in lines {
            let parts = line.components(separatedBy: ":")
            if parts.count > 1 && parts[0].contains("Hardware UUID") {
                print(parts[1])
            }
        }
    }
}

public func substring() {
    let h = "Hello World"
    let n = h.characters.index(of: " ")
    let s = h.index(h.startIndex, offsetBy: 3)
    let e = h.index(h.endIndex, offsetBy: -2)
    h[s..<e]
    h[s..<n!]
}

public func getUUIDXml() {
    let spProc = Process()
    let pipe = Pipe()
    
    spProc.launchPath = "/usr/sbin/system_profiler"
    spProc.arguments = ["-xml", "SPHardwareDataType"]
    
    spProc.standardOutput = pipe
    
    spProc.launch()
    spProc.waitUntilExit()
    
    let spData = pipe.fileHandleForReading.readDataToEndOfFile()
    let dict: AnyObject? = try? PropertyListSerialization
        .propertyList(from: spData, options: [], format: nil) as AnyObject
    
    let hardwareInfo = (dict as! NSArray)[0] as! NSDictionary
    
    let items = (hardwareInfo["_items"] as! NSArray)[0]
    if let result = (items as! NSDictionary)["platform_UUID"] as? String {
        print( result)
    }
}

public func getItemsFromSystemProfiler(dataTypeString: String) -> [[String: AnyObject]]? {
    let task = Process()
    
    task.launchPath = "/usr/sbin/system_profiler"
    task.arguments = ["-xml", dataTypeString]
    
    let pipe = Pipe()
    task.standardOutput = pipe
    
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let dict: AnyObject = try! PropertyListSerialization.propertyList(from: data,
                                                                      options: [],
                                                                      format: nil) as AnyObject
    
    guard let a = dict as? [AnyObject] else {
        return nil
    }
    
    guard let d = a[0] as? [String: AnyObject] else {
        return nil
    }
    
    return (d["_items"] as? [[String: AnyObject]])
}

public func optionalExample() {
    let a = Double("3.5n")
    let m = Mirror(reflecting: a as Any)
    print(m.subjectType)
    
    if a != nil {
        print(a!)
    } else {
        print("Nope")
    }
    
    if let aNum = a {
        print(aNum)
    } else {
        print("Nope")
    }

}

public func lambdaSyntax() {
    func add(a: Int) -> Int {
        return a + 1
    }
    let add1 = {(a: Int) -> Int in return a + 1}
    let add2 = {a in return a + 2}
    let add3 = {$0 + 3}
    
    print(add1(10))
    print(add2(10))
    print(add3(10))

}

// Map Journey

public func traditionalForLoop() {
    if let d = getItemsFromSystemProfiler(dataTypeString: "SPApplicationsDataType") {
        timeMe(label: "Traditional for loop"){
            var fora = [String?](repeating: nil, count: d.count)
            
            for n in 0..<(d.count) {
                if case let path as String = d[n]["path"] {
                    if let b = Bundle(path: path) {
                        fora[n] = b.bundleIdentifier
                    }
                }
            }
        }
    }
}

public func forInLoop() {
    if let d = getItemsFromSystemProfiler(dataTypeString: "SPApplicationsDataType") {

        timeMe(label: "For in loop") {
            var fora = [String?]()
            for appInfo in d {
                var id: String? = nil
                if case let path as String = appInfo["path"] {
                    if let b = Bundle(path: path) {
                        id = b.bundleIdentifier
                    }
                }
                fora.append(id)
            }
            print(fora.count)
        }
    }
}

public func enumeratedForIn() {
    if let d = getItemsFromSystemProfiler(dataTypeString: "SPApplicationsDataType") {
        timeMe(label: "Enumerated for loop pre allocated") {
            var fora = [String?](repeating: nil, count: d.count)
            for (n, appInfo) in d.enumerated() {
                if case let path as String = appInfo["path"] {
                    if let b = Bundle(path: path) {
                        fora[n] = b.bundleIdentifier
                    }
                }
            }
            print(fora.count)
        }
    }
}

public func mapExample() {
    if let d = getItemsFromSystemProfiler(dataTypeString: "SPApplicationsDataType") {
        var mapa: [String?] = []
        timeMe(label: "Map") {
            mapa = d.map{(appInfo) -> String? in
                if case let path as String = appInfo["path"] {
                    if let b = Bundle(path: path) {
                        return b.bundleIdentifier
                    }
                }
                return nil
            }
            print(mapa.count)
        }
    }
}

public func filterExample() {
    let ni = getItemsFromSystemProfiler(dataTypeString: "SPNetworkDataType")
    
    let inames = (ni ?? []).filter{
        return $0["ip_address"] != nil
    }
    
    for device in inames {
        
        print("\((device["interface"] as? String) ?? "NA")")
        
    }

}

public func firstInstall() {
    let installs = getItemsFromSystemProfiler(dataTypeString: "SPInstallHistoryDataType");
    var result = [String:Date]()
    
    for install in installs! {
        if let pkgName = install["_name"] as? String {
            if let pkgDate = install["install_date"] as? Date {
                if let currentDate = result[pkgName] {
                    result[pkgName] = (pkgDate.compare(currentDate) == ComparisonResult.orderedAscending) ? pkgDate : currentDate
                } else {
                    result[pkgName] = pkgDate;
                }
                
            }
        }
    }    
}

public func badReduceExample() {
    let installs = getItemsFromSystemProfiler(dataTypeString: "SPInstallHistoryDataType");
    let result = [String:Date]()
    
    
    let newest = installs?.reduce(result){(current, install) in
        var newResult = current
        guard let pkgName = install["_name" ] as? String  else {
            return current
        }
        guard let pkgDate = install["install_date"] as? Date else {
            return current
        }
        if let currentDate = current[pkgName] {
            newResult[pkgName] = (pkgDate.compare(currentDate) == ComparisonResult.orderedAscending) ? pkgDate : currentDate
        } else {
            newResult[pkgName] = pkgDate;
        }
        
        return newResult
    }
    print(newest ?? "No results")
}

public func reduceExample() {
    let psText = launchAndGetText(path: "/bin/ps", args: ["-A", "-o", "pcpu comm"])
    var psLines = psText.components(separatedBy: "\n").map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
    
    psLines.removeFirst()
    
    if(psLines.last == "") {
        psLines.removeLast()
    }

    let t = psLines.reduce(("", 0.0)) { (currentHog, potentialHog) -> (String, Double) in
        let firstSplit = potentialHog.characters.split(maxSplits: 1, omittingEmptySubsequences: true, whereSeparator: {$0 == " "}).map(String.init)
        
        if firstSplit.count == 2 {
            let pHogName = firstSplit[1]
            if let pHogVal = Double(firstSplit[0]) {
                if(pHogVal > currentHog.1) {
                    return (pHogName, pHogVal)
                }
            }
        }
        return currentHog
    }
    print(t)
}

public func mapThenReduce() {
    let psText = launchAndGetText(path: "/bin/ps", args: ["-A", "-o", "pcpu comm"])
    var psLines = psText.components(separatedBy: "\n").map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
    
    psLines.removeFirst()
    
    if(psLines.last == "") {
        psLines.removeLast()
    }
    let n = psLines.map(){(line) -> (String, Double) in
        let firstSplit = line.characters.split(maxSplits: 1, omittingEmptySubsequences: true, whereSeparator: {$0 == " "}).map(String.init)
        return (firstSplit[1], Double(firstSplit[0])!)
    }
    
    let t = n.reduce(("", 0.0)){
        if($0.1 > $1.1) {
            return $0
        } else {
            return $1
        }
    }
    print(t)
    print(n.sorted(by: {$0.1 > $1.1}).filter{$0.1 > 0.0})

}



