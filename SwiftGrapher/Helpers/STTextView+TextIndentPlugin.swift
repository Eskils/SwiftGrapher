//
//  STTextView+TextIndentPlugin.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 11/02/2024.
//

import Foundation
import STTextView
import AppKit

extension NSResponder {
    var undoActive: Bool {
        guard let manager = undoManager else { return false }

        return manager.isUndoing || manager.isRedoing
    }
}

enum IndentType {
    case tabs
    case spaces(n: Int)
    
    var text: String {
        switch self {
        case .tabs:
            return "\t"
        case .spaces(let n):
            return String(repeating: " ", count: n)
        }
    }
}

struct TextIndentPlugin: STPlugin {
    private let indentType: IndentType

    init(indentType: IndentType) {
        self.indentType = indentType
    }

    @MainActor
    public func setUp(context: any Context) {
        context.events.shouldChangeText { affectedRange, replacementString in
            context.coordinator.shouldChangeText(in: affectedRange, replacementString: replacementString)
        }
        
        context.events.onDidChangeText { affectedRange, replacementString in
            context.coordinator.didChangeText(in: affectedRange, replacementString: replacementString)
        }
    }

    @MainActor
    public func makeCoordinator(context: CoordinatorContext) -> Coordinator {
        Coordinator(textView: context.textView, indentType: indentType)
    }

    @MainActor
    public class Coordinator {
        private let textView: STTextView
        let indentText: String
        
        private var indentLevelIndex = [Int]()
        private var lineNumberIndex = [Int]()

        init(textView: STTextView, indentType: IndentType) {
            self.textView = textView
            self.indentText = indentType.text
            
            indexTextForIndentationLevel()
        }

        func shouldChangeText(in affectedRange: NSTextRange, replacementString: String?) -> Bool {
            return true
        }
        
        func didChangeText(in affectedRange: NSTextRange, replacementString: String?) {
            guard let replacementString else {
                return
            }
            
            let contentManager = textView.textContentManager

            let range = NSRange(affectedRange, in: contentManager)
            let limit = NSRange(contentManager.documentRange, in: contentManager).upperBound

            if replacementString == "\n" {
                if lineNumberIndex.indices.contains(range.location) {
                    let lineNumber = lineNumberIndex[range.location]
                    let previousLineIndent = indentLevelIndex.indices.contains(lineNumber) ? indentLevelIndex[lineNumber] : 0
                    let nextLineIndent = indentLevelIndex.indices.contains(lineNumber + 1) ? indentLevelIndex[lineNumber + 1] : 0
                    let newLineIndent = max(0, max(previousLineIndent, nextLineIndent))
                    
                    let text = textView.string
                    let mutation = String(repeating: indentText, count: newLineIndent)
                    let replacementRange = NSRange(location: range.location + replacementString.count, length: 0)
                    textView.insertText(mutation, replacementRange: replacementRange)
                }
            }
            
            indexTextForIndentationLevel()
        }
        
        private func indexTextForIndentationLevel() {
            var newIndentLevelIndex = [Int]()
            var newLineNumberIndex = [Int]()
            var lineNumber = 0
            var startLineNumber = 0
            var currentIndentLevel = 0
            
            for (i, character) in textView.string.enumerated() {
                newLineNumberIndex.append(lineNumber)
                
                if character == "}", lineNumber > startLineNumber {
                    currentIndentLevel -= 1
                    startLineNumber = -1
                    continue
                }
                
                if character == "{" {
                    startLineNumber = lineNumber + 1
                    continue
                }
                
                if character == "\n" {
                    newIndentLevelIndex.append(currentIndentLevel)
                    lineNumber += 1
                    
                    if startLineNumber == lineNumber {
                        currentIndentLevel += 1
                    }
                    
                    continue
                }
            }
            
            newIndentLevelIndex.append(currentIndentLevel)
            
            print(newIndentLevelIndex)
            self.indentLevelIndex = newIndentLevelIndex
            self.lineNumberIndex = newLineNumberIndex
        }
    }
}
