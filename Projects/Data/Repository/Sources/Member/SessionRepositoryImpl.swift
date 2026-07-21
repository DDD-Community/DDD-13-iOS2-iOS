import Foundation

import DataInterface
import Utill

public final class SessionRepositoryImpl: SessionRepositoryProtocol {
    public init() {}

    public func clearLocalSession() {
        KeyChainManager.deleteItem(key: KeyChainKey.accessToken)
        KeyChainManager.deleteItem(key: KeyChainKey.refreshToken)
        UserDefaults.standard.set(false, forKey: UserDefaultsKey.isLogin)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.registrationCompleted)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.tokenIssueDate)
    }
}
