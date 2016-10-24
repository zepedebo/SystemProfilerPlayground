import Foundation

public func timeMe(label: String, code :(Void) -> Void ) {
    let fortimeAtStart = Date()
    code()
    let forelapsedtime = Date().timeIntervalSince(fortimeAtStart)
    print("\(label): \(forelapsedtime)")
    
}

public extension Array {
    public func slowpmap<T>(transform: @escaping ((Element) -> T)) -> [T] {
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

