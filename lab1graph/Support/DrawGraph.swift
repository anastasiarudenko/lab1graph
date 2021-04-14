//
//  DrawGraph.swift
//  lab1graph
//
//  Created by Anastasia Rudenko on 10.09.2020.
//  Copyright © 2020 Anastasia Rudenko. All rights reserved.
//

import UIKit

func drawGraph(fun: ((Double) -> Double), _ confine: Int) -> UIImage? {
    let image = UIImage(named: "graph")!.resize(700)
    guard let inputCGImage = image.cgImage else {
        return nil
    }
    let colorSpace       = CGColorSpaceCreateDeviceRGB()
    let width            = inputCGImage.width
    let height           = inputCGImage.height
    let bitmapInfo       = RGBA32.bitmapInfo

    guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: colorSpace, bitmapInfo: bitmapInfo) else {
        return nil
    }
    context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))

    guard let buffer = context.data else {
        return nil
    }

    let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)

    for row in 0 ..< Int(height) {
        for column in 0 ..< Int(width) {
            let offset = row * width + column
            pixelBuffer[offset] = .white
        }
    }
    for i in 0 ..< Int(width) {
        let offset = height / 2 * width + i
        pixelBuffer[offset] = .black
    }
    for i in 0 ..< Int(height) {
        let offset = i * width + width / 2
        pixelBuffer[offset] = .black
    }
    
    let halfW = Double(width / 2)
    let halfH = Double(height / 2)
    
    let osX = confine
    let osY = osX * Int(halfH) / Int(halfW)
    for i in 0...width {
        var newX = Double(i) - halfW
        newX = newX * Double(osX) / halfW
        
        let newY = fun(newX)
        if abs(newY) < Double(osY) {
            var offset = 0.0
            var offsetInt = 0
            if newY > 0 {
                let yAsBuffer = Double(osY) - newY
                offset = yAsBuffer * halfH / Double(osY)
                offsetInt = Int(offset) * width + i
            } else {
                offset = -1 * newY * halfH / Double(osY)
                offsetInt = Int(offset) * width + Int(Double(width) * halfH) + i
            }
            if offsetInt < width * height {
                pixelBuffer[offsetInt] = .magenta
                pixelBuffer[offsetInt - 1] = .magenta
                pixelBuffer[offsetInt + 1] = .magenta
                pixelBuffer[offsetInt - width] = .magenta
                pixelBuffer[offsetInt - width - 1] = .magenta
                pixelBuffer[offsetInt - width + 1] = .magenta
                pixelBuffer[offsetInt + width] = .magenta
                pixelBuffer[offsetInt + width - 1] = .magenta
                pixelBuffer[offsetInt + width + 1] = .magenta
            }
        }
    }

    let outputCGImage = context.makeImage()!
    let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)

    return outputImage
}
