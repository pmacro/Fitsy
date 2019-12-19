//
//  DeviceInfoMessage.swift
//  
//
//  Created by Paul MacRory on 26/11/2019.
//

import Foundation

public struct DeviceInfoMessage: FitMessage {
  public var size: Int
  
  public var timestamp: Date!
  public var serialNumber: UInt32?
  public var manufacturer: FitManufacturer?
  
  public var globalMessageNumber: MessageNumber = .deviceInfo
  
  public var localMessageNumber: CChar?
  
  public var data: Data {
    var result = Data(from: UInt32(timestamp.timeIntervalSinceFitBaseDate))
    
    if let serialNumber = serialNumber {
      result += Data(from: serialNumber)
    }
    
    if let manufacturer = manufacturer {
      result += Data(from: manufacturer.rawValue)
    }
    
    return result
  }
  
  public init(timestamp: Date, serialNumber: UInt32? = nil, manufacturer: FitManufacturer? = nil) {
    self.timestamp = timestamp
    self.serialNumber = serialNumber
    self.manufacturer = manufacturer
    
    self.size = MemoryLayout.size(ofValue: UInt32())
    
    if let serialNumber = serialNumber {
      self.size += MemoryLayout.size(ofValue: serialNumber)
    }
    
    if let manufacturer = manufacturer {
      self.size += MemoryLayout.size(ofValue: manufacturer.rawValue)
    }
  }
  
  public init?(data: Data,
               bytePosition: Int,
               fields: [MessageDefinition.Field],
               localMessageNumber: CChar) {
    self.localMessageNumber = localMessageNumber
    var offset = bytePosition
    
    for field in fields {

      switch field.number {
      case 253:
        guard let timestampInt = data[offset...].to(type: UInt32.self) else { return nil }
        self.timestamp = Date(timeIntervalSinceFitBaseDate: TimeInterval(timestampInt))
      case 2:
        guard let manufacturerInt = data[offset...].to(type: UInt16.self) else { break }
        self.manufacturer = FitManufacturer(rawValue: manufacturerInt)
      case 3:
        self.serialNumber = data[offset...].to(type: UInt32.self)
      default:
        break
      }
    
      offset += Int(field.size)
    }

    self.size = fields.totalFieldSize
  }
    
  public func generateMessageDefinition() -> MessageDefinition {
    var fields = [MessageDefinition.Field]()
    
    fields.append(MessageDefinition.Field(number: 253,
                                     size: UInt8(MemoryLayout.size(ofValue: UInt32())),
                                     baseType: FitBaseType.uint32.rawValue))
    
    if let serialNumber = serialNumber {
      fields.append(.init(number: 3,
                     size: UInt8(MemoryLayout.size(ofValue: serialNumber)),
                     baseType: FitBaseType.uint32.rawValue))
    }

    if let manufacturer = manufacturer {
      fields.append(.init(number: 2,
                      size: UInt8(MemoryLayout.size(ofValue: manufacturer.rawValue)),
                      baseType: FitBaseType.uint16.rawValue))
    }
                          
    return MessageDefinition(fields: fields,
                             localMessageType: localMessageNumber ?? -1,
                             globalMessageNumber: globalMessageNumber.rawValue)
  }
}
