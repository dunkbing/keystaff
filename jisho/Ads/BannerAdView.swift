//
//  BannerAdView.swift
//  jisho
//
//  SwiftUI wrapper around a GoogleMobileAds BannerView.
//

import GoogleMobileAds
import SwiftUI

struct BannerAdView: View {
    var body: some View {
        BannerRepresentable()
            .frame(height: 50)
    }
}

private struct BannerRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AdUnitIDs.banner
        banner.rootViewController = AdsManager.rootViewController()
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        if uiView.rootViewController == nil {
            uiView.rootViewController = AdsManager.rootViewController()
        }
    }
}
