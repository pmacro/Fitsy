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
  
  init<T>(from value: T, encodingType: FitBaseType) where T: BinaryInteger {
    switch encodingType {
    case .byte:
      self.init(from: CChar(value))
    case .uint8:
      self.init(from: UInt8(value))
    case .uint16:
      self.init(from: UInt16(value))
    case .uint32:
      self.init(from: UInt32(value))
    case.uint64:
      self.init(from: UInt64(value))
    case .sint8:
      self.init(from: Int8(value))
    case .sint16:
      self.init(from: Int16(value))
    case .sint32:
      self.init(from: Int32(value))
    case .sint64:
      self.init(from: Int64(value))
    default:
      self.init(from: value)
    }
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
