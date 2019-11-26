//
//  File.swift
//  
//
//  Created by Paul MacRory on 21/11/2019.
//

import Foundation

public struct FitHeader: FitFileEntity {
  // ".FIT".  The expected value for the "dataType" property.
  static let FIT_HEADER_DATA_TYPE: [CChar] = [46, 70, 73, 84]
  
  var size:              UInt8
  let protocolVersion:   CChar
  let profileVersion:    UInt16
  let dataSize:          UInt32
  let dataType:          String
  var CRC:               UInt16?
  
  public var data: Data {
    let headerData = bodyData
    
    if let CRCData = crc16(headerData.toArray(type: UInt8.self), type: .ARC) {
      return headerData + withUnsafeBytes(of: CRCData) { Data($0) }
    }
    
    return Data()
  }
  
  /// The data representing this header, minus the CRC.
  var bodyData: Data {
    let sizeData = withUnsafeBytes(of: size) { Data($0) }
    let protocolVersionData = withUnsafeBytes(of: protocolVersion) { Data($0) }
    let profileVersionData = withUnsafeBytes(of: profileVersion) { Data($0) }
    let dataSizeData = withUnsafeBytes(of: dataSize) { Data($0) }
    let dataTypeData = Data(fromArray: FitHeader.FIT_HEADER_DATA_TYPE)
        
    return sizeData
         + protocolVersionData
         + profileVersionData
         + dataSizeData
         + dataTypeData
  }
  
  public init(representingFile: Data) {
    self.init(protocolVersion: 16, profileVersion: 1012, dataSize: UInt32(representingFile.count))
  }
  
  public init(protocolVersion: CChar, profileVersion: UInt16, dataSize: UInt32) {
    self.size = 0
    self.protocolVersion = protocolVersion
    self.profileVersion = profileVersion
    self.dataSize = dataSize
    self.dataType = String(cString: FitHeader.FIT_HEADER_DATA_TYPE)
    self.CRC = 0
        
    self.size = UInt8(MemoryLayout.size(ofValue: size)
              + MemoryLayout.size(ofValue: protocolVersion)
              + MemoryLayout.size(ofValue: profileVersion)
              + MemoryLayout.size(ofValue: dataSize)
              + 4 // The dataType size.
              + MemoryLayout.size(ofValue: UInt16()))
    
    self.CRC = crc16(bodyData.map { $0 }, type: .ARC) ?? 0
  }
  
  public init?(from data: Data) {
    var offset = 0
    
    guard let size = data.to(type: UInt8.self) else { return nil }
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
    offset += dataType.count

    let headerSizeExcludingCRC = offset

    // If there are an extra two bytes, we know this file does have a CRC.
    if offset != size {
      guard let crc = data[offset...].to(type: UInt16.self) else { return nil }
      self.CRC = crc
      offset += MemoryLayout<UInt16>.size
    }
    
    // Ensure the header size is as expected.
    if self.size != offset {
      print("Header size is not as expected.")
      return nil
    }

    if let crc = self.CRC {
      // Now check the CRC is valid, else the file is corrupt.
      let headerData = data[0..<headerSizeExcludingCRC].map { $0 }
      let crcCheck = crc16(headerData, type: .ARC)
      
      if crcCheck != crc {
        print("CRC validation failed.")
        return nil
      }
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
