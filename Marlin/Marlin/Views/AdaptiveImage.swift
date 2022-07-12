import SwiftUI

public struct AdaptiveImage: View {
    public let lightImage: Image
    public let darkImage: Image
    @Environment(\.colorScheme) var colorScheme
    
    public init(lightImage: Image, darkImage: Image) {
        self.lightImage = lightImage
        self.darkImage = darkImage
    }
    
    public var body: some View {
        if colorScheme == .light {
            lightImage
        } else {
            darkImage
        }
    }
}
