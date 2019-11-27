//
//  File.swift
//  
//
//  Created by Paul MacRory on 25/11/2019.
//

import Foundation

public struct SessionMessage: FitMessage {
  public var size: Int
    
  public var timestamp: Date!
  public var startTime: Date!
  public var totalElapsedTime: UInt32!
  public var sport: FitSport!
  public var event: FitEvent!
  public var eventType: FitEventType!
  public var totalCalories: UInt16?
  public var totalDistance: UInt32?
  
  public var data: Data {
    var result = Data(from: UInt32(timestamp.timeIntervalSinceReferenceDate))
               + Data(from: UInt32(startTime.timeIntervalSinceReferenceDate))
               + Data(from: totalElapsedTime)
               + Data(from: sport.rawValue)
               + Data(from: event.rawValue)
               + Data(from: eventType.rawValue)
    if let totalCalories = totalCalories {
      result += Data(from: totalCalories)
    }
    
    if let totalDistance = totalDistance {
      result += Data(from: totalDistance)
    }
    
    return result
  }
  
  public var globalMessageNumber: MessageNumber { .session }
  public var localMessageNumber: CChar?
  
  public init(timestamp: Date,
              startTime: Date,
              totalElapsedTime: UInt32,
              sport: FitSport,
              event: FitEvent,
              eventType: FitEventType,
              totalCalories: UInt16? = nil,
              totalDistance: UInt32? = nil) {
    self.timestamp = timestamp
    self.startTime = startTime
    self.totalElapsedTime = totalElapsedTime
    self.sport = sport
    self.event = event
    self.eventType = eventType
    self.totalCalories = totalCalories
    self.totalDistance = totalDistance
    
    self.size = MemoryLayout.size(ofValue: timestamp.timeIntervalSinceReferenceDate)
              + MemoryLayout.size(ofValue: startTime.timeIntervalSinceReferenceDate)
              + MemoryLayout.size(ofValue: totalElapsedTime)
              + MemoryLayout.size(ofValue: sport.rawValue)
              + MemoryLayout.size(ofValue: event.rawValue)
              + MemoryLayout.size(ofValue: eventType.rawValue)
      
    if let totalCalories = totalCalories {
      size += MemoryLayout.size(ofValue: totalCalories)
    }
    
    if totalDistance != nil {
      size += MemoryLayout<UInt32>.size
    }
  }

  public init?(data: Data, bytePosition: Int, fields: [MessageDefinition.Field], localMessageNumber: CChar) {
    self.localMessageNumber = localMessageNumber
    var offset = bytePosition

    for field in fields {
      switch field.number {
      case 253:
        guard let timestampInt = data[offset...].to(type: UInt32.self) else { return nil }
        self.timestamp = Date(timeIntervalSinceReferenceDate: TimeInterval(timestampInt))
      case 2:
        guard let startTimeInt = data[offset...].to(type: UInt32.self) else { return nil }
        self.startTime = Date(timeIntervalSinceReferenceDate: TimeInterval(startTimeInt))
      case 7:
        guard let totalElapsedTime = data[offset...].to(type: UInt32.self) else { return nil }
        self.totalElapsedTime = totalElapsedTime
      case 5:
        guard let sportInt = data[offset...].to(type: UInt8.self),
              let sport = FitSport(rawValue: sportInt) else { return nil }
        self.sport = sport
      case 0:
        guard let eventInt = data[offset...].to(type: UInt8.self),
        let event = FitEvent(rawValue: eventInt) else { return nil }
        self.event = event
      case 1:
        guard let eventTypeInt = data[offset...].to(type: UInt8.self) else { return nil }
        self.eventType = FitEventType(rawValue: eventTypeInt) ?? .invalid
      case 11:
        self.totalCalories = data[offset...].to(type: UInt16.self)
      case 9:
        self.totalDistance = data[offset...].to(type: UInt32.self)
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

    fields.append(MessageDefinition.Field(number: 2,
                                          size: UInt8(MemoryLayout.size(ofValue: UInt32())),
                                          baseType: FitBaseType.uint32.rawValue))
    
    fields.append(MessageDefinition.Field(number: 7,
                                          size:  UInt8(MemoryLayout.size(ofValue: totalElapsedTime)),
                                          baseType: FitBaseType.uint32.rawValue))

    fields.append(MessageDefinition.Field(number: 5,
                                          size: UInt8(MemoryLayout.size(ofValue: sport.rawValue)),
                                          baseType: FitBaseType.uint8.rawValue))
    
    fields.append(MessageDefinition.Field(number: 0,
                                          size: UInt8(MemoryLayout.size(ofValue: event.rawValue)),
                                          baseType: FitBaseType.uint8.rawValue))
    
    fields.append(MessageDefinition.Field(number: 1,
                                          size: UInt8(MemoryLayout.size(ofValue: eventType.rawValue)),
                                          baseType: FitBaseType.uint8.rawValue))

    if let totalCalories = totalCalories {
      fields.append(MessageDefinition.Field(number: 11,
                                            size: UInt8(MemoryLayout.size(ofValue: totalCalories)),
                                            baseType: FitBaseType.uint16.rawValue))
    }
    
    if totalDistance != nil {
      fields.append(MessageDefinition.Field(number: 9,
                                            size: UInt8(MemoryLayout<UInt32>.size),
                                            baseType: FitBaseType.uint32.rawValue))
    }

    return MessageDefinition(fields: fields,
                             localMessageType: localMessageNumber ?? 0,
                             globalMessageNumber: MessageNumber.session.rawValue)
  }
}
