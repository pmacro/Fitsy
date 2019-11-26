//
//  File.swift
//  
//
//  Created by Paul MacRory on 26/11/2019.
//

import Foundation

public protocol MessageDefinitionGenerator {
  func generateMessageDefinition() -> MessageDefinition
}

public struct MessageDefinition: FitFileEntity {
  public struct Field {
    let number: UInt8
    let size: UInt8
    let baseType: UInt8
  }
    
  public var fields: [Field] = []
  public let localMessageType: CChar
  public let globalMessageNumber: UInt16
  public let size: Int
  
  public var data: Data {
                             // Reserved byte.
    var result = Data(from: CChar(0))
                             // Little endian
               + Data(from: CChar(0x00))
               + Data(from: globalMessageNumber)
               + Data(from: UInt8(fields.count))
    
    for field in fields {
      result += Data(fromArray: [field.number, field.size, field.baseType])
    }
    
    return result
  }
  
  public init(fields: [Field],
              localMessageType: CChar,
              globalMessageNumber: UInt16) {
    self.fields = fields
    self.localMessageType = localMessageType
    self.globalMessageNumber = globalMessageNumber
    self.size = (fields.count * 3) + 2 + MemoryLayout.size(ofValue: globalMessageNumber)
  }
  
  public init?(data: Data, bytePosition: Int, headerByte: CChar) {
    var offset = bytePosition
        
    self.localMessageType = headerByte & MessageConstants.localMessageNumMask
    
    if localMessageType > MessageConstants.localMessageNumMask {
      print("Invalid message type: \(localMessageType)")
      return nil
    }
    
    // The next byte is reserved, so skip over it.
    offset += 1
    
    let byteOrder = data[offset...].to(type: CChar.self)
    let littleEndian = byteOrder == 0x00 // bigEndian is 0x01
    offset += 1
    
    guard let globalMessageNumber = data[offset...].to(type: UInt16.self) else { return nil }
    self.globalMessageNumber = littleEndian ? globalMessageNumber.littleEndian
                                            : globalMessageNumber.bigEndian
    offset += MemoryLayout.size(ofValue: globalMessageNumber)
    
    guard let numberOfFields = data[offset...].to(type: CChar.self), numberOfFields > 0 else {
      return nil
    }
    
    offset += 1
        
    for _ in 0..<numberOfFields {
      guard let num = data[offset...].to(type: UInt8.self) else { return nil }
      offset += 1
      guard let size = data[offset...].to(type: UInt8.self) else { return nil }
      offset += 1
      guard let bType = data[offset...].to(type: UInt8.self) else { return nil }
      offset += 1
      
      fields.append(Field(number: num, size: size, baseType: bType))
    }
    
    size = offset - bytePosition
  }
}

extension Array where Element == MessageDefinition.Field {
  var totalFieldSize: Int { self.reduce(0, { $0 + Int($1.size) }) }
}
