//
//  File.swift
//  
//
//  Created by Paul MacRory on 24/11/2019.
//

import Foundation

enum FitBaseType: UInt8 {
  case invalid               = 0xFF
  case `enum`                = 0
  case sint8                 = 1
  case uint8                 = 2
  case sint16                = 131
  case uint16                = 132
  case sint32                = 133
  case uint32                = 134
  case string                = 7
  case float32               = 136
  case float64               = 137
  case uint8z                = 10
  case uint16z               = 139
  case uint32z               = 140
  case byte                  = 13
  case sint64                = 142
  case uint64                = 143
  case uint64z               = 144
}
