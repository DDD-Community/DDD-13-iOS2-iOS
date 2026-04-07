//
//  Modules.swift
//  Plugins
//
//  Created by DDD-iOS2 on 4/7/26.
//

import Foundation
import ProjectDescription

public enum ModulePath {
  case Presentation(Presentations)
  case Network(Networks)
  case Domain(Domains)
  case Data(Datas)
  case Shared(Shareds)
}

// MARK: FeatureModule
public extension ModulePath {
  enum Presentations: String, CaseIterable {
    case Presentation


    public static let name: String = "Presentation"
  }
}



//MARK: -  CoreDomainModule
public extension ModulePath {
  enum Networks: String, CaseIterable {
    case Networking
    case Foundations

    public static let name: String = "Network"
  }
}

//MARK: -  CoreMoudule
public extension ModulePath {
  enum Datas: String, CaseIterable {
    case Model
    case Data
    case Repository
    case API
    case Service

    public static let name: String = "Data"
  }
}


//MARK: -  CoreMoudule
public extension ModulePath {
  enum Domains: String, CaseIterable {
    case Entity
    case UseCase
    case Domain
    case DataInterface
    case DomainInterface


    public static let name: String = "Domain"
  }
}


public extension ModulePath {
  enum Shareds: String, CaseIterable {
    case Shared
    case DesignSystem
    case Utill
    
    public static let name: String = "Shared"
  }
}


