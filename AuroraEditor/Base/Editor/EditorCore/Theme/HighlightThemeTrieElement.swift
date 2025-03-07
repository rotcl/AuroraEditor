//
//  ThemeTrieElement.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

class ThemeTrieElement {

    var children: [String: ThemeTrieElement]
    var attributes: [String: ThemeAttribute]
    var inSelectionAttributes: [String: ThemeAttribute]
    var outSelectionAttributes: [String: ThemeAttribute]
    var parentScopeElements: [String: ThemeTrieElement]

    init(
        children: [String: ThemeTrieElement],
        attributes: [String: ThemeAttribute],
        inSelectionAttributes: [String: ThemeAttribute],
        outSelectionAttributes: [String: ThemeAttribute],
        parentScopeElements: [String: ThemeTrieElement]
    ) {
        self.children = children
        self.attributes = attributes
        self.inSelectionAttributes = inSelectionAttributes
        self.outSelectionAttributes = outSelectionAttributes
        self.parentScopeElements = parentScopeElements
    }
}
