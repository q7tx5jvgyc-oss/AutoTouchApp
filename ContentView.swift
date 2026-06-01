import SwiftUI
import WebKit

struct ContentView: View {
    // إعدادات الواجهة والزر العائم القابل للتحريك
    @State private var buttonPosition = CGSize(width: 100, height: 200)
    @State private var showMenu = false
    @State private var isRunning = false
    @State private var clickSpeed: Double = 1.0
    @State private var clickTargets: [CGPoint] = []
    
    var body: some View {
        ZStack {
            // المتصفح الداخلي لتشغيل الألعاب والمواقع فوقها الأوتو
            WebView(url: URL(string: "https://google.com")!)
                .edgesIgnoringSafeArea(.all)
            
            // رسم أهداف النقرات (الدوائر الحمراء المضافة)
            ForEach(0..<clickTargets.count, id: \.self) { index in
                Circle()
                    .fill(Color.red.opacity(0.8))
                    .frame(width: 35, height: 35)
                    .overlay(Text("\(index + 1)").foregroundColor(.white).bold())
                    .position(clickTargets[index])
            }
            
            // الزر العائم (يتحرك بالسحب ويفتح القائمة بالنقر)
            Circle()
                .fill(isRunning ? Color.green : Color.blue)
                .frame(width: 60, height: 60)
                .shadow(radius: 10)
                .overlay(Image(systemName: "hand.tap.fill").foregroundColor(.white).font(.title2))
                .position(x: buttonPosition.width, y: buttonPosition.height)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            self.buttonPosition = CGSize(width: value.location.x, height: value.location.y)
                        }
                )
                .onTapGesture {
                    withAnimation { self.showMenu.toggle() }
                }
            
            // قائمة التحكم والمميزات (تظهر وتختفي عند الضغط على الزر)
            if showMenu {
                VStack(spacing: 15) {
                    Text("لوحة تحكم الأوتو").font(.headline).bold()
                    Divider()
                    
                    // زر تشغيل وإيقاف
                    Button(action: {
                        isRunning.toggle()
                        if isRunning { startClicking() }
                    }) {
                        Text(isRunning ? "🛑 إيقاف" : "▶️ تشغيل الأوتو")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isRunning ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    // شريط السرعة (زيادة وتقليل)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("سرعة النقر: \(String(format: "%.1f", clickSpeed)) ثانية").font(.subheadline).bold()
                        Slider(value: $clickSpeed, in: 0.1...5.0, step: 0.1)
                    }
                    
                    // زر إضافة أهداف
                    Button(action: {
                        clickTargets.append(CGPoint(x: 200, y: 350)) // إضافة هدف في المنتصف
                    }) {
                        Label("إضافة هدف (نقرة)", systemImage: "plus.circle.fill")
                    }
                    
                    // زر مسح الأهداف
                    Button(action: { clickTargets.removeAll(); isRunning = false }) {
                        Text("مسح الأهداف").foregroundColor(.red).font(.footnote)
                    }
                }
                .padding()
                .background(Color(.systemBackground).opacity(0.95))
                .cornerRadius(20)
                .shadow(radius: 25)
                .frame(width: 280)
            }
        }
    }
    
    func startClicking() {
        guard isRunning else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + clickSpeed) {
            if self.isRunning {
                self.startClicking()
            }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView { return WKWebView() }
    func updateUIView(_ uiView: WKWebView, context: Context) { uiView.load(URLRequest(url: url)) }
}
