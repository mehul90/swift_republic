//
//  Source_File.swift
//  Organization name
//
//  Created by Mehul M. Parmar on 06/01/20.
//  Copyright © 2019 Mehul. All rights reserved.
//

import Foundation

public protocol SampleProtocol {
  func firstInterfaceMethod()
  func secondInterfaceMethod()
  var property1: String { get }
  var property2: Bool? { get set }
}

public enum SampleEnum {
  case one
  case two(String, Bool)
  case unknown
}

public struct SampleStruct: SampleProtocol {
  public var property1: String
  public var property2: Bool?  // some description
  public var propertyWithDefaultValue: String? = "ABC"

  public struct InnerStruct {
    public var propA: Int
    public var propB: Int
    
    public var someComputedProperty: String {
      return "someComputedProperty"
    }
    
    public func someFunc(param: Int) {
      print (param)
    }

    public init(propA: Int, propB: Int) {
      self.propA = propA
      self.propB = propB
    }
  }
  
  public func firstInterfaceMethod() {
    // implementation
    // implementation
  }
  
  public func secondInterfaceMethod() {
    // implementation
    // implementation
  }

  public let anotherProperty: SampleEnum

  public init(property1: String, property2: Bool?, propertyWithDefaultValue: String? = "ABC", anotherProperty: SampleEnum) {
    self.property1 = property1
    self.property2 = property2
    self.propertyWithDefaultValue = propertyWithDefaultValue
    self.anotherProperty = anotherProperty
  }
}

public struct SomeDataModel {
  public struct Request {
    public var reqParam1: String
    public var reqParam2: Double

    public init(reqParam1: String, reqParam2: Double) {
      self.reqParam1 = reqParam1
      self.reqParam2 = reqParam2
    }
  }
  
  public struct Response {
    public var respParam1: Data
    public var respParam2: String

    public init(respParam1: Data, respParam2: String) {
      self.respParam1 = respParam1
      self.respParam2 = respParam2
    }
  }
}

extension SampleStruct {
  
  public func someMethod() {
    someMoreMethod()
  }
  
  private func someMoreMethod() {
    // implementation
    // implementation
  }
}

extension SampleStruct.InnerStruct {
  public init(withJSONValue value: Int) {
    guard value > 0 else {
      fatalError()
    }
    propA = value
    propB = value
  }
}
