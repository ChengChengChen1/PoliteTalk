import SwiftUI

// MARK: - 主题与工具
struct AppTheme {
    static let bgGradient = LinearGradient(
        colors: [
            Color(.sRGB, red: 0.08, green: 0.12, blue: 0.20, opacity: 1),
            Color(.sRGB, red: 0.05, green: 0.07, blue: 0.12, opacity: 1)
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let accentGradient = LinearGradient(
        colors: [
            Color(.sRGB, red: 0.40, green: 0.80, blue: 1.00, opacity: 1),
            Color(.sRGB, red: 0.50, green: 0.60, blue: 1.00, opacity: 1)
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

extension View {
    func cardStyle() -> some View {
        self
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.25), radius: 14, x: 0, y: 10)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                AppTheme.accentGradient
                    .mask(RoundedRectangle(cornerRadius: 14, style: .continuous))
            )
            .foregroundStyle(.black)
            .font(.headline)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Color.white.opacity(0.10), radius: 8, x: 0, y: 4)
    }
    
    func subtleButtonStyle() -> some View {
        self
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
    
}



// MARK: - 质感工具按钮样式
struct GlossyButtonStyle: ButtonStyle {
    let fill: LinearGradient
    let foreground: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .foregroundStyle(foreground)
            .background(
                fill
                    .mask(RoundedRectangle(cornerRadius: 12, style: .continuous))
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                // 细描边 + 高光
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
            // 按压反馈
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
    }
}

// 预设几种渐变（蓝、银灰、红）
enum ToolFills {
    static let blue = LinearGradient(
        colors: [Color.cyan, Color.blue],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let silver = LinearGradient(
        colors: [Color.white.opacity(0.28), Color.white.opacity(0.10)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let red = LinearGradient(
        colors: [Color(red: 1.00, green: 0.43, blue: 0.43),
                 Color(red: 0.95, green: 0.22, blue: 0.22)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}


// MARK: - 内容视图
struct ContentView: View {
    @State private var input: String = ""
    @State private var output: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMsg: String?

    // 替换为你的后端域名
    private let baseURL = "https://你的app.herokuapp.com"
    
    var body: some View {
        ZStack {
            AppTheme.bgGradient.ignoresSafeArea()
                .overlay(visualBackdrop) // 背景装饰
        
            ScrollView {
                VStack(spacing: 20) {
                    header
                    
                    // 输入卡片
                    VStack(spacing: 12) {
                        HStack {
                            Label("输入内容", systemImage: "square.and.pencil")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(input.count)/1000")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $input)
                                .frame(minHeight: 140)
                                .padding(8)
                                .scrollContentBackground(.hidden)
                                // .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                                // .overlay(
                                //     RoundedRectangle(cornerRadius: 14)
                                //         .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                                // )
                                .textInputAutocapitalization(.sentences)
                                .disableAutocorrection(false)
                                
                            
                            if input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("输入你要说的话")
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                            }
                        }
                        HStack(spacing: 12) {
                            // 复制
                            Button {
                                UIPasteboard.general.string = input
                                withHaptics(.light)
                            } label: {
                                Label("复制原文", systemImage: "doc.on.doc")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(GlossyButtonStyle(fill: ToolFills.blue, foreground: .black))

                            // 粘贴
                            Button {
                                if let str = UIPasteboard.general.string {
                                    input = str
                                    withHaptics(.light)
                                }
                            } label: {
                                Label("粘贴", systemImage: "arrow.down.doc")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(GlossyButtonStyle(fill: ToolFills.silver, foreground: .white))

                            // 清空（破坏性，红色）
                            Button(role: .destructive) {
                                input = ""; errorMsg = nil
                                withHaptics(.light)
                            } label: {
                                Label("清空", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(GlossyButtonStyle(fill: ToolFills.red, foreground: .white))
                        }

                        
                        
                    }
                    .cardStyle()
                    
                    // 变礼貌按钮
                    Button(action: makePolite) {
                        HStack(spacing: 8) {
                            if isLoading { ProgressView().tint(.black) }
                            Image(systemName: "sparkles")
                            Text(isLoading ? "正在润色…" : "一键变礼貌")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .primaryButtonStyle()
                    .disabled(isLoading || input.trimmed().isEmpty)
                    .opacity(isLoading || input.trimmed().isEmpty ? 0.7 : 1)
                    .animation(.easeInOut, value: isLoading)
                    
                    // 错误提示
                    if let error = errorMsg {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                            Text(error).foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 6)
                    }
                    
                    // 输出卡片
                    if !output.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("礼貌版结果", systemImage: "quote.opening")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Button {
                                    UIPasteboard.general.string = output
                                    withHaptics(.success)
                                } label: {
                                    Label("复制结果", systemImage: "doc.on.doc.fill")
                                }
                                .subtleButtonStyle()
                                .frame(maxWidth: 150)
                            }
                            
                            Text(output)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .padding(12)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                                )
                        }
                        .cardStyle()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    
                    footerTips
                }
                .padding(20)
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accentGradient)
                        .frame(width: 42, height: 42)
                        .shadow(color: .white.opacity(0.2), radius: 8, x: 0, y: 4)
                    Image(systemName: "hand.wave.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.black)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("PoliteTalk")
                        .font(.title2).fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text("把话说得更礼貌、更得体")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                Spacer()
            }
        }
    }
    
    private var footerTips: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("提示", systemImage: "info.circle")
                .foregroundStyle(.secondary)
                .font(.subheadline.weight(.semibold))
            Text("请勿输入敏感信息；AI 输出仅供参考，你可根据场景再微调。")
                .foregroundStyle(.secondary)
                .font(.footnote)
        }
        .padding(.horizontal, 4)
    }
    
    private var visualBackdrop: some View {
        ZStack {
            // 柔和高光
            Circle()
                .fill(Color.blue.opacity(0.15))
                .blur(radius: 80)
                .offset(x: -120, y: -200)
            Circle()
                .fill(Color.purple.opacity(0.12))
                .blur(radius: 100)
                .offset(x: 140, y: -120)
            Circle()
                .fill(Color.cyan.opacity(0.10))
                .blur(radius: 100)
                .offset(x: 80, y: 260)
        }
        .allowsHitTesting(false)
    }
    
    // MARK: - 行为
    private func makePolite() {
        guard !isLoading else { return }
        withHaptics(.light)
        
        errorMsg = nil
        output = ""
        isLoading = true
        
        // 简单长度限制
        let trimmed = input.trimmed()
        guard !trimmed.isEmpty else {
            isLoading = false
            errorMsg = "请输入内容"
            return
        }
        guard trimmed.count <= 1000 else {
            isLoading = false
            errorMsg = "内容太长了，请控制在 1000 字以内"
            return
        }
        
        // 不再传礼貌程度，只传 message
        guard let url = URL(string: "\(baseURL)/api/chat") else {
            self.errorMsg = "URL 不正确"
            self.isLoading = false
            return
        }
        
        var req = URLRequest(url: url, timeoutInterval: 25)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["message": trimmed]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: req) { data, resp, err in
            DispatchQueue.main.async {
                self.isLoading = false
                if let err = err {
                    self.errorMsg = "网络错误：\(err.localizedDescription)"
                    withHaptics(.error)
                    return
                }
                guard
                    let http = resp as? HTTPURLResponse,
                    (200...299).contains(http.statusCode),
                    let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                else {
                    self.errorMsg = "服务器响应异常"
                    withHaptics(.error)
                    return
                }
                if let reply = json["reply"] as? String {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        self.output = reply
                    }
                    withHaptics(.success)
                } else if let errText = json["error"] as? String {
                    self.errorMsg = errText
                    withHaptics(.warning)
                } else {
                    self.errorMsg = "未得到结果"
                    withHaptics(.warning)
                }
            }
        }.resume()
    }
    
    private func withHaptics(_ style: HapticStyle) {
        #if os(iOS)
        let generator: UINotificationFeedbackGenerator
        switch style {
        case .success: generator = UINotificationFeedbackGenerator(); generator.notificationOccurred(.success)
        case .warning: generator = UINotificationFeedbackGenerator(); generator.notificationOccurred(.warning)
        case .error:   generator = UINotificationFeedbackGenerator(); generator.notificationOccurred(.error)
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        #endif
    }
    
    enum HapticStyle { case success, warning, error, light }
}

private extension String {
    func trimmed() -> String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

#Preview {
    ContentView()
}

