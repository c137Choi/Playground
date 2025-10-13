//
//  NSDiffableDataSourceSnapshotPlus.swift
//  KnowledPhone
//
//  Created by Choi on 2025/10/13.
//

import Foundation

extension NSDiffableDataSourceSnapshot {
    
    public mutating func appendSections(_ identifiers: SectionIdentifierType...) {
        appendSections(identifiers)
    }
    
    public mutating func appendSections(@ArrayBuilder<SectionIdentifierType> _ identifiers: () -> [SectionIdentifierType]) {
        appendSections(identifiers())
    }
    
    public mutating func appendItems(_ identifiers: ItemIdentifierType..., toSection sectionIdentifier: SectionIdentifierType? = nil) {
        appendItems(identifiers, toSection: sectionIdentifier)
    }
    
    public mutating func appendItems(toSection sectionIdentifier: SectionIdentifierType? = nil, @ArrayBuilder<ItemIdentifierType> _ identifiers: () -> [ItemIdentifierType]) {
        appendItems(identifiers(), toSection: sectionIdentifier)
    }
}
