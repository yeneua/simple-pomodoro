import SwiftUI

struct ContentView: View {
    @AppStorage("theme") private var theme: AppTheme = .dark
    @AppStorage("mode") private var mode: ClockMode = .flip
    @AppStorage("mins") private var mins = 25
    @State private var timer = PomodoroTimer()

    var body: some View {
        let p = Palette.of(theme)
        ZStack {
            p.bg.ignoresSafeArea()
            if timer.isRunning {
                RunView(timer: timer, mode: $mode, theme: $theme)
            } else {
                SetupView(mins: $mins, theme: $theme) { timer.start(minutes: mins) }
            }
        }
        .environment(\.palette, p)
        .preferredColorScheme(theme == .light ? .light : .dark)
        .animation(.easeInOut(duration: 0.25), value: theme)
    }
}

// MARK: - 설정 화면

struct SetupView: View {
    @Binding var mins: Int
    @Binding var theme: AppTheme
    let onStart: () -> Void
    @Environment(\.palette) private var p

    var body: some View {
        GeometryReader { geo in
            let landscape = geo.size.width > geo.size.height
            let numberSize = landscape
                ? min(geo.size.width * 0.17, geo.size.height * 0.42)
                : min(geo.size.width * 0.26, geo.size.height * 0.22)
            let spacing = min(geo.size.height * 0.06, 40)
            Group {
                if landscape {
                    HStack(spacing: 48) {
                        stepper(numberSize)
                        VStack(spacing: spacing) { presets; startButton }
                    }
                } else {
                    VStack(spacing: spacing) { stepper(numberSize); presets; startButton }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .overlay(alignment: .topTrailing) {
            IconButton(systemName: theme == .light ? "moon" : "sun.max") {
                theme = theme == .light ? .dark : .light
            }
            .padding(16)
        }
    }

    private func stepper(_ numberSize: CGFloat) -> some View {
        HStack(spacing: 32) {
            stepButton("minus") { mins = max(1, mins - 1) }
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(mins)")
                    .font(.pretendard(numberSize))
                    .monospacedDigit()
                    .foregroundStyle(p.ui)
                    .contentTransition(.numericText())
                Text("분")
                    .font(.pretendard(18, weight: .semibold))
                    .foregroundStyle(p.uiDim)
            }
            .frame(minWidth: numberSize * 1.7)
            stepButton("plus") { mins = min(180, mins + 1) }
        }
    }

    private var presets: some View {
        HStack(spacing: 10) {
            ForEach([5, 15, 25, 50], id: \.self) { m in
                Button { mins = m } label: {
                    Text("\(m)")
                        .font(.pretendard(15, weight: .semibold))
                        .foregroundStyle(p.uiDim)
                        .frame(width: 52, height: 36)
                        .background(p.btn, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var startButton: some View {
        Button(action: onStart) {
            Text("시작")
                .font(.pretendard(20))
                .foregroundStyle(p.bg)
                .padding(.horizontal, 64)
                .padding(.vertical, 16)
                .background(p.ui, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func stepButton(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(p.ui)
                .frame(width: 56, height: 56)
                .background(p.btn, in: Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 타이머 화면

struct RunView: View {
    let timer: PomodoroTimer
    @Binding var mode: ClockMode
    @Binding var theme: AppTheme
    @Environment(\.palette) private var p
    @State private var showControls = false
    @State private var hideTask: Task<Void, Never>?
    @State private var pulse = false

    var body: some View {
        GeometryReader { geo in
            content(landscape: geo.size.width > geo.size.height)
        }
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
    }

    private func content(landscape: Bool) -> some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30, paused: timer.isPaused || timer.isDone)) { ctx in
            let left = timer.remaining(at: ctx.date)
            let sec = Int(left.rounded(.up))
            Group {
                switch mode {
                case .flip: FlipClock(seconds: sec, showHours: timer.total >= 3600)
                case .dial: DialView(fraction: left / max(timer.total, 1), seconds: sec)
                }
            }
            .opacity(pulse ? 0.25 : 1)
            .onChange(of: sec) { _, s in if s <= 0 { timer.finish() } }
        }
        // 가로면 양옆 아이콘 자리를 비워둔다
        .padding(.horizontal, landscape ? 72 : 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            if timer.isDone { timer.stop() }
            else if showControls && !timer.isPaused { showControls = false }
            else { revealControls() }
        }
        .overlay(alignment: .bottom) { if !landscape { controls } }
        .overlay(alignment: .leading) { if landscape { sideControls(leading: true) } }
        .overlay(alignment: .trailing) { if landscape { sideControls(leading: false) } }
        .onChange(of: timer.isDone) { _, done in
            guard done else { return }
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) { pulse = true }
        }
    }

    /// 가로 화면: 왼쪽엔 일시정지·처음으로, 오른쪽엔 모드·테마 전환
    private func sideControls(leading: Bool) -> some View {
        VStack(spacing: 16) {
            if leading {
                IconButton(systemName: timer.isPaused ? "play.fill" : "pause.fill", action: togglePause)
                IconButton(systemName: "arrow.counterclockwise") { timer.stop() }
            } else {
                IconButton(systemName: mode == .flip ? "timer" : "rectangle.split.2x1", action: toggleMode)
                IconButton(systemName: theme == .light ? "moon" : "sun.max", action: toggleTheme)
            }
        }
        .padding(.horizontal, 16)
        .opacity(showControls ? 1 : 0)
        .allowsHitTesting(showControls)
        .animation(.easeInOut(duration: 0.25), value: showControls)
    }

    private var controls: some View {
        HStack(spacing: 12) {
            IconButton(systemName: timer.isPaused ? "play.fill" : "pause.fill", action: togglePause)
            IconButton(systemName: "arrow.counterclockwise") { timer.stop() }
            IconButton(systemName: mode == .flip ? "timer" : "rectangle.split.2x1", action: toggleMode)
            IconButton(systemName: theme == .light ? "moon" : "sun.max", action: toggleTheme)
        }
        .padding(.bottom, 28)
        .opacity(showControls ? 1 : 0)
        .allowsHitTesting(showControls)
        .animation(.easeInOut(duration: 0.25), value: showControls)
    }

    private func togglePause() {
        timer.togglePause()
        revealControls()
    }

    private func toggleMode() {
        mode = mode == .flip ? .dial : .flip
        revealControls()
    }

    private func toggleTheme() {
        theme = theme == .light ? .dark : .light
        revealControls()
    }

    /// 컨트롤을 보여주고, 실행 중이면 3초 뒤 숨긴다.
    private func revealControls() {
        showControls = true
        hideTask?.cancel()
        guard !timer.isPaused else { return }
        hideTask = Task {
            try? await Task.sleep(for: .seconds(3))
            if !Task.isCancelled { showControls = false }
        }
    }
}

#Preview { ContentView() }
