//
//  File.swift
//  
//
//  Created by Paul MacRory on 26/11/2019.
//

import Foundation

public struct ActivityMessage: FitMessage {
  public var size: Int
  public var totalTimerTime: UInt32!
  public var timestamp: Date!
  public var numberOfSessions: UInt16!
  public var type: ActivityType!
  public var event: FitEvent!
  public var eventType: FitEventType!
  
  public var data: Data {
    return Data(from: UInt32(timestamp.timeIntervalSinceReferenceDate))
         + Data(from: totalTimerTime * 1000)
         + Data(from: numberOfSessions)
         + Data(from: type.rawValue)
         + Data(from: event.rawValue)
         + Data(from: eventType.rawValue)
  }
  
  public var globalMessageNumber: MessageNumber { .activity }
  public var localMessageNumber: CChar?
  
  public init(totalTimerTime: UInt32,
              timestamp: Date,
              numberOfSessions: UInt16,
              type: ActivityType,
              event: FitEvent,
              eventType: FitEventType) {
    self.totalTimerTime = totalTimerTime
    self.timestamp = timestamp
    self.numberOfSessions = numberOfSessions
    self.type = type
    self.event = event
    self.eventType = eventType
    
    self.size = MemoryLayout.size(ofValue: totalTimerTime * 1000)
              + MemoryLayout.size(ofValue: UInt32(timestamp.timeIntervalSinceReferenceDate))
              + MemoryLayout.size(ofValue: numberOfSessions)
              + MemoryLayout.size(ofValue: UInt8(type.rawValue))
              + MemoryLayout.size(ofValue: UInt8(event.rawValue))
              + MemoryLayout.size(ofValue: UInt8(eventType.rawValue))
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
        guard let totalTimerTime = data[offset...].to(type: UInt32.self) else { return nil }
        self.totalTimerTime = totalTimerTime / 1000
      case 1:
        guard let sessionCount = data[offset...].to(type: UInt16.self) else { return nil }
        self.numberOfSessions = sessionCount
      case 2:
        guard let activityTypeInt = data[offset...].to(type: CChar.self),
        let type = ActivityType(rawValue: activityTypeInt) else { return nil }
        self.type = type
      case 3:
        guard let typeInt = data[offset...].to(type: UInt8.self),
        let event = FitEvent(rawValue: typeInt) else { return nil }
        self.event = event
      case 4:
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
    MessageDefinition(fields: [.init(number: 253,
                                     size: UInt8(MemoryLayout.size(ofValue: UInt32())),
                                     baseType: FitBaseType.uint32.rawValue),
                               .init(number: 0,
                                     size: UInt8(MemoryLayout.size(ofValue: totalTimerTime * 1000)),
                                     baseType: FitBaseType.uint32.rawValue),
                               .init(number: 1,
                                     size: UInt8(MemoryLayout.size(ofValue: numberOfSessions)),
                                     baseType: FitBaseType.uint16.rawValue),
                               .init(number: 2,
                                     size: UInt8(MemoryLayout.size(ofValue: type.rawValue)),
                                     baseType: FitBaseType.sint8.rawValue),
                               .init(number: 3,
                                     size: UInt8(MemoryLayout.size(ofValue: event.rawValue)),
                                     baseType: FitBaseType.sint8.rawValue),
                               .init(number: 4,
                                     size: UInt8(MemoryLayout.size(ofValue: eventType.rawValue)),
                                     baseType: FitBaseType.sint8.rawValue)
                              ],
                      localMessageType: localMessageNumber ?? -1,
                      globalMessageNumber: MessageNumber.activity.rawValue)
  }
}
