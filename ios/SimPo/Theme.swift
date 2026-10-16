import SwiftUI

enum AppTheme: String { case dark, light }
enum ClockMode: String { case flip, dial }

/// 웹 버전(index.html)의 CSS 변수와 같은 색
struct Palette {
    let bg, fg, card, digit, hinge, shadow, ui, uiDim, btn: Color

    static let dark = Palette(
        bg: Color(hex: 0x2B2B30), fg: Color(hex: 0xECECF1), card: Color(hex: 0x8E8E9F), digit: .white,
        hinge: .black.opacity(0.28), shadow: .black.opacity(0.35),
        ui: Color(hex: 0xECECF1), uiDim: Color(hex: 0x7D7D88), btn: Color(hex: 0x3B3B42))

    static let light = Palette(
        bg: .white, fg: Color(hex: 0x111111), card: Color(hex: 0xE4E4EA), digit: Color(hex: 0x2B2B30),
        hinge: .black.opacity(0.12), shadow: .black.opacity(0.12),
        ui: Color(hex: 0x111111), uiDim: Color(hex: 0x9A9A9A), btn: Color(hex: 0xEFEFEF))

    static func of(_ theme: AppTheme) -> Palette { theme == .light ? .light : .dark }
}

extension EnvironmentValues {
    @Entry var palette: Palette = .dark
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}

extension Font {
    /// 폰트 파일이 번들에 없으면 시스템 폰트로 대체된다.
    static func pretendard(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .custom(weight == .semibold ? "Pretendard-SemiBold" : "Pretendard-Bold", fixedSize: size)
    }
}

/// 아이패드에선 숫자를 아이폰 비율보다 조금 작게 그린다
let isPad = UIDevice.current.userInterfaceIdiom == .pad

/// 원형 아이콘 버튼 (라이트/다크, 플립/다이얼 전환)
struct IconButton: View {
    let systemName: String
    let action: () -> Void
    @Environment(\.palette) private var p

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(p.ui)
                .frame(width: 46, height: 46)
                .background(p.btn, in: Circle())
        }
        .buttonStyle(.plain)
    }
}
