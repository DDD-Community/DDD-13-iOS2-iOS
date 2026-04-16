//
//  StorageKey.swift
//  Utill
//
//  Created by DDD-iOS2 on 4/16/26.
//  Copyright (c) 2025 DDD, Ltd., All rights reserved.
//

import Foundation

/// 키체인 저장 키
public enum KeyChainKey {
    public static let accessToken = "accessToken"
    public static let refreshToken = "refreshToken"
}

/// UserDefaults 저장 키
public enum UserDefaultsKey {
    public static let isLogin = "isLogin"
    public static let tokenIssueDate = "tokenIssueDate"
}
