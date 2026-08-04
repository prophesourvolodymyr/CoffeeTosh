import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct RemotePairingQRCode: View {
    let payload: String

    var body: some View {
        Group {
            if let image = qrImage {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .padding(10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Image(systemName: "qrcode")
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(textSecondary)
            }
        }
        .accessibilityLabel("Pairing QR code")
    }

    private var qrImage: NSImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(payload.utf8)
        filter.correctionLevel = "H"

        guard let outputImage = filter.outputImage else { return nil }
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }

        return NSImage(
            cgImage: cgImage,
            size: NSSize(width: scaledImage.extent.width, height: scaledImage.extent.height)
        )
    }
}
