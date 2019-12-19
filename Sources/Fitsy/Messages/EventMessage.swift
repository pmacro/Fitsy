//
//  EventMessage.swift
//  
//
//  Created by Paul MacRory on 26/11/2019.
//

import Foundation

public struct EventMessage: FitMessage {
  public var size: Int
  
  public var timestamp: Date!
  public var event: FitEvent!
  public var eventType: FitEventType!
  
  public var data: Data {
    Data()
  }
  
  public var globalMessageNumber: MessageNumber { .event }
  public var localMessageNumber: CChar?

  public init?(data: Data, bytePosition: Int, fields: [MessageDefinition.Field], localMessageNumber: CChar) {
    self.localMessageNumber = localMessageNumber
    var offset = bytePosition
    
    for field in fields {

      switch field.number {
      case 253:
        guard let timestampInt = data[offset...].to(type: UInt32.self) else { return nil }
        self.timestamp = Date(timeIntervalSinceFitBaseDate: TimeInterval(timestampInt))
      case 0:
        guard let eventInt = data[offset...].to(type: UInt8.self) else { return nil }
        self.event = FitEvent(rawValue: eventInt) ?? FitEvent.invalid
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
    MessageDefinition(fields: [],
                      localMessageType: 0,
                      globalMessageNumber: MessageNumber.event.rawValue)
  }
}
