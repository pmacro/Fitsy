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
  
  public var data: Data {
    Data()
  }
  
  public var globalMessageNumber: MessageNumber { .session }
  public var localMessageNumber: CChar?

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
      case 0:
        guard let eventInt = data[offset...].to(type: UInt8.self),
        let event = FitEvent(rawValue: eventInt) else { return nil }
        self.event = event
      case 1:
        guard let eventTypeInt = data[offset...].to(type: UInt8.self) else { return nil }
        self.eventType = FitEventType(rawValue: eventTypeInt) ?? .invalid
      case 11:
        self.totalCalories = data[offset...].to(type: UInt16.self)
      default:
        break
      }
      
      offset += Int(field.size)
    }
    
    self.size = fields.totalFieldSize
  }
  
  public func generateMessageDefinition() -> MessageDefinition {
    MessageDefinition(fields: [],
                      localMessageType: 0,
                      globalMessageNumber: MessageNumber.session.rawValue)
  }
}
