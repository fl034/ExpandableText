//
// ExpandableText.swift
//
//
//  Created by 이웅재 on 2021/10/12.
//

import SwiftUI

public struct ExpandableText: View {
    var text: String
    @Binding var isExpanded: Bool
    var onTap: (() -> Void)?
    
    /// onTap only is called if expanded or not truncated
    public init(
        _ text: String,
        isExpanded: Binding<Bool>,
        expandButton: TextSet = TextSet(text: "more", font: .body, color: .blue),
        onTap: (() -> Void)? = nil
    ) {
        self.text = text
        self._isExpanded = isExpanded
        self.expandButton = expandButton
        self.onTap = onTap
    }

    var font = Font.body
    var lineLimit = 3
    var foregroundColor = Color.primary

    var expandButton: TextSet
    var collapseButton: TextSet?
    var animation: Animation?
    
    @State var isTruncated: Bool = false
    @State var maxHeight: CGFloat = 0

    var markdownText: AttributedString {
        (try? AttributedString(markdown: text, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? AttributedString(text)
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Text(markdownText)
                .font(font)
                .foregroundColor(foregroundColor)
                .lineLimit(isExpanded == true ? nil : lineLimit)
                .animation(animation, value: isExpanded)
                .mask(
                    VStack(spacing: 0) {
                        Rectangle().foregroundColor(.black)
                        
                        HStack(spacing: 0) {
                            Rectangle().foregroundColor(.black)
                            
                            if isTruncated {
                                if !isExpanded {
                                    HStack(alignment: .bottom, spacing: 0) {
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                Gradient.Stop(color: .black, location: 0),
                                                Gradient.Stop(color: .clear, location: 0.8),
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .frame(width: 32, height: expandButton.text.heightOfString(usingFont: fontToUIFont(font: expandButton.font)))
                                        
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: expandButton.text.widthOfString(usingFont: fontToUIFont(font: expandButton.font)), alignment: .center)
                                    }
                                } else if let collapseButton {
                                    HStack(alignment: .bottom, spacing: 0) {
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                Gradient.Stop(color: .black, location: 0),
                                                Gradient.Stop(color: .clear, location: 0.8),
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .frame(width: 32, height: collapseButton.text.heightOfString(usingFont: fontToUIFont(font: collapseButton.font)))
                                        
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: collapseButton.text.widthOfString(usingFont: fontToUIFont(font: collapseButton.font)), alignment: .center)
                                    }
                                }
                            }
                        }
                        .frame(height: expandButton.text.heightOfString(usingFont: fontToUIFont(font: font)))
                    }
                )
            
            if isTruncated {
                if let collapseButton, isExpanded {
                    Button {
                        isExpanded = false
                    } label: {
                        Text(collapseButton.text)
                            .font(collapseButton.font)
                            .foregroundColor(collapseButton.color)
                    }.allowsHitTesting(false)
                } else if !isExpanded {
                    Button {
                        isExpanded = true
                    } label: {
                        Text(expandButton.text)
                            .font(expandButton.font)
                            .foregroundColor(expandButton.color)
                    }.allowsHitTesting(false)
                }
            }
        }
        .background(
            ZStack {
                if !isTruncated {
                    if maxHeight != 0 {
                        Text(text)
                            .font(font)
                            .lineLimit(lineLimit)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            if maxHeight > geo.size.height {
                                                self.isTruncated = true
                                                print(geo.size.height)
                                            }
                                        }
                                }
                            )
                    }
                    
                    Text(text)
                        .font(font)
                        .lineLimit(999)
                        .fixedSize(horizontal: false, vertical: true)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        self.maxHeight = geo.size.height
                                    }
                            }
                        )
                }
            }
                .hidden()
        )
        .onTapGesture {
            if isTruncated && !isExpanded {
                self.isExpanded = true
            } else {
                onTap?()
            }
        }
    }
}
