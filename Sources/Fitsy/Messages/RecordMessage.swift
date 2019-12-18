//
//  RecordMessage.swift
//  
//
//  Created by Paul MacRory on 26/11/2019.
//

import Foundation

public struct RecordMessage: FitMessage {
  public var size: Int
  public var timestamp: Date!
  public var latitude: Double?
  public var longitude: Double?
  public var distance: UInt32?
  public var speed: UInt16?
  public var heartRate: UInt8?
  public var cadence: UInt8?
  public var altitude: Int16?
  public var totalCycles: UInt32?
  
  public var data: Data {
    var result = Data(from: UInt32(timestamp.timeIntervalSinceReferenceDate))
    
    if let latitude = latitude {
      result += Data(from: latitude.degreesToSemiCircles)
    }
    
    if let longitude = longitude {
      result += Data(from: longitude.degreesToSemiCircles)
    }

    if let distance = distance {
      result += Data(from: distance)
    }
    
    if let speed = speed {
      result += Data(from: speed)
    }
    
    if let totalCycles = totalCycles {
      result += Data(from: totalCycles)
    }

    if let altitude = altitude {
      result += Data(from: (altitude + 500) * 5)
    }
    
    if let heartRate = heartRate {
      result += Data(from: heartRate)
    }

    if let cadence = cadence {
      result += Data(from: cadence)
    }
    
    return result
  }
  
  public var globalMessageNumber: MessageNumber { .record }
  public var localMessageNumber: CChar?
  
  public init(timestamp: Date,
              latitude: Double? = nil,
              longitude: Double? = nil,
              distance: UInt32? = nil,
              speed: UInt16? = nil,
              totalCycles: UInt32? = nil,
              altitude: Int16? = nil,
              heartRate: UInt8? = nil,
              cadence: UInt8? = nil) {
    self.timestamp = timestamp
    self.latitude = latitude
    self.longitude = longitude
    self.distance = distance
    self.speed = speed
    self.totalCycles = totalCycles
    self.altitude = altitude
    self.heartRate = heartRate
    self.cadence = cadence
    
    self.size = 0
    self.size = generateMessageDefinition().fields.totalFieldSize
  }

  public init?(data: Data, bytePosition: Int, fields: [MessageDefinition.Field], localMessageNumber: CChar) {
    self.localMessageNumber = localMessageNumber
    var offset = bytePosition
    
    for field in fields {
      switch field.number {
      case 253:
        guard let timestampInt = data[offset...].to(type: UInt32.self) else { return nil }
        self.timestamp = Date(timeIntervalSinceReferenceDate: TimeInterval(timestampInt))
      case 0:
        if let latitude = data[offset...].to(type: Int32.self),
          latitude < Int32.max,
          latitude > Int32.min
        {
          self.latitude = latitude.semiCirclesToDegrees
        }
      case 1:
        if let longitude = data[offset...].to(type: Int32.self),
          longitude < Int32.max,
          longitude > Int32.min
        {
          self.longitude = longitude?.semiCirclesToDegrees
        }
      case 5:
        self.distance = data[offset...].to(type: UInt32.self)
      case 6:
        self.speed = data[offset...].to(type: UInt16.self)
      case 19:
        self.totalCycles = data[offset...].to(type: UInt32.self)
      case 2:
        if let val = data[offset...].to(type: Int16.self) {
          self.altitude = (val / 5) - 500
        }
      case 3:
        self.heartRate = data[offset...].to(type: UInt8.self)
      case 4:
        self.cadence = data[offset...].to(type: UInt8.self)
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

    if latitude != nil {
      fields.append(MessageDefinition.Field(number: 0,
                                       size: UInt8(MemoryLayout<Int32>.size),
                                       baseType: FitBaseType.sint32.rawValue))
    }
    
    if longitude != nil {
      fields.append(MessageDefinition.Field(number: 1,
                                       size: UInt8(MemoryLayout<Int32>.size),
                                       baseType: FitBaseType.sint32.rawValue))
    }
    
    if distance != nil {
      fields.append(MessageDefinition.Field(number: 5,
                                       size: UInt8(MemoryLayout<UInt32>.size),
                                       baseType: FitBaseType.uint32.rawValue))
    }
    
    if speed != nil {
      fields.append(MessageDefinition.Field(number: 6,
                                       size: UInt8(MemoryLayout<UInt16>.size),
                                       baseType: FitBaseType.uint16.rawValue))
    }
    
    if totalCycles != nil {
      fields.append(MessageDefinition.Field(number: 19,
                                       size: UInt8(MemoryLayout<UInt32>.size),
                                       baseType: FitBaseType.uint32.rawValue))
    }

    if altitude != nil {
      fields.append(MessageDefinition.Field(number: 2,
                                       size: UInt8(MemoryLayout<Int16>.size),
                                       baseType: FitBaseType.sint16.rawValue))
    }
    
    if heartRate != nil {
      fields.append(MessageDefinition.Field(number: 3,
                                       size: UInt8(MemoryLayout<UInt8>.size),
                                       baseType: FitBaseType.uint8.rawValue))
    }

    if cadence != nil {
      fields.append(MessageDefinition.Field(number: 4,
                                       size: UInt8(MemoryLayout<UInt8>.size),
                                       baseType: FitBaseType.uint8.rawValue))
    }
    
    return MessageDefinition(fields: fields,
                             localMessageType: localMessageNumber ?? 0,
                             globalMessageNumber: MessageNumber.record.rawValue)
  }
}
