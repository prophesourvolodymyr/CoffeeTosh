import SwiftUI
import WebKit

struct RemoteMacBook3DView: NSViewRepresentable {
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.suppressesIncrementalRendering = false

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground")
        webView.underPageBackgroundColor = .clear
        webView.allowsMagnification = false
        webView.wantsLayer = true
        webView.layer?.backgroundColor = NSColor.clear.cgColor
        webView.setAccessibilityLabel("Interactive MacBook. Click to close or open the lid.")

        loadContent(in: webView)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        let reduceMotion = accessibilityReduceMotion ? "true" : "false"
        webView.evaluateJavaScript("window.remoteMacBookSetReducedMotion?.(\(reduceMotion));")
    }

    private func loadContent(in webView: WKWebView) {
        guard let htmlURL = Bundle.main.url(forResource: "remote-macbook", withExtension: "html") else {
            return
        }

        webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            webView.evaluateJavaScript("window.remoteMacBookSetReducedMotion?.(window.matchMedia('(prefers-reduced-motion: reduce)').matches);")
        }
    }
}
