//
//  TermPDFViewer.swift
//  Presentation
//
//  TermClause 본문 텍스트를 PDFKit으로 표시하는 임시 placeholder 뷰어
//  추후 서버/URL 교체 시 PDFDocument(url:) 기반으로 확장
//

import SwiftUI
import PDFKit
import UIKit

struct TermPDFViewer: View {
    private let clause: TermClause

    init(clause: TermClause) {
        self.clause = clause
    }

    var body: some View {
        TermPDFRepresentable(clause: clause)
            .ignoresSafeArea(edges: .bottom)
    }
}

private struct TermPDFRepresentable: UIViewRepresentable {
    let clause: TermClause

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = makeDocument(from: clause)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = makeDocument(from: clause)
    }

    private func makeDocument(from clause: TermClause) -> PDFDocument? {
        let pageSize = CGSize(width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 22),
                .foregroundColor: UIColor.black
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.darkGray
            ]
            (clause.displayTitle as NSString).draw(
                in: CGRect(x: 36, y: 48, width: pageSize.width - 72, height: 60),
                withAttributes: titleAttributes
            )
            (clause.body as NSString).draw(
                in: CGRect(x: 36, y: 120, width: pageSize.width - 72, height: pageSize.height - 160),
                withAttributes: bodyAttributes
            )
        }

        return PDFDocument(data: data)
    }
}
