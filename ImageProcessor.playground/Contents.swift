//: ## ImageProcessor
//: by: Rick Wargo, 12/9/2015
//: ### NOTE
//: Filter code available in the file Filters.swift (refer to the Sources folder).
//: Code for the ImageProcessor in ImageProcessor.swift. These files are available to be viewed in
//: the Project Navigator.
//: If the Project Navigator is not visible, press Cmd-1 to make it visible on the left hand side
//: and click on Filters.swift to inspect code. Moved to a separate file to speed processing time
//: as it performs a large number of iterations. This requires newer versions of Xcode.

import UIKit

let image = UIImage(named: "sample")!

// Initiate an image processor for the supplied image
let ip = ImageProcessor(image: image)

// Call a named filter on that image
let grayscaled = ip.applyFilter("Grayscale")

// Pass a factor to increase the brightness on the grayscale filter
// Note: applyFilter always starts from the original image
let grayscaled2 = ip.applyFilter("Grayscale", factor: 1.3)

// Call a sequence of filters and associated factors (1 being no additional influence on image processing)
// This is an arbitrary list of tuples (name: String, factor: Double), applied to the original image sequentially
// Note: applyFilterList always starts from the original image
let multiple = ip.applyFilterList([("Blur", 1.0), ("Motion Blur", 2.0), ("Brightness", 1.25), ("Grayscale", 1.0), ("Cyan", 2.0)])
                    
