import Foundation


// Based on code from http://moreindirection.blogspot.com/2015/07/gcd-and-parallel-collections-in-swift.html

func slices<T>(_ a: [T], size: Int) -> [ArraySlice<T>] {
    let sliceCount: Int = Int(ceil(Double(a.count)/Double(size)))
    var result = [ArraySlice<T>](repeating: [], count: sliceCount)
    
    for n in 0..<sliceCount {
        result[n] = a.suffix(from: n*size).prefix(size)
        //        result[n] = a[n*size...(n+1)*size]
    }
    
    return result
}


func slices<T>(_ a: [T], count: Int) -> [ArraySlice<T>] {
    let size = ceil(Double(a.count) / Double(count));
    return slices(a, size: Int(size))
}

public extension Array {
    public func pmap<T>(transform: @escaping ((Element) -> T)) -> [T] {
        guard !self.isEmpty else {
            return []
        }
        let potentialStep = /*self.count / */ ProcessInfo.processInfo.activeProcessorCount
        let step: Int = (potentialStep > 1) ? potentialStep : 1// step can never be 0
        
        let workSlices = slices(self, count: step)
        var result: [(Int, [T])] = [(Int, [T])](repeating:(0, []), count: workSlices.count)
        
        let group = DispatchGroup()
        //        let lock = DispatchQueue(label:"pmap queue for result" )
        let assemblyQueue = DispatchQueue(label: "com.mt.assembly")
        for (i, slice) in workSlices.enumerated() {
            DispatchQueue.global().async(group: group) {
                let t = (slice.startIndex, slice.map(transform))
                assemblyQueue.sync {
                    result[i] = t
                }
            }
        }
        group.wait()
        
        return result.sorted { $0.0 < $1.0 }.flatMap { $0.1 }
    }
}
