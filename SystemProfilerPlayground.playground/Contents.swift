//: Playground - noun: a place where people can play

import Cocoa

//Simple()

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

print("\([1,2,3,4,5].reduce(0){(sum, current) in return sum + current})")



//let ps = Process()
//let psStdOut = Pipe()
//ps.launchPath = "/bin/ps"
//ps.arguments = ["-A", "-o", "pcpu comm"]
//ps.standardOutput = psStdOut
//ps.launch()
//ps.waitUntilExit()
//let psData = psStdOut.fileHandleForReading.readDataToEndOfFile()
//let psText = String(data: psData, encoding: String.Encoding.utf8)

timeMe(label: "Good reduce", code: {reduceExample()})

timeMe(label: "Map then reduce") {
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
}

//print(n.sorted(by: {$0.1 > $1.1}).filter{$0.1 > 0.0})


//// Dealing with some results
//let i = Int("  23".trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
//let f = Float("10.12")
//
//// Collection.map() demo
//let firstTask = Process()
//let stdout = Pipe()
//firstTask.standardOutput = stdout
//firstTask.launchPath = "/bin/ls"
//firstTask.currentDirectoryPath = "/Users/steveg"
//firstTask.launch()
//firstTask.waitUntilExit()
//
//let lsData = stdout.fileHandleForReading.readDataToEndOfFile()
//if let lsText = String(data: lsData, encoding: String.Encoding.utf8) {
//    let contents = lsText.components(separatedBy: "\n")
//    let fullPaths = contents.map(){(a: String) -> String in firstTask.currentDirectoryPath+"/"+a}
//    print("\(fullPaths)")
//    // let fullPaths = contents.map(){firstTask.currentDirectoryPath+"/"+$0}
//}
//
//let q = String("2a3a5".characters.filter({$0 >= "0" && $0 <= "9"}))
//print("\(Int(q)!)")
//
//let newest = installs?.reduce(result){(newResult, install) in
//    guard let pkgName = install["_name" ] as? String  else {
//        return newResult
//    }
//    guard let pkgDate = install["install_date"] as? Date else {
//        return newResult
//    }
//    if let currentDate = newResult[pkgName] {
//        newResult[pkgName] = (pkgDate.compare(currentDate) == ComparisonResult.orderedAscending) ? pkgDate : currentDate
//    } else {
//        newResult[pkgName] = pkgDate;
//    }
//
//    return newResult
//}

//print(newest)

//
//// NSArray to Array is toll free. NSDictionary to Dictionary is not but that's OK. They work the same.
//let d = getItemsFromSystemProfiler(dataTypeString: "SPApplicationsDataType")
//print("\(d?.count)")
//
//var fora = [String](repeating: "", count: d!.count)
//
//timeMe(label: "Traditional for loop"){
//    for n in 0..<d!.count {
//        if let path = d?[n]["path"] {
//            let fullpath = "\(path)/Contents/Info.plist"
//            NSDictionary(contentsOfFile: fullpath)?["CFBundleIdentifier"]  ?? ""
//        }
//    }
//}
//
//timeMe(label: "For in loop") {
//    var fora = [String]()
//    for swp in d! {
//        if let path = swp["path"] {
//            let fullpath = "\(path)/Contents/Info.plist"
//            if case let info as String = NSDictionary(contentsOfFile: fullpath)?["CFBundleIdentifier"] {
//                fora.append(info)
//    //            print("\(info)")
//            } else {
//                fora.append("")
//            }
//        }
//    }
//}
//
//
//timeMe(label: "Enumerated for loop pre allocated"){
//    for (n, path) in (d?.enumerated())! {
//        if let path = d?[n]["path"] {
//            let fullpath = "\(path)/Contents/Info.plist"
//            if case let info as String = NSDictionary(contentsOfFile: fullpath)?["CFBundleIdentifier"] {
//                fora[n] = info
//                //            print("\(info)")
//            } else {
//                fora[n] = ""
//            }
//        }
//    }
//}
//
//var mapa: [String] = []
//timeMe(label: "Map") {mapa = d!.pmap{(swp) -> String in
//        if let path = swp["path"] {
//            let fullpath = "\(path)/Contents/Info.plist"
//            if let info = NSDictionary(contentsOfFile: fullpath)?["CFBundleIdentifier"] {
//                return   info as! String
//            }
//
//        }
//        return ""
//    }
//}
//
//
//let add1 = {(a: Int) -> Int in return a + 1}
//let add2 = {a in return a + 2}
//let add3 = {$0 + 3}
//
//add1(10)
//add2(10)
//add3(10)
//
////if mapa.count != fora.count {
////    print("not equal \(mapa.count), \(fora.count)")
////}
////if mapa == fora {
////    print("equal")
////}
//
//
//print(mapa.count)
//
//let id = ["one": 1, "two": 2, "three": 3]
//
//let r = id.reduce([String: Int]()){m, k in
//
//    var result = m
//    result[k.key] = k.value + 1
//    return result
//}
//
//
//// Tuples as ad hoc structures
//
//let t = (name: "add", op: {$0 + 1})
//t.op(5)
//
//var x = 10, y = 20
//(x,y) = (y,x)
//
//let a = [Int](1...100)
//func square(_ a: Int) -> Int {return a * a;}
//let m = square( 2)
//let s = a.map(square).filter(){($0 & 1) == 0}.reduce(0){$0+$1}
//print("\(s)")
//
//let so: Int? = Int("100s")
//if case .some(let x) = so {
//    print(x)
//} else {
//    print("nan")
//}
//
//
//
//
//
//
