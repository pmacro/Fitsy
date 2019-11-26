import XCTest
@testable import Fitsy

final class FitsyTests: XCTestCase {
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    XCTAssertEqual(Fitsy().text, "Hello, World!")
      
      
    let testFileURL = URL(fileURLWithPath:
          "/Users/pmacrory/Downloads/838331718.fit")
//        "/Users/pmacrory/Downloads/fit-sdk-swift-master-2/samples/running.fit")
    let parsedFile = FitFile(url: testFileURL)
    print(parsedFile?.messages)
  }
  
  func testSaving() {
    let testFileURL = URL(fileURLWithPath: "/Users/pmacrory/Downloads/838331718.fit")
    let parsedFile = FitFile(url: testFileURL)!

    let saveURL = URL(fileURLWithPath: "/Users/pmacrory/Downloads/test_save.fit")
    try! parsedFile.save(to: saveURL)

    let openedSavedFile = FitFile(url: saveURL)
    print(openedSavedFile!.messages)
  }
  
  func testTwoMessageFile() {
    var file = FitFile(fileIdMessage: FileIdMessage(type: .activity,
                                                    manufacturer: 12,
                                                    product: 21,
                                                    serialNumber: 999,
                                                    timeCreated: Date()))
    var activityMessage = ActivityMessage(totalTimerTime: 1488,
                                          timestamp: Date(timeIntervalSinceReferenceDate: 806010397),
                                          numberOfSessions: 1,
                                          type: .generic,
                                          event: .workout,
                                          eventType: .stop)
    activityMessage.localMessageNumber = 11
    file.messages.append(activityMessage)
    file.messageDefinitions[11] = activityMessage.generateMessageDefinition()
    
    let header = FitHeader(protocolVersion: 1,
                           profileVersion: 1,
                           dataSize: 12345)
    
    file.header = header
        
    guard let fileData = try? file.toData() else {
      XCTFail("Couldn't generate FIT file data.")
      return
    }
    
    let restoredFile = FitFile(data: fileData)
    
    XCTAssert(restoredFile?.messages.count == 1)
    XCTAssert(restoredFile?.messages.first is ActivityMessage)
  }
  
  func testFileIdMessageSavingAndRestoring() {
    let message = FileIdMessage(type: .activity,
                                manufacturer: 1234,
                                product: 4321,
                                serialNumber: 3333,
                                timeCreated: Date())
    
    let messageData = message.data
    
    let restoredMessage = FileIdMessage(data: messageData,
                                        bytePosition: 0,
                                        fields: message.generateMessageDefinition().fields,
                                        localMessageNumber: 0)
    
    XCTAssert(message.type == restoredMessage?.type)
    XCTAssert(message.manufacturer == restoredMessage?.manufacturer)
    XCTAssert(message.product == restoredMessage?.product)
    XCTAssert(message.serialNumber == restoredMessage?.serialNumber)
    
    // Close enough?
    XCTAssert(abs(message.timeCreated.timeIntervalSince(restoredMessage!.timeCreated)) < 1)
  }
  
  func testActivityMessageSavingAndRestoring() {
    let message = ActivityMessage(totalTimerTime: 1000000,
                                  timestamp: Date(),
                                  numberOfSessions: 1,
                                  type: .transition,
                                  event: .cadenceHighAlert,
                                  eventType: .marker)
    
    let messageData = message.data
    
    let restoredMessage = ActivityMessage(data: messageData,
                                          bytePosition: 0,
                                          fields: message.generateMessageDefinition().fields,
                                          localMessageNumber: 0)
    
    XCTAssert(message.totalTimerTime == restoredMessage?.totalTimerTime)
    XCTAssert(abs(message.timestamp.timeIntervalSince(restoredMessage!.timestamp)) < 1)
    XCTAssert(message.numberOfSessions == restoredMessage?.numberOfSessions)
    XCTAssert(message.event == restoredMessage?.event)
    XCTAssert(message.eventType == restoredMessage?.eventType)
    XCTAssert(message.type == restoredMessage?.type)
  }
  
  func testDeviceInfoMessageSavingAndRestoring() {
    let message = DeviceInfoMessage(timestamp: Date(),
                                    serialNumber: 123456,
                                    manufacturer: .favero_electronics)
    
    let messageData = message.data
    
    let restoredMessage = DeviceInfoMessage(data: messageData,
                                          bytePosition: 0,
                                          fields: message.generateMessageDefinition().fields,
                                          localMessageNumber: 0)
    
    XCTAssert(abs(message.timestamp.timeIntervalSince(restoredMessage!.timestamp)) < 1)
    XCTAssert(message.serialNumber == restoredMessage?.serialNumber)
    XCTAssert(message.manufacturer == restoredMessage?.manufacturer)
  }
  
    static var allTests = [
        ("testExample", testExample),
    ]
}
