// Views/Components/SmogParticleView.swift
// TazaAua – Particle System for Visualizing Air Quality

import SwiftUI
import Observation

/// A custom SwiftUI Canvas view that animates particles based on air quality
/// - High AQI (>100): Slow, dense, brownish/gray particles (smog)
/// - Low AQI (<50): Fast, light, transparent white particles (fresh air)
struct SmogParticleView: View {
    let aqi: Int

    @State private var engine: ParticleEngine
    @State private var lastSize: CGSize = .zero

    init(aqi: Int) {
        self.aqi = aqi
        _engine = State(initialValue: ParticleEngine(aqi: aqi))
    }

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    engine.step(date: timeline.date, in: size, aqi: aqi)

                    let isHighAQI = aqi > 100
                    let baseSize: CGFloat = isHighAQI ? 42 : 18
                    let particleColor = isHighAQI
                    ? Color(red: 0.44, green: 0.41, blue: 0.38)
                    : Color.white

                    for particle in engine.particles {
                        let size = baseSize * particle.scale
                        let rect = CGRect(
                            x: particle.x - size * 0.5,
                            y: particle.y - size * 0.5,
                            width: size,
                            height: size
                        )

                        var particleContext = context
                        particleContext.opacity = particle.opacity
                        particleContext.blendMode = isHighAQI ? .normal : .plusLighter

                        let gradient = Gradient(colors: [
                            particleColor.opacity(0.7),
                            particleColor.opacity(0.0)
                        ])

                        particleContext.fill(
                            Path(ellipseIn: rect),
                            with: .radialGradient(
                                gradient,
                                center: rect.center,
                                startRadius: 0,
                                endRadius: size * 0.5
                            )
                        )
                    }
                }
                .onAppear {
                    configureParticles(for: proxy.size)
                }
                .onChange(of: proxy.size) { newSize in
                    configureParticles(for: newSize)
                }
                .onChange(of: aqi) { _ in
                    configureParticles(for: proxy.size)
                }
            }
        }
        .ignoresSafeArea()
    }

    private func configureParticles(for size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        if size != lastSize || engine.particles.isEmpty {
            lastSize = size
            engine.resetParticles(in: size, aqi: aqi)
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var speedX: CGFloat
    var speedY: CGFloat
    var scale: CGFloat
    var opacity: Double
}

@Observable
final class ParticleEngine {
    private(set) var particles: [Particle] = []
    private var lastTimestamp: TimeInterval?

    init(aqi: Int) {
        if aqi > 100 {
            particles = makeParticles(count: 64, size: CGSize(width: 1, height: 1), isHighAQI: true)
        } else {
            particles = makeParticles(count: 40, size: CGSize(width: 1, height: 1), isHighAQI: false)
        }
    }

    func resetParticles(in size: CGSize, aqi: Int) {
        let isHighAQI = aqi > 100
        let count = isHighAQI ? 64 : 40
        particles = makeParticles(count: count, size: size, isHighAQI: isHighAQI)
        lastTimestamp = nil
    }

    func step(date: Date, in size: CGSize, aqi: Int) {
        guard size.width > 0, size.height > 0 else { return }
        let now = date.timeIntervalSinceReferenceDate
        let delta = lastTimestamp.map { now - $0 } ?? 0
        lastTimestamp = now
        guard delta > 0 else { return }

        let isHighAQI = aqi > 100
        let margin: CGFloat = isHighAQI ? 90 : 60

        for index in particles.indices {
            particles[index].x += particles[index].speedX * CGFloat(delta)
            particles[index].y += particles[index].speedY * CGFloat(delta)

            if particles[index].x > size.width + margin {
                particles[index].x = -margin
            } else if particles[index].x < -margin {
                particles[index].x = size.width + margin
            }

            if particles[index].y > size.height + margin {
                particles[index].y = -margin
            } else if particles[index].y < -margin {
                particles[index].y = size.height + margin
            }
        }
    }

    private func makeParticles(count: Int, size: CGSize, isHighAQI: Bool) -> [Particle] {
        (0..<count).map { index in
            var rng = SeededGenerator(seed: UInt64(index + 1) * 7919)
            let x = CGFloat.random(in: 0...max(size.width, 1), using: &rng)
            let y = CGFloat.random(in: 0...max(size.height, 1), using: &rng)

            let speedX: CGFloat
            let speedY: CGFloat
            let scale: CGFloat
            let opacity: Double

            if isHighAQI {
                speedX = CGFloat.random(in: -8...8, using: &rng)
                speedY = CGFloat.random(in: -22 ... -8, using: &rng)
                scale = CGFloat.random(in: 0.7...1.4, using: &rng)
                opacity = Double.random(in: 0.12...0.32, using: &rng)
            } else {
                speedX = CGFloat.random(in: 60...140, using: &rng)
                speedY = CGFloat.random(in: -6...6, using: &rng)
                scale = CGFloat.random(in: 0.5...1.0, using: &rng)
                opacity = Double.random(in: 0.03...0.12, using: &rng)
            }

            return Particle(
                x: x,
                y: y,
                speedX: speedX,
                speedY: speedY,
                scale: scale,
                opacity: opacity
            )
        }
    }
}

private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0x4d595df4d0f33173 : seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15
        var z = state
        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
        return z ^ (z >> 31)
    }
}

private extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

// MARK: - Preview

#Preview("High AQI - Smog") {
    ZStack {
        Color.black
        SmogParticleView(aqi: 158)
    }
    .ignoresSafeArea()
    .environment(ProfileViewModel())
}

#Preview("Low AQI - Fresh Air") {
    ZStack {
        Color.blue.opacity(0.3)
        SmogParticleView(aqi: 15)
    }
    .ignoresSafeArea()
    .environment(ProfileViewModel())
}
