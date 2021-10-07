//
//  ObjectConvertible.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/6/21.
//
// From code found at https://nicolasbichon.com/creating-an-abstraction-layer-for-the-model/

import Foundation

// protocol to be implemented by and NSObjects objects that will be converted to NSManagedObject
protocol ObjectConvertible {
    // to be set in toObject of ManagedObjectConvertible, represents the NSManagedObjectID for a NSManagedObject
    var identifier: String? { get }
}
