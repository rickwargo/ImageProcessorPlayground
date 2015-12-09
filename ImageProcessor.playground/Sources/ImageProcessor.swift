import UIKit

func matrixSum(matrix: [[Int]]) -> Int {
    var sum: Int = 0
    for y in 0..<matrix.count {
        for x in 0..<matrix[0].count {
            sum += matrix[y][x]
        }
    }
    return sum
}

public typealias FilterFunc = (Double) -> UIImage

public class ImageProcessor {
    var image: UIImage
    
    // Apply filter: Blur image
    func blur(factor: Double)  -> UIImage {
        let filter_small = [
            [0, 1, 0],
            [1, 1, 1],
            [0, 1, 0]
        ]
        let filter_medium = [
            [0, 0, 1, 0, 0],
            [0, 1, 1, 1, 0],
            [1, 1, 1, 1, 1],
            [0, 1, 1, 1, 0],
            [0, 0, 1, 0, 0],
        ]
        let filter_max = [
            [0, 0, 0, 1, 0, 0, 0],
            [0, 0, 1, 1, 1, 0, 0],
            [0, 1, 1, 1, 1, 1, 0],
            [1, 1, 1, 1, 1, 1, 1],
            [0, 1, 1, 1, 1, 1, 0],
            [0, 0, 1, 1, 1, 0, 0],
            [0, 0, 0, 1, 0, 0, 0],
        ]
        
        let matricies = [filter_small, filter_medium, filter_max]
        let matrix = matricies[min(matricies.count-1, Int(round(factor)))]
        let filter = ConvolutionFilter(image: image, factor: 1.0 / Double(matrixSum(matrix)), matrix: matrix)
        return filter.apply()
    }
    
    // Apply filter: Motion Blur image
    func motionBlur(factor: Double) -> UIImage {
        let filter_small = [
            [1, 0, 0, 0, 0],
            [0, 1, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 1, 0],
            [0, 0, 0, 0, 1]
        ]
        let filter_medium = [
            [1, 0, 0, 0, 0, 0, 0],
            [0, 1, 0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0, 0, 0],
            [0, 0, 0, 1, 0, 0, 0],
            [0, 0, 0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0, 1, 0],
            [0, 0, 0, 0, 0, 0, 1]
        ]
        let filter_max = [
            [1, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 1, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 1, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 1, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 1, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 1, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 1]
        ]

        let matricies = [filter_small, filter_medium, filter_max]
        let matrix = matricies[min(matricies.count-1, Int(round(factor)))]
        let filter = ConvolutionFilter(image: image, factor: 1.0 / Double(matrixSum(matrix)), matrix: matrix)
        return filter.apply()
    }
    
    func brightness(factor: Double) -> UIImage {
        let identity_matrix = [
            [0, 0, 0],
            [0, 1, 0],
            [0, 0, 0]
        ]
        
        let filter = ConvolutionFilter(image: image, factor: factor, matrix: identity_matrix)
        return filter.apply()
    }
    
    func grayscale(factor: Double) -> UIImage {
        let filter = GrayscaleFilter(image: image, factor: factor)
        return filter.apply()
    }
    
    func cyan(factor: Double) -> UIImage {
        let filter = ColorizeFilter(image: image, factor: factor, colors: [RGBColor.Green, RGBColor.Blue])
        return filter.apply()
    }
    
    var availableFilters = [String: FilterFunc]()
    
    func addFilter(filterName: String, filter: FilterFunc) {
        availableFilters[filterName] = filter
    }
    
    public init(image: UIImage) {
        self.image = image
        
        addFilter("Blur", filter: ( blur ))
        addFilter("Motion Blur", filter: ( motionBlur ))
        addFilter("Brightness", filter: ( brightness ))
        addFilter("Grayscale", filter: ( grayscale ))
        addFilter("Cyan", filter: ( cyan ))
    }
    
    public func applyFilter(name: String, factor: Double = 1.0) -> UIImage? {
        if (availableFilters[name] != nil) {
            
            print("Applying filter: " + name + ", factor: " + String(factor))
            let filterFunc = availableFilters[name]!
            return filterFunc(factor)
        }
        
        return nil
    }
    
    public func applyFilterList(filters: [(name: String, factor: Double)]) -> UIImage? {
        let originalImage = self.image
        
        for filter in filters {
            self.image = applyFilter(filter.name, factor: filter.factor)!
        }
        
        let filteredImage = self.image
        self.image = originalImage
        
        return filteredImage
    }
}