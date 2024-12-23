//
//  AnnotationFactory.swift
//  aoe2-synthetic-data
//
//  Created by Vincent Lazzara on 12/10/24.
//

import SwiftUI

enum Player: String {
    case one = "player_blue"
    case two = "player_cyan"
    case three = "player_green"
    case four = "player_grey"
    case five = "player_lightblue"
    case six = "player_lightyellow"
    case seven = "player_orange"
    case eight = "player_pink"
    case nine = "player_purple"
    case ten = "player_red"
    case eleven = "player_yellow"
    
    static func random() -> Player {
        let allPlayers: [Player] = [
            .one, .two, .three, .four, .five,
            .six, .seven, .eight, .nine, .ten, .eleven
        ]
        return allPlayers.randomElement() ?? .one
    }
}

// Factory for creating different types of annotations
struct AnnotationFactory {
    static func createResourceAnnotation(
        resource: Resource,
        canvasSize: CGSize,
        coordinate: CGPoint,
        amount: Int = Int.random(in: 0...999),
        workerCount: Int = Int.random(in: 0...9)
    ) -> ResourceAnnotation {
        let iconSize = CGSize(width: 84, height: 84)
        let rect = CGRect(
            x: coordinate.x - iconSize.width/2,
            y: coordinate.y - iconSize.height/2,
            width: iconSize.width,
            height: iconSize.height
        )
        
        return ResourceAnnotation(
            rect: rect,
            tag: resource.tag,
            size: canvasSize,
            resource: resource,
            amount: amount,
            workerCount: workerCount
        )
    }
    
    static func createVillagerAnnotation(
        at point: CGPoint,
        canvasSize: CGSize,
        num: Int = 0,
        player: Player = .one,
        progress: Double,
        progressOpacity: CGFloat = 0.5
    ) -> VillagerAnnotation {
        let iconSize = CGSize(width: 74, height: 74)
        let rect = CGRect(
            x: point.x - iconSize.width/2,
            y: point.y - iconSize.height/2,
            width: iconSize.width,
            height: iconSize.height
        )
        let isHoused = (num < 0)
        return VillagerAnnotation(
            rect: rect,
            tag: isHoused ? .alert_housed : .queue_vil,
            size: canvasSize,
            player: player,
            num: num,
            progress: progress,
            progressOpacity: progressOpacity
        )
    }
    
    static func createAgeQueueAnnotation(
        at point: CGPoint,
        canvasSize: CGSize,
        age: ImageTag,
        progress: Double,
        progressOpacity: CGFloat = 0.5
    ) -> AgeQueueAnnotation {
        let iconSize = CGSize(width: 74, height: 74)
        let rect = CGRect(
            x: point.x - iconSize.width/2,
            y: point.y - iconSize.height/2,
            width: iconSize.width,
            height: iconSize.height
        )
        return AgeQueueAnnotation(rect: rect, tag: age, size: canvasSize, progress: progress, progressOpacity: progressOpacity)
    }
    
    static func createAgeAnnotation(
        at point: CGPoint,
        canvasSize: CGSize,
        tag: ImageTag,
        civ: CivType,
        clickState: AgeClickState
    ) -> AgeAnnotation {
        let iconSize = CGSize(width: 141, height: 122)
        let rect = CGRect(
            x: point.x - iconSize.width/2,
            y: point.y - iconSize.height/2,
            width: iconSize.width,
            height: iconSize.height
        )
        return AgeAnnotation(size: canvasSize, rect: rect, tag: tag, civ: civ, clickState: clickState)
    }
    
    
}
