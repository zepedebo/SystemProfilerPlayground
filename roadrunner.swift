//
//  roadrunner.swift
//  
//
//  Created by Steve Goodrich on 8/15/16.
//
//

import Foundation

enum NavigationError: ErrorType {
    case Explode
    case Crash
    case Fall
}

struct Predator: Object {
    func attach(device: String, location: String) {
        // Strap it on
    }
    
    func navigate(feature: String) throws {
        
    }
    
    func capture(prey: Prey) {
        
    }
}

struct Prey: Object {
    
}

do {

    var coyote = Predator()
    var roadrunner = Prey()

    coyote.attach(device:"rocket", location: "back")
    coyote.attach(device:"roller skates", location: "feet")
    coyote.attach(device:"helmet", location: "head")

    try coyote.navigate(feature: "Sharp Turn")
    try coyote.navigate(feature: "Chasm")
    try coyote.navigate(feature: "Low Bridge")
    
    coyote.capture(prey: roadrunner)
} catch NavigationError.Explode {
    
} catch NavigationError.Crash {
    
} catch NavigationError.Fall {
    
}
