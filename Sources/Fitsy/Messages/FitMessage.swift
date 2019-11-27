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

public enum ActivityType: UInt8 {
  case invalid =                                                        0xFF
  case manual  =                                                        0
  case autoMultiSport =                                                 1
}

public enum FitEvent: UInt8 {
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

public enum FitEventType: UInt8 {
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

public enum FitSport: UInt8 {
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
  case waterSkiing =                                                    40
  case kayaking =                                                       41
  case rafting =                                                        42
  case windsurfing =                                                    43
  case kitesurfing =                                                    44
  case tactical =                                                       45
  case jumpmaster =                                                     46
  case boxing =                                                         47
  case floorClimbing =                                                  48
  case all =                                                            254        // All is for goals only to include all sports.
  case invalid =                                                        0xFF
}

public protocol FitFileEntity {
  var data: Data { get }
}

public protocol FitMessage: FitFileEntity, MessageDefinitionGenerator {
  var size: Int { get }
  var globalMessageNumber: MessageNumber { get }
  var localMessageNumber: CChar? { set get }
  init?(data: Data, bytePosition: Int, fields: [MessageDefinition.Field], localMessageNumber: CChar)
}

struct HRVMessage {
  public let time: UInt16
}

