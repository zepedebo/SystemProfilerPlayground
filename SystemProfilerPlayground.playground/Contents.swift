//: Playground - noun: a place where people can play

import Cocoa

func timeMe(label: String, code :(Void) -> Void ) {
    let fortimeAtStart = Date()
    code()
    let forelapsedtime = Date().timeIntervalSince(fortimeAtStart)
    print("\(label): \(forelapsedtime)")

}

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
//    print("\(lsText)")
    let contents = lsText.components(separatedBy: "\n")
    let fullPaths = contents.map(){(a) -> String in firstTask.currentDirectoryPath+"/"+a}
    // let fullPaths = contents.map(){firstTask.currentDirectoryPath+"/"+$0}

//    print("\(fullPaths)")
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
let d = getItemsFromSystemProfiler(dataTypeString: "SPApplicationsDataType")
print("\(d?.count)")

var fora = [String](repeating: "", count: d!.count)

timeMe(label: "Traditional for loop"){
//for swp in d! {
for n in 0..<d!.count {
    if let path = d?[n]["path"] {
        let fullpath = "\(path)/Contents/Info.plist"
        NSDictionary(contentsOfFile: fullpath)?["CFBundleIdentifier"]  ?? ""
    }
}
}
//let fortimeAtStart = Date()

//var fora = [String]()
//for swp in d! {
//    if let path = swp["path"] {
//        let fullpath = "\(path)/Contents/Info.plist"
//        if case let info as String = NSDictionary(contentsOfFile: fullpath)?["CFBundleIdentifier"] {
//            fora.append(info)
////            print("\(info)")
//        } else {
//            print(fullpath)
//            fora.append("")
//        }
//    }
//}
// let forelapsedtime = Date().timeIntervalSince(fortimeAtStart)
// print("\(forelapsedtime)")

timeMe(label: "Enumerated for loop"){
    //for swp in d! {
    for (n, path) in (d?.enumerated())! {
        if let path = d?[n]["path"] {
            let fullpath = "\(path)/Contents/Info.plist"
            if case let info as String = NSDictionary(contentsOfFile: fullpath)?["CFBundleIdentifier"] {
                fora[n] = info
                //            print("\(info)")
            } else {
                fora[n] = ""
            }
        }
    }
}

var mapa: [String] = []
timeMe(label: "Map") {mapa = d!.map{(swp) -> String in
    if let path = swp["path"] {
        let fullpath = "\(path)/Contents/Info.plist"
        if let info = NSDictionary(contentsOfFile: fullpath)?["CFBundleIdentifier"] {
//            print("\(info)")
            return   info as! String
        }

    }
    return ""
}
}

//if mapa.count != fora.count {
//    print("not equal \(mapa.count), \(fora.count)")
//}
//if mapa == fora {
//    print("equal")
//}


print(mapa.count)

let id = ["one": 1, "two": 2, "three": 3]

let r = id.reduce([String: Int]()){m, k in

    var result = m
    result[k.key] = k.value + 1
    return result
}


// Tuples as ad hoc structures

let t = (name: "add", op: {$0 + 1})
t.op(5)

var x = 10, y = 20
(x,y) = (y,x)

let a = [Int](1...100)
func square(_ a: Int) -> Int {return a * a;}
let m = square( 2)
let s = a.map(square).filter(){($0 & 1) == 0}.reduce(0){$0+$1}
print("\(s)")

let so: Int? = Int("100s")
if case .some(let x) = so {
    print(x)
} else {
    print("nan")
}
