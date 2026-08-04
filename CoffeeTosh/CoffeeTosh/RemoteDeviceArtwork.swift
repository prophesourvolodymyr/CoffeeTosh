import SwiftUI

struct RemoteDeviceArtwork: View {
    let platform: RemoteDevicePlatform
    var size: CGFloat = 112

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(platform == .iPhone ? Color.white.opacity(0.94) : Color.black.opacity(0.22))

            Image(platform.imageAssetName)
                .resizable()
                .scaledToFit()
                .padding(8)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .accessibilityHidden(true)
    }
}
