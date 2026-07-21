//
//  TermWebView.swift
//  Presentation
//
//  약관 URL을 WKWebView로 로드하는 뷰
//

import SwiftUI
import WebKit

struct TermWebView: View {
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    var body: some View {
        TermWebViewRepresentable(url: url)
            .ignoresSafeArea(edges: .bottom)
    }
}

private struct TermWebViewRepresentable: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard uiView.url != url else { return }

        uiView.load(URLRequest(url: url))
    }
}
