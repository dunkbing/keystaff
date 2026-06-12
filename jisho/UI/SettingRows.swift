//
//  SettingRows.swift
//  jisho
//
//  Vendored from TikimUI
//

import SwiftUI

public struct SettingRowWithIcon: View {
    let iconType: SettingIconType
    let color: Color
    let title: String
    let value: String?
    let showChevron: Bool

    public init(
        icon: String,
        color: Color,
        title: String,
        value: String? = nil,
        showChevron: Bool = false
    ) {
        self.iconType = .systemName(icon)
        self.color = color
        self.title = title
        self.value = value
        self.showChevron = showChevron
    }

    public init(
        iconType: SettingIconType,
        color: Color,
        title: String,
        value: String? = nil,
        showChevron: Bool = false
    ) {
        self.iconType = iconType
        self.color = color
        self.title = title
        self.value = value
        self.showChevron = showChevron
    }

    // Convenience initializer for UIImage
    public init(
        uiImage: UIImage,
        color: Color,
        title: String,
        value: String? = nil,
        showChevron: Bool = false
    ) {
        self.iconType = .uiImage(uiImage)
        self.color = color
        self.title = title
        self.value = value
        self.showChevron = showChevron
    }

    // Convenience initializer for SwiftUI Image
    public init(
        image: Image,
        color: Color,
        title: String,
        value: String? = nil,
        showChevron: Bool = false
    ) {
        self.iconType = .image(image)
        self.color = color
        self.title = title
        self.value = value
        self.showChevron = showChevron
    }

    public var body: some View {
        HStack {
            SettingIcon(iconType: iconType, color: color)

            Text(LocalizedStringKey(title))
                .font(.body)
                .foregroundColor(Color.appText)

            Spacer()

            if let value = value {
                Text(LocalizedStringKey(value))
                    .font(.body)
                    .foregroundColor(Color.appSubtitle)
                    .padding(.trailing, showChevron ? 4 : 0)
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.appSubtitle)
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 6)
        .padding(.horizontal)
    }
}

public struct ToggleSettingRow: View {
    let iconType: SettingIconType
    let color: Color
    let title: String
    let isOn: Bool
    let action: () -> Void
    @Namespace private var animation

    // Convenience initializer for system icons (backwards compatibility)
    public init(
        icon: String,
        color: Color,
        title: String,
        isOn: Bool,
        action: @escaping () -> Void
    ) {
        self.iconType = .systemName(icon)
        self.color = color
        self.title = title
        self.isOn = isOn
        self.action = action
    }

    // New initializer for different icon types
    public init(
        iconType: SettingIconType,
        color: Color,
        title: String,
        isOn: Bool,
        action: @escaping () -> Void
    ) {
        self.iconType = iconType
        self.color = color
        self.title = title
        self.isOn = isOn
        self.action = action
    }

    // Convenience initializer for UIImage
    public init(
        uiImage: UIImage,
        color: Color,
        title: String,
        isOn: Bool,
        action: @escaping () -> Void
    ) {
        self.iconType = .uiImage(uiImage)
        self.color = color
        self.title = title
        self.isOn = isOn
        self.action = action
    }

    public var body: some View {
        HStack {
            SettingIcon(iconType: iconType, color: color)

            Text(LocalizedStringKey(title))
                .font(.body)
                .foregroundColor(Color.appText)

            Spacer()

            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .frame(width: 42, height: 28)
                    .foregroundColor(isOn ? Color.appGreen : Color.appSurface2)

                Circle()
                    .foregroundColor(Color.appBackground)
                    .padding(2)
                    .frame(width: 28, height: 28)
                    .matchedGeometryEffect(id: "toggle\(iconType.id)", in: animation)
            }
            .onTapGesture {
                withAnimation(.spring(dampingFraction: 0.7)) {
                    action()
                }
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 6)
        .padding(.horizontal)
    }
}

public enum SettingIconType {
    case systemName(String)
    case uiImage(UIImage)
    case image(Image)
}

extension SettingIconType {
    var id: String {
        switch self {
        case .systemName(let name):
            return "system_\(name)"
        case .uiImage(let image):
            return "uiimage_\(image.hashValue)"
        case .image(_):
            return "image_\(UUID().uuidString)"
        }
    }
}

// MARK: - Enhanced SettingIcon
fileprivate struct SettingIcon: View {
    let iconType: SettingIconType
    let color: Color
    private var size: CGFloat = 16

    public init(iconType: SettingIconType, color: Color) {
        self.iconType = iconType
        self.color = color
    }

    public var body: some View {
        Group {
            switch iconType {
            case .systemName(let name):
                Image(systemName: name)
                    .font(.system(size: size, weight: .semibold))
                    .foregroundColor(.white)
            case .uiImage(let uiImage):
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
            case .image(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
            }
        }
        .frame(width: size, height: size)
        .frame(width: size + 16, height: size + 16)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
