//
//  LapMessage.swift
//  
//
//  Created by Paul MacRory on 26/11/2019.
//

import Foundation

public struct LapMessage: FitMessage {
  public var size: Int

  public var timestamp: Date!
  public var startTime: Date!

  public var sport: FitSport!
  public var event: FitEvent!
  public var eventType: FitEventType!
  
  public var data: Data {
    return  Data(from: UInt32(timestamp.timeIntervalSinceReferenceDate))
          + Data(from: UInt32(startTime.timeIntervalSinceReferenceDate))
          + Data(from: sport.rawValue)
          + Data(from: event.rawValue)
          + Data(from: eventType.rawValue)
  }
  
  public var globalMessageNumber: MessageNumber { .lap }
  public var localMessageNumber: CChar?
  
  public init(timestamp: Date,
              startTime: Date,
              sport: FitSport,
              event: FitEvent,
              eventType: FitEventType) {
    self.timestamp = timestamp
    self.startTime = startTime
    self.sport = sport
    self.event = event
    self.eventType = eventType
    
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
      case 2:
        guard let startTimeInt = data[offset...].to(type: UInt32.self) else { return nil }
        self.startTime = Date(timeIntervalSinceReferenceDate: TimeInterval(startTimeInt))
      case 23:
        guard let sportInt = data[offset...].to(type: UInt8.self),
              let sport = FitSport(rawValue: sportInt) else { return nil }
        self.sport = sport
      case 0:
        guard let eventInt = data[offset...].to(type: UInt8.self) else { return nil }
        self.event = FitEvent(rawValue: eventInt) ?? .invalid
      case 1:
        guard let eventTypeInt = data[offset...].to(type: UInt8.self) else { return nil }
        self.eventType = FitEventType(rawValue: eventTypeInt) ?? .invalid
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
    
    fields.append(MessageDefinition.Field(number: 23,
                                          size: UInt8(MemoryLayout.size(ofValue: sport.rawValue)),
                                          baseType: FitBaseType.uint8.rawValue))
    
    fields.append(MessageDefinition.Field(number: 0,
                                          size: UInt8(MemoryLayout.size(ofValue: event.rawValue)),
                                          baseType: FitBaseType.uint8.rawValue))
    
    fields.append(MessageDefinition.Field(number: 1,
                                          size: UInt8(MemoryLayout.size(ofValue: eventType.rawValue)),
                                          baseType: FitBaseType.uint8.rawValue))
    
    return MessageDefinition(fields: fields,
                      localMessageType: localMessageNumber ?? 0,
                      globalMessageNumber: MessageNumber.lap.rawValue)
  }
}
