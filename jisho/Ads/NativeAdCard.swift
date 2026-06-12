//
//  NativeAdCard.swift
//  jisho
//
//  SwiftUI wrapper around a GoogleMobileAds NativeAdView.
//

import Combine
import GoogleMobileAds
import SwiftUI

@MainActor
final class NativeAdController: NSObject, ObservableObject, NativeAdLoaderDelegate {
    @Published var nativeAd: NativeAd?
    private var adLoader: AdLoader?

    func loadIfNeeded() {
        guard nativeAd == nil, adLoader == nil,
            let rootVC = AdsManager.rootViewController()
        else { return }
        let loader = AdLoader(
            adUnitID: AdUnitIDs.native,
            rootViewController: rootVC,
            adTypes: [.native],
            options: nil
        )
        loader.delegate = self
        loader.load(Request())
        adLoader = loader
    }

    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        self.nativeAd = nativeAd
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: any Error) {
        self.adLoader = nil  // allow a retry next time the view appears
    }
}

struct NativeAdCard: View {
    @StateObject private var controller = NativeAdController()

    var body: some View {
        Group {
            if let ad = controller.nativeAd {
                NativeAdRepresentable(nativeAd: ad)
                    .frame(height: 68)
                    .padding(12)
                    .background(
                        Color.appSurface1,
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )
            }
        }
        .onAppear { controller.loadIfNeeded() }
    }
}

private struct NativeAdRepresentable: UIViewRepresentable {
    let nativeAd: NativeAd

    func makeUIView(context: Context) -> NativeAdView {
        let adView = NativeAdView()

        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFill
        icon.clipsToBounds = true
        icon.layer.cornerRadius = 10
        icon.image = nativeAd.icon?.image

        let headline = UILabel()
        headline.font = .systemFont(ofSize: 15, weight: .bold)
        headline.numberOfLines = 1
        headline.text = nativeAd.headline

        let body = UILabel()
        body.font = .systemFont(ofSize: 12)
        body.textColor = .secondaryLabel
        body.numberOfLines = 2
        body.text = nativeAd.body

        let adBadge = UILabel()
        adBadge.text = "Ad"
        adBadge.font = .systemFont(ofSize: 9, weight: .bold)
        adBadge.textColor = .white
        adBadge.backgroundColor = UIColor(Color.appAccent)
        adBadge.textAlignment = .center
        adBadge.layer.cornerRadius = 3
        adBadge.clipsToBounds = true
        adBadge.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [headline, body])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let cta = UIButton(type: .system)
        cta.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = UIColor(Color.appAccent)
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14)
        config.title = nativeAd.callToAction
        config.titleTextAttributesTransformer = .init { attrs in
            var copy = attrs
            copy.font = .systemFont(ofSize: 13, weight: .semibold)
            return copy
        }
        cta.configuration = config
        cta.isUserInteractionEnabled = false  // SDK handles the tap

        adView.addSubview(icon)
        adView.addSubview(adBadge)
        adView.addSubview(textStack)
        adView.addSubview(cta)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            icon.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 44),
            icon.heightAnchor.constraint(equalToConstant: 44),

            adBadge.leadingAnchor.constraint(equalTo: icon.leadingAnchor),
            adBadge.topAnchor.constraint(equalTo: icon.topAnchor),
            adBadge.widthAnchor.constraint(equalToConstant: 18),
            adBadge.heightAnchor.constraint(equalToConstant: 12),

            textStack.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            textStack.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: cta.leadingAnchor, constant: -10),

            cta.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            cta.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
        ])

        adView.iconView = icon
        adView.headlineView = headline
        adView.bodyView = body
        adView.callToActionView = cta
        adView.nativeAd = nativeAd  // register last
        return adView
    }

    func updateUIView(_ uiView: NativeAdView, context: Context) {}
}
