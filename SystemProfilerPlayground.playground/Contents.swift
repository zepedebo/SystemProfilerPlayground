//: Playground - noun: a place where people can play

import Cocoa

//Simple()

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
        print(fora.count)
    }
    
    
    
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
    
    var mapa: [String?] = []
    timeMe(label: "Map") {
        mapa = d.pmap{(appInfo) -> String? in
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



//let ps = Process()
//let psStdOut = Pipe()
//ps.launchPath = "/bin/ps"
//ps.arguments = ["-A", "-o", "pcpu comm"]
//ps.standardOutput = psStdOut
//ps.launch()
//ps.waitUntilExit()
//let psData = psStdOut.fileHandleForReading.readDataToEndOfFile()
//let psText = String(data: psData, encoding: String.Encoding.utf8)


//
//// NSArray to Array is toll free. NSDictionary to Dictionary is not but that's OK. They work the same.
///
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
