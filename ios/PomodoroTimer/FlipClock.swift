import SwiftUI

struct FlipClock: View {
    let seconds: Int
    let showHours: Bool

    var body: some View {
        let h = seconds / 3600, m = seconds % 3600 / 60, s = seconds % 60
        let values = showHours ? [h, m, s] : [m, s]
        GeometryReader { geo in
            let cw = showHours
                ? min(geo.size.width * 0.28, geo.size.height * 0.48)
                : min(geo.size.width * 0.40, geo.size.height * 0.52)
            HStack(spacing: cw * 0.07) {
                ForEach(values.indices, id: \.self) { i in
                    FlipCard(value: String(format: "%02d", values[i]), width: cw)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

/// 위 반쪽이 접히며 내려오고(이전 값), 아래 반쪽이 펼쳐지는(새 값) 플립 카드
struct FlipCard: View {
    let value: String
    let width: CGFloat
    @Environment(\.palette) private var p
    @State private var current: String
    @State private var previous: String
    @State private var topAngle = 0.0
    @State private var bottomAngle = 0.0

    init(value: String, width: CGFloat) {
        self.value = value
        self.width = width
        _current = State(initialValue: value)
        _previous = State(initialValue: value)
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                half(current, top: true)
                half(previous, top: true)
                    .rotation3DEffect(.degrees(topAngle), axis: (1, 0, 0), anchor: .bottom, perspective: 0.5)
            }
            ZStack {
                half(previous, top: false)
                half(current, top: false)
                    .rotation3DEffect(.degrees(bottomAngle), axis: (1, 0, 0), anchor: .top, perspective: 0.5)
            }
        }
        .overlay {
            Rectangle().fill(p.hinge).frame(height: max(1, width * 0.012))
        }
        .compositingGroup()
        .shadow(color: p.shadow, radius: width * 0.04, y: width * 0.03)
        .onChange(of: value) { _, new in
            previous = current
            current = new
            topAngle = 0
            bottomAngle = 90
            // 위 상태가 먼저 그려진 다음 애니메이션을 시작해야 한다
            DispatchQueue.main.async {
                withAnimation(.easeIn(duration: 0.28)) { topAngle = -90 }
                withAnimation(.easeOut(duration: 0.28).delay(0.28)) { bottomAngle = 0 }
            }
        }
    }

    private func half(_ text: String, top: Bool) -> some View {
        let height = width * 1.1, r = width * 0.09
        return Text(text)
            .font(.pretendard(width * 0.72))
            .monospacedDigit()
            .kerning(-width * 0.02)
            .foregroundStyle(p.digit)
            .frame(width: width, height: height)
            .frame(width: width, height: height / 2, alignment: top ? .top : .bottom)
            .clipped()
            .background(p.card, in: UnevenRoundedRectangle(
                topLeadingRadius: top ? r : 0, bottomLeadingRadius: top ? 0 : r,
                bottomTrailingRadius: top ? 0 : r, topTrailingRadius: top ? r : 0))
    }
}
