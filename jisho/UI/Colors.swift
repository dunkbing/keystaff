import SwiftUI

struct ColorsPalette {
    struct Latte {
        static let rosewater = Color(hex: "#dc8a78")
        static let flamingo = Color(hex: "#dd7878")
        static let pink = Color(hex: "#ea76cb")
        static let mauve = Color(hex: "#8839ef")
        static let red = Color(hex: "#d20f39")
        static let maroon = Color(hex: "#e64553")
        static let peach = Color(hex: "#fe640b")
        static let yellow = Color(hex: "#df8e1d")
        static let green = Color(hex: "#40a02b")
        static let teal = Color(hex: "#179299")
        static let sky = Color(hex: "#04a5e5")
        static let sapphire = Color(hex: "#209fb5")
        static let blue = Color(hex: "#1e66f5")
        static let lavender = Color(hex: "#7287fd")

        static let text = Color(hex: "#4c4f69")
        static let subtext1 = Color(hex: "#5c5f77")
        static let subtext0 = Color(hex: "#6c6f85")
        static let overlay2 = Color(hex: "#7c7f93")
        static let overlay1 = Color(hex: "#8c8fa1")
        static let overlay0 = Color(hex: "#9ca0b0")
        static let surface2 = Color(hex: "#acb0be")
        static let surface1 = Color(hex: "#bcc0cc")
        static let surface0 = Color(hex: "#ccd0da")
        static let base = Color(hex: "#eff1f5")
        static let mantle = Color(hex: "#e6e9ef")
        static let crust = Color(hex: "#dce0e8")
    }

    struct Macchiato {
        static let rosewater = Color(hex: "#f4dbd6")
        static let flamingo = Color(hex: "#f0c6c6")
        static let pink = Color(hex: "#f5bde6")
        static let mauve = Color(hex: "#c6a0f6")
        static let red = Color(hex: "#ed8796")
        static let maroon = Color(hex: "#ee99a0")
        static let peach = Color(hex: "#f5a97f")
        static let yellow = Color(hex: "#eed49f")
        static let green = Color(hex: "#a6da95")
        static let teal = Color(hex: "#8bd5ca")
        static let sky = Color(hex: "#91d7e3")
        static let sapphire = Color(hex: "#7dc4e4")
        static let blue = Color(hex: "#8aadf4")
        static let lavender = Color(hex: "#b7bdf8")

        static let text = Color(hex: "#cad3f5")
        static let subtext1 = Color(hex: "#b8c0e0")
        static let subtext0 = Color(hex: "#a5adcb")
        static let overlay2 = Color(hex: "#939ab7")
        static let overlay1 = Color(hex: "#8087a2")
        static let overlay0 = Color(hex: "#6e738d")
        static let surface2 = Color(hex: "#5b6078")
        static let surface1 = Color(hex: "#494d64")
        static let surface0 = Color(hex: "#363a4f")
        static let base = Color(hex: "#24273a")
        static let mantle = Color(hex: "#1e2030")
        static let crust = Color(hex: "#181926")
    }

    struct Vietnamese {
        // Vietnamese flag colors and complementary shades
        static let red = Color(hex: "#DA251D")        // Vietnamese flag red
        static let yellow = Color(hex: "#FFCD00")     // Vietnamese flag yellow
        static let darkRed = Color(hex: "#B91C17")    // Darker red
        static let lightRed = Color(hex: "#F54A45")   // Lighter red
        static let darkYellow = Color(hex: "#D6AD00") // Darker yellow
        static let lightYellow = Color(hex: "#FFD633") // Lighter yellow

        // Text and background colors
        static let text = Color(hex: "#1A1A1A")       // Near black
        static let subtext1 = Color(hex: "#333333")
        static let subtext0 = Color(hex: "#4D4D4D")
        static let overlay2 = Color(hex: "#666666")
        static let overlay1 = Color(hex: "#808080")
        static let overlay0 = Color(hex: "#999999")
        static let surface2 = Color(hex: "#B3B3B3")
        static let surface1 = Color(hex: "#CCCCCC")
        static let surface0 = Color(hex: "#E6E6E6")
        static let base = Color(hex: "#F2F2F2")       // Off-white/cream background
        static let mantle = Color(hex: "#FAFAFA")
        static let crust = Color(hex: "#FFFFFF")

        // Accent colors
        static let blue = Color(hex: "#228AE6")       // Complementary blue
        static let green = Color(hex: "#28A745")      // Success/positive color
        static let pink = Color(hex: "#DC3545")       // Alternative highlight color
        static let mauve = Color(hex: "#6F42C1")      // Purple accent
        static let peach = Color(hex: "#FD7E14")      // Orange accent
        static let teal = Color(hex: "#20C997")       // Teal accent
    }

    struct Bubblegum {
        // Main pink shades
        static let pink = Color(hex: "#FF99C8")         // A brighter, clearer bubblegum pink
        static let hotPink = Color(hex: "#FF69B4")      // Classic, vibrant hot pink
        static let pastelPink = Color(hex: "#FFD1DC")    // Still a very light pastel
        static let deepPink = Color(hex: "#FF1493")      // Much deeper and more saturated
        static let blush = Color(hex: "#F08080")        // A more noticeable, warm blush

        // Complementary colors
        static let lavender = Color(hex: "#D8BFD8")      // Softer, clearer lavender
        static let mint = Color(hex: "#98FB98")          // Brighter, more distinct mint
        static let peach = Color(hex: "#FFDAB9")         // Paler and more clearly peach
        static let skyBlue = Color(hex: "#87CEEB")       // A more vibrant sky blue
        static let buttercup = Color(hex: "#FFFACD")     // A light, creamy yellow

        // Text and background colors - adjusted surface for visibility
        static let text = Color(hex: "#2E1519")         // A deep, dark reddish-purple for high contrast
        static let subtext1 = Color(hex: "#52393D")
        static let subtext0 = Color(hex: "#765D61")
        static let overlay2 = Color(hex: "#9A8185")
        static let overlay1 = Color(hex: "#BEA5A9")
        static let overlay0 = Color(hex: "#E2C9CD")
        static let surface2 = Color(hex: "#F9E2E6")
        static let surface1 = Color(hex: "#FFECF0")
        static let surface0 = Color(hex: "#FFE3E8")      // Slightly darker, but still light pink
        static let base = Color(hex: "#FFF5FA")          // Kept as a very light base
        static let mantle = Color(hex: "#FFEDF5")
        static let crust = Color(hex: "#FFE5F0")

        // Accent colors
        static let red = Color(hex: "#FF6F61")           // A more vibrant reddish-pink
        static let yellow = Color(hex: "#FFDB58")        // A clearer, more golden yellow
        static let green = Color(hex: "#90EE90")         // A brighter light green
        static let blue = Color(hex: "#ADD8E6")          // A softer, clearer light blue
        static let purple = Color(hex: "#BA55D3")        // A more vibrant medium purple

        // Define app-specific colors with better contrast for the empty columns
        static let appText = text
        static let appSurface = Color(hex: "#FFE3E8")     // A slightly more visible light pink for the base
        static let appAccent = hotPink
    }

    struct Sparkle {
        // Main accent colors - vibrant pastels with better contrast
        static let lavender = Color(hex: "#9D78FF")      // Deeper purple
        static let mintGreen = Color(hex: "#67D99E")     // Stronger mint
        static let babyBlue = Color(hex: "#73BDDE")      // Deeper sky blue
        static let peach = Color(hex: "#FF9B76")         // Stronger peach/coral
        static let lemonYellow = Color(hex: "#FFDF4F")   // Stronger yellow
        static let cottonCandy = Color(hex: "#FF9ECE")   // Brighter pink
        static let aqua = Color(hex: "#4CD9CB")          // Stronger teal/aqua
        static let lilac = Color(hex: "#BF92FF")         // Deeper light purple
        static let coral = Color(hex: "#FF6B78")         // Stronger coral

        // Rainbow gradient colors - more vibrant
        static let rainbowRed = Color(hex: "#FF7A85")    // Stronger red
        static let rainbowOrange = Color(hex: "#FFBA8C") // Stronger orange
        static let rainbowYellow = Color(hex: "#FFED74") // Stronger yellow
        static let rainbowGreen = Color(hex: "#89E0BB")  // Stronger green
        static let rainbowBlue = Color(hex: "#92ADDE")   // Stronger blue
        static let rainbowPurple = Color(hex: "#CE9CFF") // Stronger purple

        // Text and background colors with better contrast
        static let text = Color(hex: "#464646")          // Darker gray for text
        static let subtext1 = Color(hex: "#5A5A5A")      // Darker
        static let subtext0 = Color(hex: "#6E6E6E")      // Darker
        static let overlay2 = Color(hex: "#858585")      // Darker
        static let overlay1 = Color(hex: "#9E9E9E")      // Darker
        static let overlay0 = Color(hex: "#B8B8B8")      // Darker

        // Surface colors with more distinct steps
        static let surface2 = Color(hex: "#D4D4D4")      // Much darker surface
        static let surface1 = Color(hex: "#E5E5E5")      // Darker surface
        static let surface0 = Color(hex: "#F0F0F0")      // Slightly darker surface
        static let base = Color(hex: "#FFFFFF")          // White background
        static let mantle = Color(hex: "#FCFCFC")
        static let crust = Color(hex: "#F5F5F5")

        // Special accent colors
        static let primary = lavender                    // Primary theme color
        static let secondary = mintGreen                 // Secondary theme color
        static let success = aqua                        // Success/positive color
        static let warning = lemonYellow                 // Warning color
        static let error = coral                         // Error color
        static let info = babyBlue                       // Information color

        // App-specific colors
        static let appText = text
        static let appSurface = Color(hex: "#FCFAFF")    // Very light lavender-tinted white
        static let appAccent = primary                   // Main accent color
        static let appSecondary = secondary              // Secondary accent color
    }

    struct Ghibli {
        // Main accent colors inspired by iconic Ghibli films
        static let meadow = Color(hex: "#94C973")         // Totoro meadow green
        static let forestSpirit = Color(hex: "#5A9367")   // Deeper forest green
        static let skyBlue = Color(hex: "#71B3CF")        // Castle in the Sky blue
        static let spiritedAway = Color(hex: "#DF6B88")   // Chihiro's outfit pink
        static let calcifer = Color(hex: "#FF9642")       // Howl's Moving Castle fire
        static let sootSprite = Color(hex: "#454545")     // Soot sprite dark gray
        static let dustBunny = Color(hex: "#808080")      // Dust bunny gray
        static let ponyo = Color(hex: "#EF5B5B")          // Ponyo red
        static let haku = Color(hex: "#68C4B9")           // Dragon Haku teal

        // Earthy Ghibli landscape colors
        static let earthBrown = Color(hex: "#9E7E67")     // Natural earth tones
        static let susuwatari = Color(hex: "#2D2D2D")     // Dark charcoal
        static let nausicaa = Color(hex: "#8975B4")       // Purple from Nausicaa
        static let ashitaka = Color(hex: "#BF8C60")       // Mononoke earth tone
        static let sandGold = Color(hex: "#DBBC85")       // Nausicaa desert

        // Ghibli sky and natural colors
        static let sunsetGold = Color(hex: "#F0BC61")     // Golden sunset
        static let laputa = Color(hex: "#7AA1D2")         // Sky kingdom blue
        static let makkuro = Color(hex: "#31394D")        // Deep night blue
        static let zeniba = Color(hex: "#B88E71")         // Warm cottage brown

        // Text and background colors - soft natural tones
        static let text = Color(hex: "#3A3A3A")           // Natural dark gray
        static let subtext1 = Color(hex: "#4A4A4A")
        static let subtext0 = Color(hex: "#5C5C5C")
        static let overlay2 = Color(hex: "#727272")
        static let overlay1 = Color(hex: "#898989")
        static let overlay0 = Color(hex: "#A0A0A0")

        // Surface colors - soft parchment-like background
        static let surface2 = Color(hex: "#CCC5B9")       // Paper-like texture
        static let surface1 = Color(hex: "#DCD5C9")       // Lighter parchment
        static let surface0 = Color(hex: "#E8E2D6")       // Soft cream
        static let base = Color(hex: "#F5F0E5")           // Light parchment background
        static let mantle = Color(hex: "#EAE5DA")         // Subtle texture
        static let crust = Color(hex: "#DFD9CE")          // Slightly darker edge

        // Special accent colors
        static let primary = meadow                        // Primary theme color
        static let secondary = skyBlue                     // Secondary theme color
        static let success = forestSpirit                  // Success/positive color
        static let warning = calcifer                      // Warning color
        static let error = ponyo                           // Error color
        static let info = laputa                           // Information color

        // App-specific colors
        static let appText = text
        static let appSurface = Color(hex: "#F5F0E5")      // Parchment-like white
        static let appAccent = primary                     // Main accent color
        static let appSecondary = secondary                // Secondary accent color
    }
}

// Extension to create colors from hex values
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    public static var appBackground: Color {
        AppColors.dynamicColor(
            light: ColorsPalette.Latte.base,
            dark: ColorsPalette.Macchiato.base,
            vietnam: ColorsPalette.Vietnamese.base,
            bubblegum: ColorsPalette.Bubblegum.base,
            sparkle: ColorsPalette.Sparkle.base,
            ghibli: ColorsPalette.Ghibli.base)
    }

    public static var appText: Color {
        AppColors.dynamicColor(
            light: ColorsPalette.Latte.text,
            dark: ColorsPalette.Macchiato.text,
            vietnam: ColorsPalette.Vietnamese.text,
            bubblegum: ColorsPalette.Bubblegum.text,
            sparkle: ColorsPalette.Sparkle.text,
            ghibli: ColorsPalette.Ghibli.text)
    }

    public static var appSubtitle: Color {
        AppColors.dynamicColor(
            light: ColorsPalette.Latte.subtext0,
            dark: ColorsPalette.Macchiato.subtext0,
            vietnam: ColorsPalette.Vietnamese.subtext0,
            bubblegum: ColorsPalette.Bubblegum.subtext0,
            sparkle: ColorsPalette.Sparkle.subtext0,
            ghibli: ColorsPalette.Ghibli.subtext0)
    }

    public static var appAccent: Color {
        AppColors.dynamicColor(
            light: ColorsPalette.Latte.blue,
            dark: ColorsPalette.Macchiato.blue,
            vietnam: ColorsPalette.Vietnamese.red,
            bubblegum: ColorsPalette.Bubblegum.pink,
            sparkle: ColorsPalette.Sparkle.primary,
            ghibli: ColorsPalette.Ghibli.primary)
    }

    public static var appSecondaryAccent: Color {
        AppColors.dynamicColor(
            light: ColorsPalette.Latte.mauve,
            dark: ColorsPalette.Macchiato.mauve,
            vietnam: ColorsPalette.Vietnamese.yellow,
            bubblegum: ColorsPalette.Bubblegum.lavender,
            sparkle: ColorsPalette.Sparkle.secondary,
            ghibli: ColorsPalette.Ghibli.secondary)
    }

    public static var appGreen: Color {
        AppColors.dynamicColor(
            light: ColorsPalette.Latte.green,
            dark: ColorsPalette.Macchiato.green,
            vietnam: ColorsPalette.Vietnamese.green,
            bubblegum: ColorsPalette.Bubblegum.green,
            sparkle: ColorsPalette.Sparkle.mintGreen,
            ghibli: ColorsPalette.Ghibli.forestSpirit)
    }

    public static var appRed: Color {
        AppColors.dynamicColor(
            light: ColorsPalette.Latte.red,
            dark: ColorsPalette.Macchiato.red,
            vietnam: ColorsPalette.Vietnamese.red,
            bubblegum: ColorsPalette.Bubblegum.red,
            sparkle: ColorsPalette.Sparkle.coral,
            ghibli: ColorsPalette.Ghibli.ponyo)
    }

    public static var appOrange: Color {
        AppColors.dynamicColor(
            light: ColorsPalette.Latte.peach,
            dark: ColorsPalette.Macchiato.peach,
            vietnam: ColorsPalette.Vietnamese.peach,
            bubblegum: ColorsPalette.Bubblegum.peach,
            sparkle: ColorsPalette.Sparkle.peach,
            ghibli: ColorsPalette.Ghibli.calcifer)
    }

    public static var appYellow: Color {
        AppColors.dynamicColor(
            light: ColorsPalette.Latte.yellow,
            dark: ColorsPalette.Macchiato.yellow,
            vietnam: ColorsPalette.Vietnamese.yellow,
            bubblegum: ColorsPalette.Bubblegum.yellow,
            sparkle: ColorsPalette.Sparkle.lemonYellow,
            ghibli: ColorsPalette.Ghibli.sunsetGold)
    }

    public static var appSurface: Color {
        AppColors.dynamicColor(
            light: ColorsPalette.Latte.surface0,
            dark: ColorsPalette.Macchiato.surface0,
            vietnam: ColorsPalette.Vietnamese.surface0,
            bubblegum: ColorsPalette.Bubblegum.surface0,
            sparkle: ColorsPalette.Sparkle.surface0,
            ghibli: ColorsPalette.Ghibli.surface0)
    }

    public static var appSurface1: Color {
        AppColors.dynamicColor(
            light: ColorsPalette.Latte.surface1,
            dark: ColorsPalette.Macchiato.surface1,
            vietnam: ColorsPalette.Vietnamese.surface1,
            bubblegum: ColorsPalette.Bubblegum.surface1,
            sparkle: ColorsPalette.Sparkle.surface1,
            ghibli: ColorsPalette.Ghibli.surface1)
    }

    public static var appSurface2: Color {
        AppColors.dynamicColor(
            light: ColorsPalette.Latte.surface2,
            dark: ColorsPalette.Macchiato.surface2,
            vietnam: ColorsPalette.Vietnamese.surface2,
            bubblegum: ColorsPalette.Bubblegum.surface2,
            sparkle: ColorsPalette.Sparkle.surface2,
            ghibli: ColorsPalette.Ghibli.surface2)
    }

    public static var appCrust: Color {
        AppColors.dynamicColor(
            light: ColorsPalette.Latte.crust,
            dark: ColorsPalette.Macchiato.crust,
            vietnam: ColorsPalette.Vietnamese.crust,
            bubblegum: ColorsPalette.Bubblegum.crust,
            sparkle: ColorsPalette.Sparkle.crust,
            ghibli: ColorsPalette.Ghibli.crust)
    }

    public static var appMantle: Color {
        AppColors.dynamicColor(
            light: ColorsPalette.Latte.mantle,
            dark: ColorsPalette.Macchiato.mantle,
            vietnam: ColorsPalette.Vietnamese.mantle,
            bubblegum: ColorsPalette.Bubblegum.mantle,
            sparkle: ColorsPalette.Sparkle.mantle,
            ghibli: ColorsPalette.Ghibli.mantle)
    }
}

class AppColors {
    static func dynamicColor(
        light: Color,
        dark: Color,
        vietnam: Color? = nil,
        bubblegum: Color? = nil,
        sparkle: Color? = nil,
        ghibli: Color? = nil
    ) -> Color {
        let theme = getCurrentTheme()

        switch theme {
        case .light:
            return light
        case .dark:
            return dark
        case .system:
            #if os(iOS)
                return UITraitCollection.current.userInterfaceStyle == .dark ? dark : light
            #elseif os(macOS)
                return NSAppearance.current.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light
            #else
                return light
            #endif
        case .vietnam:
            return vietnam ?? light
        case .bubblegum:
            return bubblegum ?? light
        case .sparkle:
            return sparkle ?? dark
        case .ghibli:
            return ghibli ?? light
        }
    }

    // Helper method to safely get the current theme
    private static func getCurrentTheme() -> AppTheme {
        // First check UserDefaults directly
        if let themeName = UserDefaults.standard.string(forKey: "appTheme"),
           let theme = AppTheme(rawValue: themeName) {
            return theme
        }
        // Fallback to system if can't determine
        return .system
    }

    // App theme colors
    static var appBackground: Color {
        dynamicColor(
            light: ColorsPalette.Latte.base,
            dark: ColorsPalette.Macchiato.base,
            vietnam: ColorsPalette.Vietnamese.base,
            bubblegum: ColorsPalette.Bubblegum.base,
            sparkle: ColorsPalette.Sparkle.base,
            ghibli: ColorsPalette.Ghibli.base)
    }

    static var appText: Color {
        dynamicColor(
            light: ColorsPalette.Latte.text,
            dark: ColorsPalette.Macchiato.text,
            vietnam: ColorsPalette.Vietnamese.text,
            bubblegum: ColorsPalette.Bubblegum.text,
            sparkle: ColorsPalette.Sparkle.text,
            ghibli: ColorsPalette.Ghibli.text)
    }

    static var appSubtitle: Color {
        dynamicColor(
            light: ColorsPalette.Latte.subtext0,
            dark: ColorsPalette.Macchiato.subtext0,
            vietnam: ColorsPalette.Vietnamese.subtext0,
            bubblegum: ColorsPalette.Bubblegum.subtext0,
            sparkle: ColorsPalette.Sparkle.subtext0,
            ghibli: ColorsPalette.Ghibli.subtext0)
    }

    static var appAccent: Color {
        dynamicColor(
            light: ColorsPalette.Latte.blue,
            dark: ColorsPalette.Macchiato.blue,
            vietnam: ColorsPalette.Vietnamese.red,
            bubblegum: ColorsPalette.Bubblegum.pink,
            sparkle: ColorsPalette.Sparkle.primary,
            ghibli: ColorsPalette.Ghibli.primary)
    }

    static var appSecondaryAccent: Color {
        dynamicColor(
            light: ColorsPalette.Latte.mauve,
            dark: ColorsPalette.Macchiato.mauve,
            vietnam: ColorsPalette.Vietnamese.yellow,
            bubblegum: ColorsPalette.Bubblegum.lavender,
            sparkle: ColorsPalette.Sparkle.secondary,
            ghibli: ColorsPalette.Ghibli.secondary)
    }

    static var appGreen: Color {
        dynamicColor(
            light: ColorsPalette.Latte.green,
            dark: ColorsPalette.Macchiato.green,
            vietnam: ColorsPalette.Vietnamese.green,
            bubblegum: ColorsPalette.Bubblegum.green,
            sparkle: ColorsPalette.Sparkle.mintGreen,
            ghibli: ColorsPalette.Ghibli.forestSpirit)
    }

    static var appRed: Color {
        dynamicColor(
            light: ColorsPalette.Latte.red,
            dark: ColorsPalette.Macchiato.red,
            vietnam: ColorsPalette.Vietnamese.red,
            bubblegum: ColorsPalette.Bubblegum.red,
            sparkle: ColorsPalette.Sparkle.coral,
            ghibli: ColorsPalette.Ghibli.ponyo)
    }

    static var appOrange: Color {
        dynamicColor(
            light: ColorsPalette.Latte.peach,
            dark: ColorsPalette.Macchiato.peach,
            vietnam: ColorsPalette.Vietnamese.peach,
            bubblegum: ColorsPalette.Bubblegum.peach,
            sparkle: ColorsPalette.Sparkle.peach,
            ghibli: ColorsPalette.Ghibli.calcifer)
    }

    static var appYellow: Color {
        dynamicColor(
            light: ColorsPalette.Latte.yellow,
            dark: ColorsPalette.Macchiato.yellow,
            vietnam: ColorsPalette.Vietnamese.yellow,
            bubblegum: ColorsPalette.Bubblegum.yellow,
            sparkle: ColorsPalette.Sparkle.lemonYellow,
            ghibli: ColorsPalette.Ghibli.sunsetGold)
    }

    static var appSurface: Color {
        dynamicColor(
            light: ColorsPalette.Latte.surface0,
            dark: ColorsPalette.Macchiato.surface0,
            vietnam: ColorsPalette.Vietnamese.surface0,
            bubblegum: ColorsPalette.Bubblegum.surface0,
            sparkle: ColorsPalette.Sparkle.surface0,
            ghibli: ColorsPalette.Ghibli.surface0)
    }

    static var appSurface1: Color {
        dynamicColor(
            light: ColorsPalette.Latte.surface1,
            dark: ColorsPalette.Macchiato.surface1,
            vietnam: ColorsPalette.Vietnamese.surface1,
            bubblegum: ColorsPalette.Bubblegum.surface1,
            sparkle: ColorsPalette.Sparkle.surface1,
            ghibli: ColorsPalette.Ghibli.surface1)
    }

    static var appSurface2: Color {
        dynamicColor(
            light: ColorsPalette.Latte.surface2,
            dark: ColorsPalette.Macchiato.surface2,
            vietnam: ColorsPalette.Vietnamese.surface2,
            bubblegum: ColorsPalette.Bubblegum.surface2,
            sparkle: ColorsPalette.Sparkle.surface2,
            ghibli: ColorsPalette.Ghibli.surface2)
    }

    static var appCrust: Color {
        dynamicColor(
            light: ColorsPalette.Latte.crust,
            dark: ColorsPalette.Macchiato.crust,
            vietnam: ColorsPalette.Vietnamese.crust,
            bubblegum: ColorsPalette.Bubblegum.crust,
            sparkle: ColorsPalette.Sparkle.crust,
            ghibli: ColorsPalette.Ghibli.crust)
    }

    static var appMantle: Color {
        dynamicColor(
            light: ColorsPalette.Latte.mantle,
            dark: ColorsPalette.Macchiato.mantle,
            vietnam: ColorsPalette.Vietnamese.mantle,
            bubblegum: ColorsPalette.Bubblegum.mantle,
            sparkle: ColorsPalette.Sparkle.mantle,
            ghibli: ColorsPalette.Ghibli.mantle)
    }
}
