// bomberfish
// MarkdownView.swift – Voltaire
// created on 2025-01-29

import SwiftUI
import LaTeXSwiftUI

// markdown view that offers more than what swiftui provides ootb
// (i.e. codeblocks, headers, latex)
struct MarkdownView: View {
    @Binding var markdown: String
    @State private var lines: [MarkdownLine] = []
    
    init(_ md: Binding<String>) {
        self._markdown = md
    }
    
    init(_ md: String) {
        self._markdown = .constant(md)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(buildViews().enumerated()), id: \.offset) { _, view in
                view
            }
        }
        .textSelection(.enabled)
        .animation(.default, value: lines)
        .onChange(of: markdown) {
            lines = parseMD(markdown)
        }
        .onAppear {
            lines = parseMD(markdown)
        }
    }
    
    func buildViews() -> [AnyView] {
        var views: [AnyView] = []
        var idx = 0
        while idx < lines.count {
            let line = lines[idx]
            if line.type == .codeblockTitle {
                let language = line.content.trimmingCharacters(in: .whitespaces)
                var codeLines: [String] = []
                var nextIndex = idx + 1
                while nextIndex < lines.count && lines[nextIndex].type == .codeblock {
                    codeLines.append(lines[nextIndex].content)
                    nextIndex += 1
                }
                let code = codeLines.joined(separator: "\n")
                views.append(AnyView(CodeBlockView(language: language, code: code)))
                idx = nextIndex
            } else {
                views.append(AnyView(MarkdownLineView(line: line)))
                idx += 1
            }
        }
        return views
    }
}

struct CodeBlockView: View {
    let language: String
    let code: String
    @State private var copied = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(language.isEmpty ? "Code" : language)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    UIPasteboard.general.string = code
                    withAnimation {
                        copied = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            copied = false
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            .font(.caption)
                        Text(copied ? "Copied" : "Copy")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            
            Divider()
            
            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(.subheadline, design: .monospaced))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
        .padding(.vertical, 4)
    }
}

struct MarkdownLineView: View {
    public var line: MarkdownLine
    var body: some View {
        switch line.type {
        case .h1:
            Text(line.content)
                .font(.title)
        case .h2:
            Text(line.content)
                .font(.title2)
        case .h3:
            Text(line.content)
                .font(.title3)
        case .h4:
            Text(line.content)
                .font(.headline)
        case .codeblock:
            EmptyView()
        case .codeblockTitle:
            EmptyView()
        case .latex:
            LaTeX(line.content)
                .errorMode(.rendered)
                .parsingMode(.all)
        case .includesLatex:
            LaTeX(line.content)
                .errorMode(.original)
                .parsingMode(.onlyEquations)
        default:
            Text((try? AttributedString(markdown: line.content)) ?? AttributedString(stringLiteral: line.content))
        }
    }
}

struct MarkdownLine: Identifiable, Equatable, Hashable {
    var id = UUID()
    var type: MarkdownLineType
    var content: String
}

func parseMD(_ markdown: String) -> [MarkdownLine] {
    let lines = markdown.components(separatedBy: "\n")
    var parsedLines: [MarkdownLine] = []
    
    var withinCodeblock = false
    var withinLatex = false
    
    for line in lines {
        if withinCodeblock {
            if line.starts(with: "```") {
                withinCodeblock = false
                continue
            }
            parsedLines.append(MarkdownLine(type: .codeblock, content: line))
        } else if withinLatex {
            if line.starts(with: "$$") {
                withinLatex = false
            }
            parsedLines.append(MarkdownLine(type: .latex, content: line))
        } else if line.starts(with: "# ") {
            parsedLines.append(MarkdownLine(type: .h1, content: String(line.dropFirst(2))))
        } else if line.starts(with: "## ") {
            parsedLines.append(MarkdownLine(type: .h2, content: String(line.dropFirst(3))))
        } else if line.starts(with: "### ") {
            parsedLines.append(MarkdownLine(type: .h3, content: String(line.dropFirst(4))))
        } else if line.starts(with: "#### ") {
            parsedLines.append(MarkdownLine(type: .h4, content: String(line.dropFirst(5))))
        } else if line == "```" {
            //            parsedLines.append(MarkdownLine(type: .codeblock, content: line))
            withinCodeblock = true
        } else if line.starts(with: "```") {
            parsedLines.append(MarkdownLine(type: .codeblockTitle, content: String(line.dropFirst(3))))
            withinCodeblock = true
        } else if line == "$$" || line == "$" { // some models really like to use single even if the system prompt instructs otherwise.
            //            parsedLines.append(MarkdownLine(type: .latex, content: line))
            withinLatex = true
        } else if (line.starts(with: "$$") && line.hasSuffix("$$")) {
            parsedLines.append(MarkdownLine(type: .latex, content: String(line.dropFirst(2).dropLast(2))))
        } else if ((line.starts(with: "$") && line.hasSuffix("$"))) {
            parsedLines.append(MarkdownLine(type: .latex, content: String(line.dropFirst().dropLast())))
        } else if line.contains("$$") || line.contains("$"){
            parsedLines.append(MarkdownLine(type: .includesLatex, content: line))
        } else {
            parsedLines.append(MarkdownLine(type: .regular, content: line))
        }
    }
    print(parsedLines)
    return parsedLines
}

enum MarkdownLineType: Equatable {
    case h1,h2,h3,h4,codeblock,codeblockTitle,regular,includesLatex,latex
}

#Preview {
    MarkdownView("""
# Heading 1
Body
## Heading 2
**Bold** *Italic* `Code`
### Heading 3
$$\\sqrt{2}$$
$\\sqrt{2}$

""")
}
