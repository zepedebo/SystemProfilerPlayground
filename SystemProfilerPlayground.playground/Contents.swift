//: Playground - noun: a place where people can play

import Cocoa

let lsTask = Task()
let wcTask = Task()

wcTask.launchPath = "/usr/bin/wc"
lsTask.launchPath = "/bin/ls"
let lsOutPipe = Pipe()
let wcOutPipe = Pipe()
lsTask.standardOutput = lsOutPipe
wcTask.standardInput = lsOutPipe
wcTask.arguments = ["-l"]
wcTask.standardOutput = wcOutPipe
lsTask.arguments = ["/Users/steveg"]
lsTask.launch()
wcTask.launch()
lsTask.waitUntilExit()
wcTask.waitUntilExit()

let data = wcOutPipe.fileHandleForReading.readDataToEndOfFile()
let stringData = String(data: data, encoding: String.Encoding.utf8)

print("File count = \(stringData?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))")

let i = Int("  23".trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
let f = Float("10.12")

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
        
        
        let a = dict as? NSArray
        let d = a?[0] as? NSDictionary
    
    if let q = (dict as? NSArray)?[0] as? NSDictionary {
        
    }
    
        if let n = d?["_items"] as? NSArray {
            systemProfilerInfo = (n as! Array<NSDictionary>) as Array<NSDictionary>?
        } else {
            systemProfilerInfo = nil
        }
    return systemProfilerInfo
}

/*
extension Array {
    public func pmap<T>(transform: ((Element) -> T)) -> [T] {
        guard !self.isEmpty else {
            return []
        }
        
        var result: [(Int, [T])] = []
        
        let group = DispatchGroup()
        let lock = DispatchQueue(label: "pmap queue for result") // dispatch_queue_create("pmap queue for result", DISPATCH_QUEUE_SERIAL)
        let possibleStep = (self.count / ProcessInfo.processInfo.activeProcessorCount)
        
        let step: Int = possibleStep == 0 ? 1 : possibleStep // step can never be 0
        
        var stepIndex = 0
        while stepIndex * step < self.count {
            let capturedStepIndex = stepIndex
            
            var stepResult: [T] = []
            dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                for i in (capturedStepIndex * step)..<((capturedStepIndex + 1) * step) {
                    if i < self.count {
                        let mappedElement = transform(self[i])
                        stepResult += [mappedElement]
                    }
                }
                
                dispatch_group_async(group, lock) {
                    result += [(capturedStepIndex, stepResult)]
                }
            }
            stepIndex += 1
        }
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
        
        return result.sort { $0.0 < $1.0 }.flatMap { $0.1 }
    }
}
*/

