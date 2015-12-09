//
//  Filters.swift
//  Filters
//
//  Created by Rick Wargo on 12/8/15.
//  Copyright © 2015 Rick Wargo. All rights reserved.
//

import UIKit

public enum RGBColor {
    case Red
    case Green
    case Blue
}

let DNE = -987654321.0

public class Filter {
    var originalImage: UIImage?
    var rgbaImage: RGBAImage?
    var factor: Double = 1.0
    
    var imageWidth: Int = 0
    var imageHeight: Int = 0
    var imageSize: Int { return imageHeight * imageWidth }
    
    public init(image: UIImage, factor: Double) {
        originalImage = image
        self.factor = factor
        
        rgbaImage = RGBAImage(image: image)!
        
        imageWidth = rgbaImage!.width
        imageHeight = rgbaImage!.height
    }

    public convenience init(image: UIImage) {
        self.init(image: image, factor: 1.0)
    }
    
    
    func pixelAt(x: Int, y: Int) -> Pixel {
        let index = y * imageWidth + x
        return rgbaImage!.pixels[index]
    }
    
    func setPixel(x: Int, y: Int, pixel: Pixel) {
        let index = y * imageWidth + x
        rgbaImage!.pixels[index] = pixel
    }
    
    func inBand(val: Double) -> UInt8 {
        return UInt8(max(min(255, val), 0))
    }
    
    func setPixel(x: Int, y: Int, red: Double = DNE, green: Double = DNE, blue: Double = DNE) {
        var pixel = pixelAt(x, y: y)
        
        if red != DNE { pixel.red = inBand(red) }
        if green != DNE { pixel.green = inBand(green) }
        if blue != DNE { pixel.blue = inBand(blue) }
        
        setPixel(x, y: y, pixel: pixel)
    }

    // Override transform to apply filter for each pixel
    func transform(pixel: Pixel, x: Int = -1, y: Int = -1) -> Pixel {
        return pixel
    }
    
    func preTansform() { }
    
    func postTransform() { }
    
    public func apply() -> UIImage {
        preTansform()
        
        for y in 0..<imageHeight {
            for x in 0..<imageWidth {
                // for each pixel, transform it and replace it
                setPixel(x, y: y, pixel: transform(pixelAt(x, y: y), x: x, y: y))
            }
        }
        
        postTransform()

        return (rgbaImage?.toUIImage()!)!
    }
    
}

public class ConvolutionFilter: Filter {
    var filterMatrix: [[Int]] = [    // normal filter - no change
        [0, 0, 0],
        [0, 1, 0],
        [0, 0, 0]
    ]
    var filterHeight: Int { return filterMatrix.count }
    var filterWidth: Int { return filterMatrix[0].count }
    var bias: Int = 0
    
    public init(image: UIImage, factor: Double, matrix: [[Int]], bias: Int = 0) {
        super.init(image: image, factor: factor)
        
        self.filterMatrix = matrix
        self.bias = bias
    }
    
    override func transform(var pixel: Pixel, x: Int, y: Int) -> Pixel {
        var red = 0.0,
            green = 0.0,
            blue = 0.0
        
        for filterY in 0..<filterHeight {
            for filterX in 0..<filterWidth {
                let imageX = (x - filterWidth / 2 + filterX + imageWidth) % imageWidth
                let imageY = (y - filterHeight / 2 + filterY + imageHeight) % imageHeight
                
                let px = pixelAt(imageX, y: imageY)
                
                red += Double(Int(px.red) * filterMatrix[filterY][filterX])
                green += Double(Int(px.green) * filterMatrix[filterY][filterX])
                blue += Double(Int(px.blue) * filterMatrix[filterY][filterX])
            }
        }
        
        pixel.red = inBand(factor * red + Double(bias))
        pixel.green = inBand(factor * green + Double(bias))
        pixel.blue = inBand(factor * blue + Double(bias))
        
        return pixel
    }
}

public class ColorizeFilter: Filter {
    var avgRed: Int = 0
    var avgGreen: Int = 0
    var avgBlue: Int = 0
    var colors: Set<RGBColor> = []

    public init(image: UIImage, factor: Double, colors: Set<RGBColor>) {
        super.init(image: image, factor: factor)
        
        self.colors = colors
    }

    func findAverageColors() {
        for y in 0..<imageHeight {
            for x in 0..<imageWidth {
                let pixel = pixelAt(x, y: y)
                
                avgRed += Int(pixel.red)
                avgGreen += Int(pixel.green)
                avgBlue += Int(pixel.blue)
            }
        }
        avgRed /= imageSize
        avgGreen /= imageSize
        avgBlue /= imageSize
    }
    
    override func preTansform() {
        findAverageColors()
    }
    
    override func transform(var pixel: Pixel, x: Int, y: Int) -> Pixel {
        let redDelta = Int(pixel.red) - avgRed
        let greenDelta = Int(pixel.green) - avgGreen
        let blueDelta = Int(pixel.blue) - avgBlue
        
        var redModifier = factor
        var greenModifier = factor
        var blueModifier = factor
        
        if (Int(pixel.red) < avgRed) { redModifier = 1.0 }
        if (Int(pixel.green) < avgGreen) { greenModifier = 1.0 }
        if (Int(pixel.blue) < avgBlue) { blueModifier = 1.0 }
        
        if colors.contains(RGBColor.Red) {
            pixel.red = inBand(Double(avgRed) + redModifier * Double(redDelta))
        }
        if colors.contains(RGBColor.Green) {
            pixel.green = inBand(Double(avgGreen) + greenModifier * Double(greenDelta))
        }
        if colors.contains(RGBColor.Blue) {
            pixel.blue = inBand(Double(avgBlue) + blueModifier * Double(blueDelta))
        }
        
        return pixel
    }
}

public class GrayscaleFilter: Filter {
    override func transform(var pixel: Pixel, x: Int, y: Int) -> Pixel {
        let gray = (Double(pixel.red) * 0.2126 + Double(pixel.green) * 0.7152 + Double(pixel.blue) * 0.0722) * factor
        
        pixel.red = inBand(gray)
        pixel.green = inBand(gray)
        pixel.blue = inBand(gray)
        
        return pixel
        
    }
}

