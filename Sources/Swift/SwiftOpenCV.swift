import UIKit
import ObjCOpenCV

public struct SwiftOpenCV {
    public static func openCVVersionString() -> String {
        return OpenCVWrapper.openCVVersionString()
    }

    public static func processImage(_ image: UIImage) -> UIImage? {
        return OpenCVWrapper.processImage(image)
    }
}
