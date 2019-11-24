//
//  File.swift
//  
//
//  Created by Paul MacRory on 21/11/2019.
//

import Foundation

public struct FitFile {
  
  let header: FitHeader
  
  public var fileIdMessage: FileIdMessage!
  
  var messageDefinitions: [CChar : MessageDefinition] = [:]
  
  public var messages: [FitMessage] = []
  
  public init?(url: URL) {
    if let data = FileManager.default.contents(atPath: url.path) {
      self.init(data: data)
    } else {
      return nil
    }
  }
  
  public init?(data: Data) {
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
