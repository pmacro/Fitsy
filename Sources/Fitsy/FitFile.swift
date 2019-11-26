//
//  File.swift
//  
//
//  Created by Paul MacRory on 21/11/2019.
//

import Foundation

public enum FitFileError: Error {
  case noHeader
}

public struct FitFile {
  
  var header: FitHeader?
  
  public var fileIdMessage: FileIdMessage!
  
  var messageDefinitions: [CChar : MessageDefinition] = [:]
  
  public var messages: [FitMessage] = []
  
  public init(fileIdMessage: FileIdMessage) {
    self.fileIdMessage = fileIdMessage
  }
  
  public init?(url: URL) {
    if let data = FileManager.default.contents(atPath: url.path) {
      self.init(data: data)
    } else {
      return nil
    }
  }
  
  public init?(data: Data) {
    guard checkFileCRC(in: data) else {
      print("CRC file validation failed.")
      return
    }
    
    // Strip off the file CRC.
    let data = data.dropLast(2)
    
    guard let header = FitHeader(from: data) else { return nil }
    self.header = header
    
    var offset = Int(header.size)
    
    guard let definitionHeaderByte = data[offset...].to(type: CChar.self),
      definitionHeaderByte & MessageConstants.messageDefinitionMask == MessageConstants.messageDefinitionMask else {
      return nil
    }
    
    offset += 1

    guard let fileIdMessageDefinition = MessageDefinition(data: data,
                                                          bytePosition: offset,
                                                          headerByte: definitionHeaderByte) else { return nil }
    offset += fileIdMessageDefinition.size
    self.messageDefinitions[fileIdMessageDefinition.localMessageType] = fileIdMessageDefinition
   
    guard let headerByte = data[offset...].to(type: CChar.self),
      headerByte & MessageConstants.messageHeaderMask == MessageConstants.messageHeaderMask else {
      return nil
    }
    
    offset += 1

    guard let fileIdMessage = inflateMessage(from: data,
                                             bytePosition: offset,
                                             headerByte: headerByte,
                                             compressed: false) as? FileIdMessage else {
      return nil
    }
    
    self.fileIdMessage = fileIdMessage
    offset += fileIdMessage.size
    
    inflateFileData(from: data, bytePosition: offset)
  }
  
  public func save(to fileURL: URL) throws {
    try toData().write(to: fileURL)
  }
  
  func toData() throws -> Data {
    var fileData = Data()
    
    // The file ID message definition.
    let fileIdDefinition = fileIdMessage.generateMessageDefinition()
    fileData += Data(from: MessageConstants.messageDefinitionMask)
    fileData += fileIdDefinition.data
    fileData += Data(from: fileIdDefinition.localMessageType)
    fileData += fileIdMessage.data
    
    // Add all other message definitions and message bodies.
    fileData += generateFileData()
    
    fileData = FitHeader(representingFile: fileData).data + fileData
    fileData += Data(from: generateFileCRC(for: fileData))

    return fileData
  }
  
  func generateFileCRC(for fileData: Data) -> UInt16 {
    return crc16(fileData.map { $0 }, type: .ARC) ?? 0
  }
  
  func checkFileCRC(in fileData: Data) -> Bool {
    let fileSize = fileData.count
    let fileCRC = fileData[(fileSize-2)...].to(type: UInt16.self)
    let crcValueCheck = crc16(fileData[0..<fileSize-2].map { $0 }, type: .ARC)
    return fileCRC != nil && fileCRC == crcValueCheck
  }
  
  func generateFileData() -> Data {
    var fileData = Data()
    
    for message in messages where !message.data.isEmpty {
      let messageDefinition = message.generateMessageDefinition()
      let byte = messageDefinition.localMessageType + MessageConstants.messageDefinitionMask
      fileData += Data(from: byte) + messageDefinition.data
      fileData += Data(from: messageDefinition.localMessageType)
      fileData += message.data
    }
    
    return fileData
  }
  
  mutating func inflateFileData(from data: Data, bytePosition: Int) {
    var offset = bytePosition
    
    while offset < data.count {
      guard let byte = data[offset...].to(type: CChar.self) else { return }
      offset += 1
      
      if (Int16(byte) & MessageConstants.compressedHeaderMask) == MessageConstants.compressedHeaderMask {
        guard let message = inflateMessage(from: data,
                                           bytePosition: offset,
                                           headerByte: byte,
                                           compressed: true) else {
          print("Unable to read message at expected position")
          return
        }
        messages.append(message)
        offset += message.size
      }
      else if byte & MessageConstants.messageDefinitionMask == MessageConstants.messageDefinitionMask {
        guard let messageDefinition = MessageDefinition(data: data,
                                                        bytePosition: offset,
                                                        headerByte: byte) else { return }
        self.messageDefinitions[messageDefinition.localMessageType] = messageDefinition
        offset += messageDefinition.size
      }
      else if byte & MessageConstants.messageHeaderMask == MessageConstants.messageHeaderMask {
        guard let message = inflateMessage(from: data,
                                           bytePosition: offset,
                                           headerByte: byte,
                                           compressed: false) else {
          print("Unable to read message at expected position")
          return
        }
        messages.append(message)
        offset += message.size
      } else {
        print("Unsupported record header found.")
      }
    }
  }
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
    
    let messageNumber = MessageNumber(rawValue: messageDefinition.globalMessageNumber)
    let messageType: FitMessage.Type
    
    switch messageNumber {
    case .fileId:
      messageType = FileIdMessage.self
    case .deviceInfo:
      messageType = DeviceInfoMessage.self
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
    case .totals:
      messageType = TotalsMessage.self
    default:
      print("Skipping message type \(messageNumber ?? .invalid) as Fitsy has not implemented this type.")
      return DummyMessage(messageType: messageNumber ?? .invalid,
                          data: data,
                          bytePosition: bytePosition,
                          messageDefinition: messageDefinition)
    }
    
    return messageType.init(data: data,
                            bytePosition: bytePosition,
                            fields: messageDefinition.fields,
                            localMessageNumber: messageDefinition.localMessageType)
  }
}

// Convenience methods for API users.
extension FitFile {
  
  mutating public func add(message: FitMessage) {
    var localMessageId: Int8
    var shouldAddDefinition = false
    
    if let existingDef = messageDefinitions.firstIndex(where: { $0.1.globalMessageNumber == message.globalMessageNumber.rawValue }) {
      localMessageId = messageDefinitions[existingDef].key
    } else {
      localMessageId = Int8(messageDefinitions.count) + 1
      shouldAddDefinition = true
    }
    
    var messageCopy = message
    messageCopy.localMessageNumber = localMessageId
    
    if shouldAddDefinition {
      messageDefinitions[localMessageId] = messageCopy.generateMessageDefinition()
    }
    
    messages.append(messageCopy)
  }
  
  mutating func add(messages: [FitMessage]) {
    messages.forEach { self.add(message: $0) }
  }
}
