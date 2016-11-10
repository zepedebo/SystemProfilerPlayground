//: Playground - noun: a place where people can play

import Cocoa



























////////////////////////////////
//// Extended Process Example //
////////////////////////////////
//
//let wcProc = Process()
//let wcStdout = Pipe()
//wcProc.launchPath = "/usr/bin/wc"
//wcProc.arguments = ["-l"]
//wcProc.standardInput = lsStdout
//wcProc.standardOutput = wcStdout
//
//// NOTE: launch throws an exception on bad input but it is an Objective-C exception. Swift won't catch it
//// see http://stackoverflow.com/questions/32758811/catching-nsexception-in-swift
//
//guard FileManager.default.fileExists(atPath: lsProc.launchPath!) && FileManager.default.fileExists(atPath: wcProc.launchPath!) else
//{
//    print("Missing executable")
//    exit(0)
//}
//
//lsProc.launch()
//wcProc.launch()
//
//
//lsProc.waitUntilExit()
//wcProc.waitUntilExit()
//
//print("ls terminated with \(lsProc.terminationStatus), wc terminated with \(wcProc.terminationStatus)")
//
//let data = wcStdout.fileHandleForReading.readDataToEndOfFile()
//let stringData = String(data: data, encoding: String.Encoding.utf8)
//
//print("File count = \(stringData?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))")



























//----------------------------------------------------------------------
///////////////////////////////////
//// Hardware UUID example start //
///////////////////////////////////
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

//// Find the UUID

//// Convert to XML


//public func getItemsFromSystemProfiler2(dataTypeString: String) -> Array<Dictionary<String, AnyObject>>? {
//    let task = Process()
//    
//    
//    task.launchPath = "/usr/sbin/system_profiler"
//    task.arguments = ["-xml", dataTypeString]
//    
//    
//    let pipe = Pipe()
//    task.standardOutput = pipe
//    
//    task.launch()
//    
//    let data = pipe.fileHandleForReading.readDataToEndOfFile()
//    let dict: AnyObject = try! PropertyListSerialization.propertyList(from: data, options: [], format: nil) as AnyObject
//    
//    
//    guard let a = dict as? Array<AnyObject> else {
//        return nil
//    }
//    
//    guard let d = a[0] as? Dictionary<String, AnyObject> else {
//        return nil
//    }
//    
//    return (d["_items"] as? Array<Dictionary<String, AnyObject>>)
//    
//}

//if let d = getItemsFromSystemProfiler(dataTypeString: "SPApplicationsDataType") {
//    
////    timeMe(label: "Traditional for loop"){
////        var fora = [String?](repeating: nil, count: d.count)
////        
////        for n in 0..<(d.count) {
////            if case let path as String = d[n]["path"] {
////                if let b = Bundle(path: path) {
////                    fora[n] = b.bundleIdentifier
////                }
////            }
////        }
////    }
////
////    timeMe(label: "For in loop") {
////        var fora = [String?]()
////        for appInfo in d {
////            var id: String? = nil
////            if case let path as String = appInfo["path"] {
////                if let b = Bundle(path: path) {
////                    id = b.bundleIdentifier
////                }
////            }
////            fora.append(id)
////        }
////    }
////    
////    timeMe(label: "Enumerated for loop pre allocated") {
////        var fora = [String?](repeating: nil, count: d.count)
////        for (n, appInfo) in d.enumerated() {
////            if case let path as String = appInfo["path"] {
////                if let b = Bundle(path: path) {
////                    fora[n] = b.bundleIdentifier
////                }
////            }
////        }
////    }
////    
////    var mapa: [String?] = []
////    timeMe(label: "Map") {
////        mapa = d.pmap{(appInfo) -> String? in
////            if case let path as String = appInfo["path"] {
////                if let b = Bundle(path: path) {
////                    return b.bundleIdentifier
////                }
////            }
////            return nil
////        }
////    }
//}

/////////////////////
//// Lambda Syntax //
/////////////////////
//let add1 = {(a: Int) -> Int in return a + 1}
//let add2 = {a in return a + 2}
//let add3 = {$0 + 3}
//
//print(add1(10))
//print(add2(10))
//print(add3(10))

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

//////////////////////////
//// Bad Reduce Example //
//////////////////////////

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


///////////////////////////
//// Good Reduce Example //
///////////////////////////


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
//
