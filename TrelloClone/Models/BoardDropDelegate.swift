//
//  BoardDropDelegate.swift
//  TrelloClone
//
//  Created by Alfian Losari on 12/1/21.
//

import Foundation
import SwiftUI

struct BoardDropDelegate: DropDelegate {
    
    let board: Board
    let boardList: BoardList
    
    @Binding var lists: [BoardList]
    @Binding var current: BoardList?
    
    private func boardListItemProviders(info: DropInfo) -> [NSItemProvider] {
        info.itemProviders(for: [BoardList.typeIdentifier])
    }
    
    private func cardItemProviders(info: DropInfo) -> [NSItemProvider] {
        info.itemProviders(for: [Card.typeIdentifier])
    }
    
    func dropEntered(info: DropInfo) {
        guard
            !boardListItemProviders(info: info).isEmpty,
            let current = current,
            boardList != current,
            let fromIndex = lists.firstIndex(of: current),
            let toIndex = lists.firstIndex(of: boardList) else {
                return
            }
        lists.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        if !cardItemProviders(info: info).isEmpty {
            return DropProposal(operation: .copy)
        } else if !boardListItemProviders(info: info).isEmpty {
            return DropProposal(operation: .move)
        }
        return nil
    }
    
    func performDrop(info: DropInfo) -> Bool {
        let cardItemProviders = cardItemProviders(info: info)
        for cardItemProvider in cardItemProviders {
            cardItemProvider.loadObject(ofClass: Card.self) { item, _ in
                guard let card = item as? Card,
                      card.boardListId != boardList.id
                else { return }
                DispatchQueue.main.async {
                    board.move(card: card, to: boardList, at: 0)
                }
            }
        }
        self.current = nil
        return true
    }
}

