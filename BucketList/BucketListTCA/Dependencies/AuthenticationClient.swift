//
//  AuthenticationClient.swift
//  BucketListTCA
//
//  Created by hn on 2025/12/5.
//

import Dependencies
import LocalAuthentication

struct AuthenticationClient {
    var authenticate: @Sendable () async -> Result<Void, any Error>
}

private enum AuthenticationClientKey: DependencyKey {
    static let liveValue = AuthenticationClient {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate yourself to unlock your places."
            do {
                try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
                return .success(())
            } catch {
                return .failure(error)
            }
        }else {
            // no biometrics
            return .success(())
        }
    }
}

extension DependencyValues {
    var authenticationClient: AuthenticationClient {
        get { self[AuthenticationClientKey.self] }
        set { self[AuthenticationClientKey.self] = newValue }
    }
}
