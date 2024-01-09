//
//  WallCommentEditor.swift
//  wasteof-ios
//
//  Created by Oren Lindsey on 1/9/24.
//

import SwiftUI
import MarkupEditor


struct WallCommentEditor: View, MarkupDelegate {
    @Binding var currenthtml: String
    init(currenthtml: Binding<String>) {
        MarkupEditor.style = .labeled
        let myToolbarContents = ToolbarContents(
            correction: true, formatContents: FormatContents(subSuper: false)
        )
        ToolbarContents.custom = myToolbarContents
        self._currenthtml = currenthtml
    }
    func markupInput(_ view: MarkupWKWebView) {
        MarkupEditor.selectedWebView?.getHtml { html in
            currenthtml = html!
        }
    }
    
    var body: some View {
        MarkupEditorView(markupDelegate: self, html: $currenthtml)
    }
}
