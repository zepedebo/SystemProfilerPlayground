// Running system tools with Swift

import Foundation

//--------------------------------------------------
// Simplest example

//let lsProc = Process()
//let lsStdout = Pipe()
//lsProc.launchPath = "/bin/ls"
//lsProc.arguments = ["-l"]
//lsProc.standardOutput = lsStdout
//
//lsProc.launch()
//lsProc.waitUntilExit()
//let lsResultData = lsStdout
//    .fileHandleForReading
//    .readDataToEndOfFile();
//let lsResultText = String(data: lsResultData,
//                          encoding: String.Encoding.utf8)
//print(lsResultText ?? "No results")
//

// An array
let a1 : Array<Int> = [1, 2, 3]
let a2 : [Int] = [1,2,3]

// A dictionary
let d1 : Dictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
let d2 : [String: Int] = ["one": 1, "two": 2, "three": 3]

//---------------------------------------------------
// GetUUID text

//let spProc = Process()
//
//spProc.launchPath = "/usr/sbin/system_profiler"
//spProc.arguments = ["SPHardwareDataType"]
//
//let pipe = Pipe()
//spProc.standardOutput = pipe
//
//spProc.launch()
//spProc.waitUntilExit()
//
//let spData = pipe.fileHandleForReading.readDataToEndOfFile()
//let spText = String(data:spData, encoding: String.Encoding.utf8)
//
//if let lines = spText?.components(separatedBy: "\n") {
//    for line in lines {
//        let parts = line.components(separatedBy: ":")
//        if parts.count > 1 && parts[0].contains("Hardware UUID") {
//            print(parts[1])
//        }
//    }
//}


//---------------------------------------------------
// GetUUID .plist (AKA XML)

//let spProc = Process()
//let pipe = Pipe()
//
//spProc.launchPath = "/usr/sbin/system_profiler"
//spProc.arguments = ["-xml", "SPHardwareDataType"]
//
//spProc.standardOutput = pipe
//
//spProc.launch()
//spProc.waitUntilExit()
//
//let spData = pipe.fileHandleForReading.readDataToEndOfFile()
//let dict: AnyObject? = try? PropertyListSerialization
//    .propertyList(from: spData, options: [], format: nil) as AnyObject
//
//if let hardwareInfo = (dict as! NSArray)[0] as? [String: AnyObject] {
//    let items = (hardwareInfo["_items"] as! [AnyObject])[0]
//    if let result = (items as! [String: AnyObject])["platform_UUID"] as? String {
//        print( result)
//    }
//}


// Lambda Syntax
//let incLong = {(a: Int) -> Int in return a + 1}
//let incShorter = {a in return a + 1}
//let incShortest = {$0 + 1}
//
//print(incLong(10))
//print(incShorter(10))
//print(incShortest(10))

// Get a list of bundle identifiers for all the installed applications
//if let d = getItemsFromSystemProfiler(dataTypeString: "SPApplicationsDataType") {
//    
//    timeMe(label: "Traditional for loop"){
//        var fora = [String?](repeating: nil, count: d.count)
//        
//        for n in 0..<(d.count) {
//            if case let path as String = d[n]["path"] {
//                if let b = Bundle(path: path) {
//                    fora[n] = b.bundleIdentifier
//                }
//            }
//        }
//    }
//    
//    timeMe(label: "For in loop") {
//        var fora = [String?]()
//        for appInfo in d {
//            var id: String? = nil
//            if case let path as String = appInfo["path"] {
//                if let b = Bundle(path: path) {
//                    id = b.bundleIdentifier
//                }
//            }
//            fora.append(id)
//        }
//    }
//    
//    timeMe(label: "Enumerated for loop pre allocated") {
//        var fora = [String?](repeating: nil, count: d.count)
//        for (n, appInfo) in d.enumerated() {
//            if case let path as String = appInfo["path"] {
//                if let b = Bundle(path: path) {
//                    fora[n] = b.bundleIdentifier
//                }
//            }
//        }
//    }
//    
//    var mapa: [String?] = []
//    timeMe(label: "Map") {
//        mapa = d.map{(appInfo) -> String? in
//            if case let path as String = appInfo["path"] {
//                if let b = Bundle(path: path) {
//                    return b.bundleIdentifier
//                }
//            }
//            return nil
//        }
//    }
//}

//////////////////////
//// Filter Example //
//////////////////////

//let ni = getItemsFromSystemProfiler(dataTypeString: "SPNetworkDataType")
//
//let inames = (ni ?? []).filter{(a) -> Bool in
//    return a["ip_address"] != nil
//}
//
//for device in inames {
//    
//    print("\((device["interface"] as? String) ?? "NA")")
//    
//}

//: Bad Reduce Example
//let installs = getItemsFromSystemProfiler(dataTypeString: "SPInstallHistoryDataType");
//let result = [String:Date]()
//
//
//let newest = installs?.reduce(result){(current, install) in
//    var newResult = current
//    guard let pkgName = install["_name" ] as? String  else {
//        return current
//    }
//    guard let pkgDate = install["install_date"] as? Date else {
//        return current
//    }
//    if let currentDate = current[pkgName] {
//        newResult[pkgName] = (pkgDate.compare(currentDate) == ComparisonResult.orderedAscending) ? pkgDate : currentDate
//    } else {
//        newResult[pkgName] = pkgDate;
//    }
//    
//    return newResult
//}
//print(newest ?? "No results")
//

///////////////////////////
//// Good Reduce Example //
///////////////////////////

//          /bin/ps -A -o "pcpu comm"

//let psText = launchAndGetText(path: "/bin/ps", args: ["-A", "-o", "pcpu comm"])
//var psLines = psText.components(separatedBy: "\n").map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
//
//psLines.removeFirst()
//
//if(psLines.last == "") {
//    psLines.removeLast()
//}
//
//let t = psLines.reduce(("", 0.0)) { (currentHog, potentialHog) -> (String, Double) in
//    let firstSplit = potentialHog.characters.split(maxSplits: 1, omittingEmptySubsequences: true, whereSeparator: {$0 == " "}).map(String.init)
//    
//    if firstSplit.count == 2 {
//        let pHogName = firstSplit[1]
//        if let pHogVal = Double(firstSplit[0]) {
//            if(pHogVal > currentHog.1) {
//                return (pHogName, pHogVal)
//            }
//        }
//    }
//    return currentHog
//}
//print(t)




//--------------------- Ignore the stuff below this --------------------------------------
//let p = getItemsFromSystemProfiler(dataTypeString: "SPConfigurationProfileDataType")

//for n in p {
//    print (n)
//}

//if let p = getItemsFromSystemProfiler(dataTypeString: "SPConfigurationProfileDataType") {
//    for i in p {
//        print(i["_name"] ?? "Something is very wrong")
//
//        if let i2 = i["_items"] as? [[NSString: AnyObject]] {
//            for q in i2 {
//                let m = Mirror(reflecting: q)
//                print (m)
//                for (key, val) in q {
//                    print("key = \(key), val = \(val)")
//                }
//            }
//        }
//    }
//} else {
//    print("bad p")
//}
