//
//  ParticleStrategies.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import UIKit

// Particle creation strategy protocol
protocol ParticleCreationStrategy {
    func createImage(size: CGSize, color: UIColor) -> UIImage
}

// Default fallback strategy
class DefaultParticleStrategy: ParticleCreationStrategy {
    func createImage(size: CGSize, color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
    }
}

// Specific particle strategies
class CircleParticleStrategy: ParticleCreationStrategy {
    func createImage(size: CGSize, color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
    }
}

class SquareParticleStrategy: ParticleCreationStrategy {
    func createImage(size: CGSize, color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.cgContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}

class TriangleParticleStrategy: ParticleCreationStrategy {
    func createImage(size: CGSize, color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let path = UIBezierPath()
            path.move(to: CGPoint(x: size.width / 2, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            path.close()

            color.setFill()
            path.fill()
        }
    }
}

class SparkParticleStrategy: ParticleCreationStrategy {
    func createImage(size: CGSize, color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cgContext = context.cgContext

            // Create a spark-like gradient
            let locations: [CGFloat] = [0.0, 0.5, 1.0]
            let colors: [CGColor] = [
                color.withAlphaComponent(0.8).cgColor,
                color.withAlphaComponent(0.4).cgColor,
                color.withAlphaComponent(0.0).cgColor
            ]

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)!

            cgContext.drawRadialGradient(gradient,
                                         startCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                                         startRadius: 0,
                                         endCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                                         endRadius: size.width / 2,
                                         options: .drawsBeforeStartLocation)
        }
    }
}

class SmokeParticleStrategy: ParticleCreationStrategy {
    func createImage(size: CGSize, color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cgContext = context.cgContext

            // Create a smoke-like gradient
            let locations: [CGFloat] = [0.0, 0.5, 1.0]
            let colors: [CGColor] = [
                color.withAlphaComponent(0.6).cgColor,
                color.withAlphaComponent(0.3).cgColor,
                color.withAlphaComponent(0.0).cgColor
            ]

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)!

            cgContext.drawRadialGradient(gradient,
                                         startCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                                         startRadius: 0,
                                         endCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                                         endRadius: size.width / 2,
                                         options: .drawsBeforeStartLocation)
        }
    }
}

class BubbleParticleStrategy: ParticleCreationStrategy {
    func createImage(size: CGSize, color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            // Outer circle
            color.withAlphaComponent(0.7).setStroke()
            let circlePath = UIBezierPath(ovalIn: CGRect(x: 1, y: 1, width: size.width - 2, height: size.height - 2))
            circlePath.lineWidth = 1
            circlePath.stroke()

            // Inner highlight
            color.withAlphaComponent(0.3).setFill()
            let highlightPath = UIBezierPath(ovalIn: CGRect(x: size.width * 0.25, y: size.width * 0.25,
                                                            width: size.width * 0.25, height: size.height * 0.25))
            highlightPath.fill()
        }
    }
}
