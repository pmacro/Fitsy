//
//  File.swift
//  
//
//  Created by Paul MacRory on 23/11/2019.
//

import Foundation

private let semiToDegFactor: Double = 180 / pow(2, 31)

extension Int32 {
  var semiCirclesToDegrees: Double {
    return Double(self) * semiToDegFactor
  }
}
