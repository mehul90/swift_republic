//
//  Source_File.swift
//  Organization name
//
//  Created by Mehul M. Parmar on 06/01/20.
//  Copyright © 2019 Mehul. All rights reserved.
//

import Foundation

protocol SampleProtocol {
  func firstInterfaceMethod()
  func secondInterfaceMethod()
  var property1: String { get }
  var property2: Bool? { get set }
}

enum SampleEnum {
  case one
  case two(String, Bool)
  case unknown
}

struct SampleStruct: SampleProtocol {
  var property1: String
  var property2: Bool?  // some description
  var propertyWithDefaultValue: String? = "ABC"

  struct InnerStruct {
    var propA: Int
    var propB: Int
    
    var someComputedProperty: String {
      return "someComputedProperty"
    }
    
    func someFunc(param: Int) {
      print (param)
    }
  }
  
  func firstInterfaceMethod() {
    // implementation
    // implementation
  }
  
  func secondInterfaceMethod() {
    // implementation
    // implementation
  }

  let anotherProperty: SampleEnum
}

struct SomeDataModel {
  struct Request {
    var reqParam1: String
    var reqParam2: Double
  }
  
  struct Response {
    var respParam1: Data
    var respParam2: String
  }
}

extension SampleStruct {
  
  func someMethod() {
    someMoreMethod()
  }
  
  private func someMoreMethod() {
    // implementation
    // implementation
  }
}

extension SampleStruct.InnerStruct {
  init(withJSONValue value: Int) {
    guard value > 0 else {
      fatalError()
    }
    propA = value
    propB = value
  }
}
