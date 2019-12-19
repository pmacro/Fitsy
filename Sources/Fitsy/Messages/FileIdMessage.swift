//
//  FileIdMessage.swift
//  
//
//  Created by Paul MacRory on 26/11/2019.
//

import Foundation

public struct FileIdMessage: Equatable, FitMessage {
  public var type: FileType!
  public var manufacturer: UInt16!
  public var product: UInt16!
  public var serialNumber: UInt32!
  public var timeCreated: Date!
  public var size: Int = 0
  
  public var globalMessageNumber: MessageNumber { .fileId }
  public var localMessageNumber: CChar?
  
  public var data: Data {
    let typeData = Data(from: Int8(type.rawValue))
    let manufacturerData = Data(from: manufacturer)
    let productData = Data(from: product)
    let serialNumberData = Data(from: serialNumber)
    let timeCreatedData = Data(from: UInt32(timeCreated.timeIntervalSinceFitBaseDate))
    
    return typeData
           + manufacturerData
           + productData
           + serialNumberData
           + timeCreatedData
  }
  
  public init(type: FileType,
              manufacturer: FitManufacturer,
              product: UInt16,
              serialNumber: UInt32,
              timeCreated: Date) {
    self.type = type
    self.manufacturer = manufacturer.rawValue
    self.product = product
    self.serialNumber = serialNumber
    self.timeCreated = timeCreated
    self.localMessageNumber = 0
    
    self.size = MemoryLayout.size(ofValue: UInt8(type.rawValue))
              + MemoryLayout.size(ofValue: manufacturer)
              + MemoryLayout.size(ofValue: product)
              + MemoryLayout.size(ofValue: serialNumber)
              // timeCreated is stored as UInt32, not Date.
              + MemoryLayout.size(ofValue: UInt32())
  }
  
  public init?(data: Data, bytePosition: Int, fields: [MessageDefinition.Field], localMessageNumber: CChar) {
    self.localMessageNumber = localMessageNumber
    var offset = bytePosition
    
    for field in fields {
      switch field.number {
      case 0:
        guard let typeInt = data[offset...].to(type: CChar.self),
              let type = FileType(rawValue: Int(typeInt)) else { return nil }
        self.type = type
        
      case 1:
        guard let manufacturer = data[offset...].to(type: UInt16.self) else { return nil }
        self.manufacturer = manufacturer
        
      case 2:
        guard let product = data[offset...].to(type: UInt16.self) else { return nil }
        self.product = product
        
      case 3:
        guard let serialNumber = data[offset...].to(type: UInt32.self) else { return nil }
        self.serialNumber = serialNumber
        
      case 4:
        guard let timeCreated = data[offset...].to(type: UInt32.self) else { return nil }
        self.timeCreated = Date(timeIntervalSinceFitBaseDate: TimeInterval(timeCreated))
        
      default:
        print("Unexpected field found.")
      }
      offset += Int(field.size)
    }
    
    self.size = offset - bytePosition
  }
  
  public func generateMessageDefinition() -> MessageDefinition {
    MessageDefinition(fields: [.init(number: 0,
                                     size: UInt8(MemoryLayout.size(ofValue: UInt8(type.rawValue))),
                                     baseType: FitBaseType.uint8.rawValue),
                               .init(number: 1,
                                     size: UInt8(MemoryLayout.size(ofValue: manufacturer)),
                                     baseType: FitBaseType.uint16.rawValue),
                               .init(number: 2,
                                     size: UInt8(MemoryLayout.size(ofValue: product)),
                                     baseType: FitBaseType.uint16.rawValue),
                               .init(number: 3,
                                     size: UInt8(MemoryLayout.size(ofValue: serialNumber)),
                                     baseType: FitBaseType.uint32.rawValue),
                               .init(number: 4,
                                     size: 4,
                                     baseType: FitBaseType.uint32.rawValue)
                              ],
                      localMessageType: localMessageNumber ?? -1,
                      globalMessageNumber: MessageNumber.fileId.rawValue)
  }
}
