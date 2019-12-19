//
//  TotalsMessage.swift
//  
//
//  Created by Paul MacRory on 26/11/2019.
//

import Foundation

public struct TotalsMessage: FitMessage {
  public var size: Int
  
  public var timestamp: Date!
  public var timerTime: UInt32?
  public var distance: UInt32?
  public var calories: UInt32?
  public var elapsedTime: UInt32?
  public var activeTime: UInt32?
  
  public var data: Data {
    Data()
  }
  
  public var globalMessageNumber: MessageNumber { .totals }
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
        self.timerTime = data[offset...].to(type: UInt32.self)
      case 1:
        self.distance = data[offset...].to(type: UInt32.self)
      case 2:
        self.calories = data[offset...].to(type: UInt32.self)
      case 4:
        self.elapsedTime = data[offset...].to(type: UInt32.self)
      case 6:
        self.activeTime = data[offset...].to(type: UInt32.self)
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
                      globalMessageNumber: MessageNumber.totals.rawValue)
  }
  
}
