//
//  File.swift
//  
//
//  Created by Paul MacRory on 21/11/2019.
//

import Foundation

extension Data {

    init<T>(from value: T) {
      self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }

    func to<T>(type: T.Type) -> T? where T: ExpressibleByIntegerLiteral {
      var value: T = 0
      guard count >= MemoryLayout.size(ofValue: value) else { return nil }
      _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
      return value
    }
}

extension Data {
    init<T>(fromArray values: [T]) {
      self = values.withUnsafeBytes { Data($0) }
    }

    func toArray<T>(type: T.Type) -> [T] where T: ExpressibleByIntegerLiteral {
      var array = Array<T>(repeating: 0, count: self.count/MemoryLayout<T>.stride)
      _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
      return array
    }
}
