//
//  ShapeStrategies.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import UIKit

// Shape creation strategy protocol
protocol ShapeCreationStrategy {
    func createPath(in rect: CGRect) -> CGPath
}

// Default fallback strategy
class DefaultShapeStrategy: ShapeCreationStrategy {
    func createPath(in rect: CGRect) -> CGPath {
        return UIBezierPath(ovalIn: rect).cgPath
    }
}

// Specific shape strategies
class CircleShapeStrategy: ShapeCreationStrategy {
    func createPath(in rect: CGRect) -> CGPath {
        return UIBezierPath(ovalIn: rect).cgPath
    }
}

class SquareShapeStrategy: ShapeCreationStrategy {
    func createPath(in rect: CGRect) -> CGPath {
        return UIBezierPath(rect: rect).cgPath
    }
}

class TriangleShapeStrategy: ShapeCreationStrategy {
    func createPath(in rect: CGRect) -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.close()
        return path.cgPath
    }
}

class XShapeStrategy: ShapeCreationStrategy {
    func createPath(in rect: CGRect) -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path.cgPath
    }
}

class LineShapeStrategy: ShapeCreationStrategy {
    func createPath(in rect: CGRect) -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path.cgPath
    }
}

class ArcShapeStrategy: ShapeCreationStrategy {
    func createPath(in rect: CGRect) -> CGPath {
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: rect.midX, y: rect.midY),
                   radius: rect.width / 2,
                   startAngle: 0, endAngle: .pi, clockwise: true)
        return path.cgPath
    }
}

class SpiralShapeStrategy: ShapeCreationStrategy {
    func createPath(in rect: CGRect) -> CGPath {
        let path = UIBezierPath()
        var currentPoint = CGPoint(x: rect.midX, y: rect.midY)
        let maxRadius = min(rect.width, rect.height) / 2
        path.move(to: currentPoint)
        
        for i in 0..<36 {
            let angle = CGFloat(i) * .pi / 18
            let radius = CGFloat(i) * maxRadius / 36
            let x = rect.midX + radius * cos(angle)
            let y = rect.midY + radius * sin(angle)
            currentPoint = CGPoint(x: x, y: y)
            path.addLine(to: currentPoint)
        }
        
        return path.cgPath
    }
}

class StarShapeStrategy: ShapeCreationStrategy {
    func createPath(in rect: CGRect) -> CGPath {
        let path = UIBezierPath()
        let centerX = rect.midX
        let centerY = rect.midY
        let radius = min(rect.width, rect.height) / 2
        let innerRadius = radius * 0.4
        
        for i in 0..<5 {
            let angle = CGFloat(i) * .pi * 2 / 5 - .pi / 2
            let point = CGPoint(x: centerX + cos(angle) * radius,
                              y: centerY + sin(angle) * radius)
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
            
            let innerAngle = angle + .pi / 5
            let innerPoint = CGPoint(x: centerX + cos(innerAngle) * innerRadius,
                                  y: centerY + sin(innerAngle) * innerRadius)
            path.addLine(to: innerPoint)
        }
        
        path.close()
        return path.cgPath
    }
}
