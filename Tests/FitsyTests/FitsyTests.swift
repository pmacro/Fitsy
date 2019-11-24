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

    static var allTests = [
        ("testExample", testExample),
    ]
}
