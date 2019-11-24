//
//  File.swift
//  
//
//  Created by Paul MacRory on 22/11/2019.
//

import Foundation

public enum MessageNumber: UInt16 {
  case fileId                       = 0
  case capabilities                 = 1
  case deviceSettings               = 2
  case userProfile                  = 3
  case hrmProfile                   = 4
  case sdmProfile                   = 5
  case bikeProfile                  = 6
  case zonesTarget                  = 7
  case hrZone                       = 8
  case powerZone                    = 9
  case metZone                      = 10
  case sport                        = 12
  case goal                         = 15
  case session                      = 18
  case lap                          = 19
  case record                       = 20
  case event                        = 21
  case deviceInfo                   = 23
  case workout                      = 26
  case workoutStep                  = 27
  case schedule                     = 28
  case weightScale                  = 30
  case course                       = 31
  case coursePoint                  = 32
  case totals                       = 33
  case activity                     = 34
  case software                     = 35
  case fileCapabilities             = 37
  case mesgCapabilities             = 38
  case fieldCapabilities            = 39
  case fileCreator                  = 49
  case bloodPressure                = 51
  case speedZone                    = 53
  case monitoring                   = 55
  case trainingFile                 = 72
  case hrv                          = 78
  case antRx                        = 80
  case antTx                        = 81
  case antChannelId                 = 82
  case length                       = 101
  case monitoringInfo               = 103
  case pad                          = 105
  case slaveDevice                  = 106
  case connectivity                 = 127
  case weatherConditions            = 128
  case weatherAlert                 = 129
  case cadenceZone                  = 131
  case hr                           = 132
  case segmentLap                   = 142
  case memoGlob                     = 145
  case segmentId                    = 148
  case segmentLeaderboardEntry      = 149
  case segmentPoint                 = 150
  case segmentFile                  = 151
  case watchfaceSettings            = 159
  case gpsMetadata                  = 160
  case cameraEvent                  = 161
  case timestampCorrelation         = 162
  case gyroscopeData                = 164
  case accelerometerData            = 165
  case threeDSensorCalibration      = 167
  case videoFrame                   = 169
  case obdiiData                    = 174
  case nmeaSentence                 = 177
  case aviationAttitude             = 178
  case video                        = 184
  case videoTitle                   = 185
  case videoDescription             = 186
  case videoClip                    = 187
  case ohrSettings                  = 188
  case exdScreenConfiguration       = 200
  case exdDataFieldConfiguration    = 201
  case exdDataConceptConfiguration  = 202
  case fieldDescription             = 206
  case developerDataId              = 207
  case magnetometerData             = 208
  case barometerData                = 209
  case oneDSensorCalibration        = 210
  case set                          = 225
  case stressLevel                  = 227
  case diveSettings                 = 258
  case diveGas                      = 259
  case diveAlarm                    = 262
  case exerciseTitle                = 264
  case diveSummary                  = 268
  case jump                         = 285
  case climbPro                     = 317
  case mfgRangeMin                  = 0xFF00 // 0xFF00 - 0xFFFE reserved for manufacturer specific messages
  case mfgRangeMax                  = 0xFFFE // 0xFF00 - 0xFFFE reserved for manufacturer specific messages
  case invalid                      = 0xFFFF
}
