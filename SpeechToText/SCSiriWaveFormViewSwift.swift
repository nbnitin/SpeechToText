//
//  SCSiriWaveFormViewSwift.swift
//  VoiceRecorder
//
//  Created by Nitin on 10/06/20.
//  Copyright © 2020 Nitin. All rights reserved.
//

import UIKit

let kDefaultFrequency : CGFloat = 1.5
let kDefaultAmplitude  : CGFloat = 1.0
let kDefaultIdleAmplitude : CGFloat = 0.01
let kDefaultNumberOfWaves : CGFloat = 5.0
let kDefaultPhaseShift  : CGFloat = -0.15
let kDefaultDensity  : CGFloat = 5.0
let kDefaultPrimaryLineWidth : CGFloat = 3.0
let kDefaultSecondaryLineWidth : CGFloat = 1.0

@IBDesignable
class SCSiriWaveFormViewSwift : UIView {
    
    var phase : CGFloat!
    var amplitude : CGFloat!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    @IBInspectable
    public var waveColor : UIColor = UIColor.white
    @IBInspectable
       public var frequency : CGFloat = kDefaultFrequency
    @IBInspectable
       public var idleAmplitude : CGFloat = kDefaultAmplitude
    @IBInspectable
       public var numberOfWaves : CGFloat = kDefaultNumberOfWaves
    @IBInspectable
       public var phaseShift : CGFloat = kDefaultPhaseShift
    @IBInspectable
       public var density : CGFloat = kDefaultDensity
    @IBInspectable
       public var primaryWaveLineWidth : CGFloat = kDefaultPrimaryLineWidth
    @IBInspectable
       public var secondaryWaveLineWidth : CGFloat = kDefaultSecondaryLineWidth
    
    func setup(){
        self.waveColor = .white
        self.frequency = kDefaultFrequency
        
        self.amplitude = kDefaultAmplitude
        self.idleAmplitude = kDefaultIdleAmplitude
        
        self.numberOfWaves = kDefaultNumberOfWaves
        self.phaseShift = kDefaultPhaseShift
        self.density = kDefaultDensity
        
        self.primaryWaveLineWidth = kDefaultPrimaryLineWidth
        self.secondaryWaveLineWidth = kDefaultSecondaryLineWidth
        
        self.phase = self.phaseShift
    }
    
   public func update(withLevel:CGFloat) {
        self.phase += self.phaseShift
        self.amplitude = max(withLevel, self.idleAmplitude)
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.clear(bounds)

        backgroundColor?.set()
        context?.fill(rect)

        // We draw multiple sinus waves, with equal phases but altered amplitudes, multiplied by a parable function.
        for i in stride(from: 0, through: self.numberOfWaves, by: +1 as CGFloat) {
            let strokeLineWidth = i == 0 ? primaryWaveLineWidth : secondaryWaveLineWidth
            context?.setLineWidth(strokeLineWidth)

            let halfHeight = bounds.height / 2.0
            let width = bounds.width
            let mid = width / 2.0

            let maxAmplitude = halfHeight - (strokeLineWidth * 2)

            let progress = 1.0 - CGFloat(i) / CGFloat(numberOfWaves)
            let normedAmplitude = (1.5 * progress - (2.0 / numberOfWaves)) * amplitude

            let multiplier = CGFloat(min(1.0, (progress / 3.0 * 2.0) + (1.0 / 3.0)))
            (waveColor.withAlphaComponent(multiplier * waveColor.cgColor.alpha)).set()

            var x = 0
            while x < Int((width + density)) {
                // We use a parable to scale the sinus wave, that has its peak in the middle of the view.
                let scaling: CGFloat = -pow(1 / mid * (CGFloat(x) - mid), 2) + 1

                var y = scaling * maxAmplitude * normedAmplitude
                y = y * CGFloat(getSinF(width:width,x:x)) + CGFloat(halfHeight)

                if x == 0 {
                    context?.move(to: CGPoint(x: CGFloat(x), y: y))
                } else {
                    context?.addLine(to: CGPoint(x: CGFloat(x), y: y))
                }
                x += Int(density)
            }

            context?.strokePath()
        }
    }
    
    func getSinF(width:CGFloat,x:Int)->Float{
        let xDividedByWidth = CGFloat(x) / width
        let MultiplyPi = CGFloat(2 * Double.pi)
                
        return (sinf(Float(MultiplyPi * xDividedByWidth * frequency + phase)))
    }
}
