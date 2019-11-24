//
//  File.swift
//  
//
//  Created by Paul MacRory on 21/11/2019.
//

import Foundation

public struct FitHeader {
  let size:              CChar
  let protocolVersion:   CChar
  let profileVersion:    UInt16
  let dataSize:          UInt32
  let dataType:          String
  let CRC:               UInt16
  
  public init?(from data: Data) {
    var offset = 0
    
    guard let size = data.to(type: CChar.self) else { return nil }
    self.size = size
    offset += MemoryLayout.size(ofValue: self.size)
    
    guard let protocolVersion = data[offset...].to(type: CChar.self) else { return nil }
    self.protocolVersion = protocolVersion
    offset += MemoryLayout.size(ofValue: self.protocolVersion)
    
    guard let profileVersion = data[offset...].to(type: UInt16.self) else { return nil }
    self.profileVersion = profileVersion
    offset += MemoryLayout.size(ofValue: self.profileVersion)

    guard let dataSize = data[offset...].to(type: UInt32.self) else { return nil }
    self.dataSize = dataSize
    offset += MemoryLayout.size(ofValue: self.dataSize)

    let dataType = data[offset..<offset+4].toArray(type: CChar.self)
    self.dataType = String(cString: dataType + [0])
    offset += 4

    guard let crc = data[offset...].to(type: UInt16.self) else { return nil }
    self.CRC = crc
    let headerSizeExcludingCRC = offset
    offset += MemoryLayout.size(ofValue: self.CRC)
    
    // Ensure the header size is as expected.
    if self.size != offset {
      print("Header size is not as expected.")
      return nil
    }

    // Now check the CRC is valid, else the file is corrupt.
    let headerData = data[0..<headerSizeExcludingCRC].map { $0 }
    let crcCheck = crc16(headerData, type: .ARC)
    
    if crcCheck != crc {
      print("CRC validation failed.")
      return nil
    }
  }
}

enum CRCType {
    case MODBUS
    case ARC
}

func crc16(_ data: [UInt8], type: CRCType) -> UInt16? {
    if data.isEmpty {
        return nil
    }
    let polynomial: UInt16 = 0xA001 // A001 is the bit reverse of 8005
    var accumulator: UInt16
    // set the accumulator initial value based on CRC type
    if type == .ARC {
        accumulator = 0
    }
    else {
        // default to MODBUS
        accumulator = 0xFFFF
    }
    // main computation loop
    for byte in data {
        var tempByte = UInt16(byte)
        for _ in 0 ..< 8 {
            let temp1 = accumulator & 0x0001
            accumulator = accumulator >> 1
            let temp2 = tempByte & 0x0001
            tempByte = tempByte >> 1
            if (temp1 ^ temp2) == 1 {
                accumulator = accumulator ^ polynomial
            }
        }
    }
    return accumulator
}
