//
//  DummyMessage.swift
//  
//
//  Created by Paul MacRory on 26/11/2019.
//

import Foundation

///
/// This is used to skip a message and is used solely to determine the size of the message, and therefore the number of bytes
/// that need to be skipped.
///
struct DummyMessage: FitMessage {
  var size: Int = 0
  public var globalMessageNumber: MessageNumber
  public var localMessageNumber: CChar?
  public var data: Data { Data() }
  
  var messageDefinition: MessageDefinition?
  
  init?(messageType: MessageNumber,
        data: Data,
        bytePosition: Int,
        messageDefinition: MessageDefinition) {
    self.init(data: data,
              bytePosition: bytePosition,
              fields: messageDefinition.fields,
              localMessageNumber: messageDefinition.localMessageType)
    self.globalMessageNumber = messageType
    self.messageDefinition = messageDefinition
  }
  
  init?(data: Data, bytePosition: Int, fields: [MessageDefinition.Field], localMessageNumber: CChar) {
//    self.data = data
    self.localMessageNumber = localMessageNumber
    self.globalMessageNumber = .invalid
    size = fields.totalFieldSize
  }
  
  public func generateMessageDefinition() -> MessageDefinition {
    messageDefinition ?? MessageDefinition(fields: [],
                                           localMessageType: 0,
                                           globalMessageNumber: globalMessageNumber.rawValue)
  }
}
