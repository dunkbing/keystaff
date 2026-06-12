//
//  AdsConfig.swift
//  jisho
//
//  Google AdMob configuration and lifecycle helpers.
//

import GoogleMobileAds
import UIKit

enum AdUnitIDs {
    #if DEBUG
    static let banner = "ca-app-pub-3940256099942544/2934735716"  // Google test banner
    static let native = "ca-app-pub-3940256099942544/3986624511"  // Google test native
    #else
    static let banner = "ca-app-pub-5895413516232256/5406000806"
    static let native = "ca-app-pub-5895413516232256/6750872062"
    #endif
}

enum AdsManager {
    /// Starts the Mobile Ads SDK. Safe to call multiple times.
    static func start() {
        Task { @MainActor in
            MobileAds.shared.start(completionHandler: nil)
        }
    }

    /// Resolves the key window's root view controller, required by banner and
    /// native ads to present full-screen content from a SwiftUI app.
    @MainActor
    static func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
    }
}
