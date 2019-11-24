//
//  File.swift
//  
//
//  Created by Paul MacRory on 21/11/2019.
//

import Foundation

struct MessageConstants {
  static let messageDefinitionMask:                                     CChar = 0x40
  static let messageHeaderMask:                                         CChar = 0x00
  static let localMessageNumMask:                                       CChar = 0x0F
                                
  static let headerTypeMask:                                            Int16 = 0xF0
  static let compressedHeaderMask:                                      Int16 = 0x80
  static let compressedTimeMask:                                        CChar = 0x1F
  static let compressedLocalMessageNumMask:                             CChar = 0x60
}

public enum FileType: Int {
  case device =                                                         1
  case activity =                                                       4
}

public enum ActivityType: CChar {
  case generic =                                                        0
  case running
  case cycling
  case transition
}

public enum FitEvent: Int16 {
  case invalid =                                                        0xFF
  case timer =                                                          0 // Group 0.  Start / stop_all
  case workout =                                                        3 // start / stop
  case workoutStep =                                                    4 // Start at beginning of workout.  Stop at end of each step.
  case powerDown =                                                      5 // stop_all group 0
  case powerUp =                                                        6 // stop_all group 0
  case offCourse =                                                      7 // start / stop group 0
  case session =                                                        8 // Stop at end of each session.
  case lap =                                                            9 // Stop at end of each lap.
  case coursePoint =                                                    10 // marker
  case battery =                                                        11 // marker
  case virtualPartnerPace =                                             12 // Group 1. Start at beginning of activity if VP enabled, when VP pace is changed during activity or VP enabled mid activity.  stop_disable when VP disabled.
  case heartRateHighAlert =                                             13 // Group 0.  Start / stop when in alert condition.
  case heartRateLowAlert =                                              14 // Group 0.  Start / stop when in alert condition.
  case speedHighAlert =                                                 15 // Group 0.  Start / stop when in alert condition.
  case speedLowAlert =                                                  16 // Group 0.  Start / stop when in alert condition.
  case cadenceHighAlert =                                               17 // Group 0.  Start / stop when in alert condition.
  case cadenceLowAlert =                                                18 // Group 0.  Start / stop when in alert condition.
  case powerHighAlert =                                                 19 // Group 0.  Start / stop when in alert condition.
  case powerLowAlert =                                                  20 // Group 0.  Start / stop when in alert condition.
  case heartRateRecovery =                                              21 // marker
  case batteryLow =                                                     22 // marker
  case timeDurationAlert =                                              23 // Group 1.  Start if enabled mid activity (not required at start of activity). Stop when duration is reached.  stop_disable if disabled.
  case distanceDurationAlert =                                          24 // Group 1.  Start if enabled mid activity (not required at start of activity). Stop when duration is reached.  stop_disable if disabled.
  case calorieDurationAlert =                                           25 // Group 1.  Start if enabled mid activity (not required at start of activity). Stop when duration is reached.  stop_disable if disabled.
  case activity =                                                       26 // Group 1..  Stop at end of activity.
  case fitnessEquipment =                                               27 // marker
  case length  =                                                        28 // Stop at end of each length.
  case userMarker =                                                     32 // marker
  case sportPoint =                                                     33 // marker
  case calibration =                                                    36 // start/stop/marker
  case frontGearChange =                                                42 // marker
  case rearGearChange =                                                 43 // marker
  case riderPositionChange =                                            44 // marker
  case elevationHighAlert =                                             45 // Group 0.  Start / stop when in alert condition.
  case elevationLowAlert =                                              46 // Group 0.  Start / stop when in alert condition.
  case commTimeout =                                                    47 // marker
}

public enum FitEventType: Int16 {
  case invalid =                                                        0xFF
  case start =                                                          0
  case stop =                                                           1
  case consecutiveDepreciated =                                         2
  case marker =                                                         3
  case stopAll =                                                        4
  case beginDepreciated =                                               5
  case endDepreciated =                                                 6
  case endAllDepreciated =                                              7
  case stopDisable =                                                    8
  case stopDisableAll =                                                 9
}

public enum FitSport: Int {
  case generic =                                                        0
  case running =                                                        1
  case cycling =                                                        2
  case transition =                                                     3        // Mulitsport transition
  case fitnessEquipment =                                               4
  case swimming =                                                       5
  case basketball =                                                     6
  case soccer =                                                         7
  case tennis =                                                         8
  case americanFootball =                                               9
  case training =                                                       10
  case walking =                                                        11
  case crossCountrySkiing =                                             12
  case alpineSkiing =                                                   13
  case snowboarding =                                                   14
  case rowing =                                                         15
  case mountaineering =                                                 16
  case hiking =                                                         17
  case multisport =                                                     18
  case paddling =                                                       19
  case flying =                                                         20
  case eBiking =                                                        21
  case motorcycling =                                                   22
  case boating =                                                        23
  case driving =                                                        24
  case golf =                                                           25
  case hangGliding =                                                    26
  case horsebackRiding =                                                27
  case hunting =                                                        28
  case fishing =                                                        29
  case inlineSkating =                                                  30
  case rockClimbing =                                                   31
  case sailing =                                                        32
  case iceSkating =                                                     33
  case skyDiving =                                                      34
  case snowshoeing =                                                    35
  case snowmobiling =                                                   36
  case standUpPaddleboarding =                                          37
  case surfing =                                                        38
  case wakeboarding =                                                   39
  case waterSkiing =                                                   40
  case kayaking =                                                       41
  case rafting =                                                        42
  case windsurfing =                                                    43
  case kitesurfing =                                                    44
  case tactical =                                                       45
  case jumpmaster =                                                     46
  case boxing =                                                         47
  case floorClimbing =                                                  48
  case all =                                                            254        // All is for goals only to include all sports.

}

public struct MessageDefinition {
  
  public struct Field {
    let number: UInt8
    let size: CChar
    let baseType: CChar
  }
    
  public var fields: [Field] = []
  public let localMessageType: CChar
  public let globalMessageNumber: UInt16
  public let size: Int
  
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
      guard let size = data[offset...].to(type: CChar.self) else { return nil }
      offset += 1
      guard let bType = data[offset...].to(type: CChar.self) else { return nil }
      offset += 1
      
      fields.append(Field(number: num, size: size, baseType: bType))
    }
    
    size = offset - bytePosition
  }
}

extension Array where Element == MessageDefinition.Field {
  var totalFieldSize: Int { self.reduce(0, { $0 + Int($1.size) }) }
}

extension FitFile {
  func inflateMessage(from data: Data,
                      bytePosition: Int,
                      headerByte: CChar,
                      compressed: Bool) -> FitMessage? {
    let offset = bytePosition
        
    let localMessageNumber: CChar
    
    if compressed {
      localMessageNumber = (headerByte & MessageConstants.compressedLocalMessageNumMask) >> 5
    } else {
      localMessageNumber = headerByte & MessageConstants.localMessageNumMask
    }

    guard let messageDefinition = messageDefinitions[localMessageNumber] else {
      print("Couldn't find message definition for message with local ID: \(localMessageNumber)")
      return nil
    }
    
    return inflateFields(messageDefinition: messageDefinition,
                         data: data,
                         bytePosition: offset)
  }
  
  func inflateFields(messageDefinition: MessageDefinition,
                     data: Data,
                     bytePosition: Int) -> FitMessage? {
    
    let messageNumber = MessageNumber(rawValue: UInt16(messageDefinition.globalMessageNumber))
    let messageType: FitMessage.Type
    
    switch messageNumber {
    case .fileId:
      messageType = FileIdMessage.self
    case .activity:
      messageType = ActivityMessage.self
    case .session:
      messageType = SessionMessage.self
    case .length:
      messageType = LengthMessage.self
    case .lap:
      messageType = LapMessage.self
    case .record:
      messageType = RecordMessage.self
    case .event:
      messageType = EventMessage.self
    default:
      print("Skipping message type \(messageNumber ?? .invalid) as Fitsy has not implemented this type.")
      return DummyMessage(messageType: messageNumber ?? .invalid,
                          data: data,
                          bytePosition: bytePosition,
                          fields: messageDefinition.fields)
    }
    
    return messageType.init(data: data,
                            bytePosition: bytePosition,
                            fields: messageDefinition.fields)
  }
}

public protocol FitMessage {
  var size: Int { get }
  init?(data: Data, bytePosition: Int, fields: [MessageDefinition.Field])
}

public struct FileIdMessage: FitMessage {
  public var type: FileType!
  public var manufacturer: UInt16!
  public var product: UInt16!
  public var serialNumber: UInt32!
  public var timeCreated: Date!
  public var size: Int = 0
  
  public init?(data: Data, bytePosition: Int, fields: [MessageDefinition.Field]) {
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
        self.timeCreated = Date(timeIntervalSince1970: TimeInterval(timeCreated))
        
      default:
        print("Unexpected field found.")
      }
      offset += Int(field.size)
    }
    
    self.size = offset - bytePosition
  }
}

///
/// This is used to skip a message and is used solely to determine the size of the message, and therefore the number of bytes
/// that need to be skipped.
///
struct DummyMessage: FitMessage {
  var size: Int = 0
  var messageType: MessageNumber!
  
  init?(messageType: MessageNumber, data: Data, bytePosition: Int, fields: [MessageDefinition.Field]) {
    self.init(data: data, bytePosition: bytePosition, fields: fields)
    self.messageType = messageType
  }
  
  init?(data: Data, bytePosition: Int, fields: [MessageDefinition.Field]) {
    size = fields.totalFieldSize
  }
}

public struct ActivityMessage: FitMessage {
  public var size: Int
  public var totalTimerTime: UInt32!
  public var timestamp: Date!
  public var numberOfSessions: UInt16!
  public var type: ActivityType!
  public var event: FitEvent!
  public var eventType: FitEventType!
  
  public init?(data: Data, bytePosition: Int, fields: [MessageDefinition.Field]) {
    var offset = bytePosition

    for field in fields {
      switch field.number {
      case 253:
        guard let timestampInt = data[offset...].to(type: UInt32.self) else { return nil }
        self.timestamp = Date(timeIntervalSinceReferenceDate: TimeInterval(timestampInt))
      case 0:
        guard let totalTimerTime = data[offset...].to(type: UInt32.self) else { return nil }
        self.totalTimerTime = totalTimerTime
      case 1:
        guard let sessionCount = data[offset...].to(type: UInt16.self) else { return nil }
        self.numberOfSessions = sessionCount
      case 2:
        guard let eventTypeInt = data[offset...].to(type: CChar.self),
        let type = ActivityType(rawValue: eventTypeInt) else { return nil }
        self.type = type
      case 3:
        guard let typeInt = data[offset...].to(type: CChar.self),
        let event = FitEvent(rawValue: Int16(typeInt)) else { return nil }
        self.event = event
      case 4:
        guard let eventTypeInt = data[offset...].to(type: CChar.self) else { return nil }
        self.eventType = FitEventType(rawValue: Int16(eventTypeInt)) ?? .invalid
      default:
        break
      }
      
      offset += Int(field.size)
    }
    
    self.size = fields.totalFieldSize
  }
}

public struct SessionMessage: FitMessage {
  public var size: Int
    
  public var timestamp: Date!
  public var startTime: Date!
  public var totalElapsedTime: UInt32!
  public var sport: FitSport!
  public var event: FitEvent!
  public var eventType: FitEventType!
  
  public init?(data: Data, bytePosition: Int, fields: [MessageDefinition.Field]) {
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
        guard let eventInt = data[offset...].to(type: CChar.self),
        let event = FitEvent(rawValue: Int16(eventInt)) else { return nil }
        self.event = event
      case 1:
        guard let eventTypeInt = data[offset...].to(type: CChar.self) else { return nil }
        self.eventType = FitEventType(rawValue: Int16(eventTypeInt)) ?? .invalid
      default:
        break
      }
      
      offset += Int(field.size)
    }
    
    self.size = fields.totalFieldSize
  }
}

public struct LapMessage: FitMessage {
  public var size: Int

  public var timestamp: Date!
  public var startTime: Date!

  public var event: FitEvent!
  public var eventType: FitEventType!
  
  public init?(data: Data, bytePosition: Int, fields: [MessageDefinition.Field]) {
    var offset = bytePosition

    for field in fields {
      switch field.number {
      case 253:
        guard let timestampInt = data[offset...].to(type: UInt32.self) else { return nil }
        self.timestamp = Date(timeIntervalSinceReferenceDate: TimeInterval(timestampInt))
      case 2:
        guard let startTimeInt = data[offset...].to(type: UInt32.self) else { return nil }
        self.startTime = Date(timeIntervalSinceReferenceDate: TimeInterval(startTimeInt))
      case 0:
        guard let eventInt = data[offset...].to(type: CChar.self) else { return nil }
        self.event = FitEvent(rawValue: Int16(eventInt)) ?? .invalid
      case 1:
        guard let eventTypeInt = data[offset...].to(type: CChar.self) else { return nil }
        self.eventType = FitEventType(rawValue: Int16(eventTypeInt)) ?? .invalid
      default:
        break
      }
      
      offset += Int(field.size)
    }
    
    self.size = fields.totalFieldSize
  }
}

public struct LengthMessage: FitMessage {
  public var size: Int
 
  public var timestamp: Date!
  public var event: FitEvent!
  public var eventType: FitEventType!
  
  public init?(data: Data, bytePosition: Int, fields: [MessageDefinition.Field]) {
    var offset = bytePosition

    for field in fields {
      switch field.number {
      case 253:
        guard let timestampInt = data[offset...].to(type: UInt32.self) else { return nil }
        self.timestamp = Date(timeIntervalSinceReferenceDate: TimeInterval(timestampInt))
      case 0:
        guard let eventInt = data[offset...].to(type: CChar.self) else { return nil }
        self.event = FitEvent(rawValue: Int16(eventInt)) ?? FitEvent.invalid
      case 1:
        guard let eventTypeInt = data[offset...].to(type: CChar.self) else { return nil }
        self.eventType = FitEventType(rawValue: Int16(eventTypeInt)) ?? .invalid
      default:
        break
      }
      
      offset += Int(field.size)
    }
    
    self.size = fields.totalFieldSize
  }
}

public struct RecordMessage: FitMessage {
  public var size: Int
  public var timestamp: Date!
  public var latitude: Double?
  public var longitude: Double?
  public var distance: UInt32?
  public var heartRate: UInt8?
  public var cadence: UInt8?
  public var altitude: UInt16?
  public var totalCycles: UInt32?
  
  public init?(data: Data, bytePosition: Int, fields: [MessageDefinition.Field]) {
    var offset = bytePosition
    
    for field in fields {
      switch field.number {
      case 253:
        guard let timestampInt = data[offset...].to(type: UInt32.self) else { return nil }
        self.timestamp = Date(timeIntervalSinceReferenceDate: TimeInterval(timestampInt))
      case 0:
        self.latitude = data[offset...].to(type: Int32.self)?.semiCirclesToDegrees
      case 1:
        self.longitude = data[offset...].to(type: Int32.self)?.semiCirclesToDegrees
      case 5:
        self.distance = data[offset...].to(type: UInt32.self)
      case 19:
        self.totalCycles = data[offset...].to(type: UInt32.self)
      case 2:
        self.altitude = data[offset...].to(type: UInt16.self)
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
}

public struct EventMessage: FitMessage {
  public var size: Int
  
  public var timestamp: Date!
  public var event: FitEvent!
  public var eventType: FitEventType!

  public init?(data: Data, bytePosition: Int, fields: [MessageDefinition.Field]) {
    var offset = bytePosition
    
    for field in fields {

      switch field.number {
      case 253:
        guard let timestampInt = data[offset...].to(type: UInt32.self) else { return nil }
        self.timestamp = Date(timeIntervalSinceReferenceDate: TimeInterval(timestampInt))
      case 0:
        guard let eventInt = data[offset...].to(type: CChar.self) else { return nil }
        self.event = FitEvent(rawValue: Int16(eventInt)) ?? FitEvent.invalid
      case 1:
        guard let eventTypeInt = data[offset...].to(type: CChar.self) else { return nil }
        self.eventType = FitEventType(rawValue: Int16(eventTypeInt)) ?? .invalid
      default:
        break
      }
    
      offset += Int(field.size)
    }

    self.size = fields.totalFieldSize
  }
}

struct DeviceInfoMessage {
  public let timestamp: Date
}

struct HRVMessage {
  public let time: UInt16
}

