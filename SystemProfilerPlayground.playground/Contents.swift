//: Playground - noun: a place where people can play

import Cocoa

func timeMe(label: String, code :(Void) -> Void ) {
    let fortimeAtStart = Date()
    code()
    let forelapsedtime = Date().timeIntervalSince(fortimeAtStart)
    print("\(label): \(forelapsedtime)")

}

extension Array {
    public func pmap<T>(transform: @escaping ((Element) -> T)) -> [T] {
        guard !self.isEmpty else {
            return []
        }
        
        var result: [(Int, [T])] = []
        
        let group = DispatchGroup()
        let lock = DispatchQueue(label:"pmap queue for result" )// dispatch_queue_create("pmap queue for result", DISPATCH_QUEUE_SERIAL)
        
        let potentialStep = self.count / ProcessInfo.processInfo.activeProcessorCount
        let step: Int = (potentialStep > 1) ? potentialStep : 1// step can never be 0
        
        //        for var stepIndex = 0; stepIndex * step < self.count; stepIndex += 1 {
        var stepIndex = 0
        while stepIndex * step < self.count {
            let capturedStepIndex = stepIndex
            
            var stepResult: [T] = []
            DispatchQueue.global().async(group: group) {
                for i in (capturedStepIndex * step)..<((capturedStepIndex + 1) * step) {
                    if i < self.count {
                        let mappedElement = transform(self[i])
                        stepResult += [mappedElement]
                    }
                }
                
                lock.async(group: group) {
                    result += [(capturedStepIndex, stepResult)]
                }
            }
            stepIndex += 1
        }
        group.wait()
        
        //        dispatch_group_wait(group, DispatchTime.distantFuture)
        
        return result.sorted { $0.0 < $1.0 }.flatMap { $0.1 }
    }
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
    let contents = lsText.components(separatedBy: "\n")
    let fullPaths = contents.map(){(a: String) -> String in firstTask.currentDirectoryPath+"/"+a}
    print("\(fullPaths)")
    // let fullPaths = contents.map(){firstTask.currentDirectoryPath+"/"+$0}
}

let q = String("2a3a5".characters.filter({$0 >= "0" && $0 <= "9"}))
print("\(Int(q)!)")

func getItemsFromSystemProfiler(dataTypeString: String) -> Array<NSDictionary>? {
    let task = Process()

    var systemProfilerInfo: Array<NSDictionary>? = nil

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
    for n in 0..<d!.count {
        if let path = d?[n]["path"] {
            let fullpath = "\(path)/Contents/Info.plist"
            NSDictionary(contentsOfFile: fullpath)?["CFBundleIdentifier"]  ?? ""
        }
    }
}

timeMe(label: "For in loop") {
    var fora = [String]()
    for swp in d! {
        if let path = swp["path"] {
            let fullpath = "\(path)/Contents/Info.plist"
            if case let info as String = NSDictionary(contentsOfFile: fullpath)?["CFBundleIdentifier"] {
                fora.append(info)
    //            print("\(info)")
            } else {
                fora.append("")
            }
        }
    }
}


timeMe(label: "Enumerated for loop pre allocated"){
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
timeMe(label: "Map") {mapa = d!.pmap{(swp) -> String in
        if let path = swp["path"] {
            let fullpath = "\(path)/Contents/Info.plist"
            if let info = NSDictionary(contentsOfFile: fullpath)?["CFBundleIdentifier"] {
                return   info as! String
            }

        }
        return ""
    }
}


let add1 = {(a: Int) -> Int in return a + 1}
let add2 = {a in return a + 2}
let add3 = {$0 + 3}

add1(10)
add2(10)
add3(10)

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






