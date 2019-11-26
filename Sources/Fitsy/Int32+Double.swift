//
//  File.swift
//  
//
//  Created by Paul MacRory on 23/11/2019.
//

import Foundation

private let semiToDegFactor: Double = 180 / pow(2, 31)
private let degreesToSemiFactor: Double = pow(2, 31) / 180

extension Int32 {
  var semiCirclesToDegrees: Double {
    return Double(self) * semiToDegFactor
  }
}

extension Double {
  var degreesToSemiCircles: Int32 {
    return Int32(self * degreesToSemiFactor)
  }
}
