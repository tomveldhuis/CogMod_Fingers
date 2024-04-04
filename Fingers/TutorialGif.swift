/// Credits to: https://github.com/pitt500/GifView-SwiftUI/blob/main/GifView_SwiftUI/GifView_SwiftUI/GifImage.swift
///
import SwiftUI
import WebKit

struct GifImage: UIViewRepresentable {
    private let name: String

    init(_ name: String) {
        self.name = name
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        let url = Bundle.main.url(forResource: self.name, withExtension: "gif")!
        let data = try! Data(contentsOf: url)
        webView.load(
            data,
            mimeType: "image/gif",
            characterEncodingName: "UTF-8",
            baseURL: url.deletingLastPathComponent()
        )
        webView.scrollView.isScrollEnabled = false
        //webView.contentMode = .scaleAspectFill
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.reload()
    }

}
