import SwiftUI

/// 남은 시간만큼 부채꼴이 줄어드는 다이얼. 부채꼴과 겹친 눈금·숫자는 색이 반전된다.
struct DialView: View {
    let fraction: Double
    let seconds: Int
    @Environment(\.palette) private var p

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width * 0.9, geo.size.height * 0.86)
            let u = side / 220   // 웹 버전 SVG viewBox(220) 기준 단위
            ZStack {
                face(p.fg, u: u)
                Wedge(fraction: fraction).fill(p.fg).frame(width: 172 * u, height: 172 * u)
                face(p.bg, u: u)
                    .mask(Wedge(fraction: fraction).frame(width: 172 * u, height: 172 * u))
            }
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func face(_ color: Color, u: CGFloat) -> some View {
        let h = seconds / 3600, m = seconds % 3600 / 60, s = seconds % 60
        let top = h > 0 ? "\(h):" + String(format: "%02d", m) : String(format: "%02d", m)
        return ZStack {
            Ticks(major: true).stroke(color, style: StrokeStyle(lineWidth: 3 * u, lineCap: .round))
            Ticks(major: false).stroke(color, style: StrokeStyle(lineWidth: 1.4 * u, lineCap: .round))
            VStack(spacing: -5 * u) {
                Text(top)
                Text(String(format: "%02d", s))
            }
            .font(.pretendard(44 * u))
            .monospacedDigit()
            .foregroundStyle(color)
        }
    }
}

struct Wedge: Shape {
    var fraction: Double

    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY), r = min(rect.width, rect.height) / 2
        var path = Path()
        guard fraction > 0 else { return path }
        if fraction >= 0.9999 {
            path.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r))
            return path
        }
        // SwiftUI 좌표계에서는 clockwise: false 가 화면상 시계방향
        path.move(to: c)
        path.addArc(center: c, radius: r, startAngle: .degrees(-90),
                    endAngle: .degrees(-90 + 360 * fraction), clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct Ticks: Shape {
    let major: Bool

    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY), u = min(rect.width, rect.height) / 220
        var path = Path()
        for i in 0..<60 where (i % 5 == 0) == major {
            let a = Double(i) * .pi / 30
            let r1 = (major ? 90 : 96) * u, r2 = 104 * u
            path.move(to: CGPoint(x: c.x + r1 * sin(a), y: c.y - r1 * cos(a)))
            path.addLine(to: CGPoint(x: c.x + r2 * sin(a), y: c.y - r2 * cos(a)))
        }
        return path
    }
}
