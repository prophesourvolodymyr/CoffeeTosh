import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct RemoteControlView: View {
    @ObservedObject var store: RemoteControlStore

    @State private var showingManagement = false
    @State private var editingDeviceID: UUID?
    @State private var renameDraft = ""
    @State private var deviceToRemove: PairedRemoteDevice?

    var body: some View {
        ScrollView {
            Group {
                if showingManagement {
                    managementContent
                } else {
                    overviewContent
                }
            }
            .padding(16)
        }
        .background(popoverBase)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            store.expirePairingIfNeeded()
        }
        .alert(item: $deviceToRemove) { device in
            Alert(
                title: Text("Remove \(device.displayName)?"),
                message: Text("This device will need to pair again before it can connect to this Mac."),
                primaryButton: .destructive(Text("Remove")) {
                    store.removeDevice(id: device.id)
                },
                secondaryButton: .cancel()
            )
        }
    }

    @ViewBuilder
    private var overviewContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            RemoteMacBook3DView()
                .frame(maxWidth: .infinity)
                .frame(height: 172)
                .background(cardSection.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(warmAmber.opacity(0.16), lineWidth: 1)
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Interactive MacBook. Click to close or open the lid.")

            HStack(spacing: 10) {
                Image("logo-filled")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Remote Control")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(textPrimary)
                }

                Spacer(minLength: 0)
            }

            Text("Pair a device to access this Mac.")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(textSecondary)
            hostStatusCard

            if let invitation = store.invitation {
                if let request = store.pendingRequest {
                    pairingRequestCard(request)
                } else {
                    pairingInvitationCard(invitation)
                }
            } else {
                Button(action: store.beginPairing) {
                    Label("Add Device", systemImage: "qrcode")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(popoverBase)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 9).fill(warmAmber))
                }
                .buttonStyle(.plain)
                .disabled(!store.canStartPairing)
                .opacity(store.canStartPairing ? 1 : 0.45)
            }

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showingManagement = true
                }
            } label: {
                HStack {
                    Label("Manage Devices", systemImage: "ipad.and.iphone")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 9).fill(cardSection))
            }
            .buttonStyle(.plain)

            if let session = store.session,
               let device = store.devices.first(where: { $0.id == session.deviceID }) {
                activeSessionCard(device: device, startedAt: session.startedAt)
            }

            if !store.devices.isEmpty {
                deviceSummary
            } else if store.hostState == .notSetUp {
                Text("No paired devices yet.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(textSecondary)
            }

            if store.hostState == .permissionNeeded {
                Button("Open Screen Recording Permissions", action: openScreenRecordingSettings)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(warmAmber)
                    .buttonStyle(.plain)
            }

            privacyStatement
            messageView
        }
    }

    @ViewBuilder
    private var managementContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showingManagement = false
                }
            } label: {
                Label("Remote Control", systemImage: "chevron.left")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(textSecondary)
            }
            .buttonStyle(.plain)

            HStack {
                Text("Paired Devices")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(textPrimary)
                Spacer()
                Text("\(store.devices.count)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(warmAmber)
            }

            Text("One device controls this Mac at a time.")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(textSecondary)

            if store.devices.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "iphone.gen3")
                        .font(.system(size: 27, weight: .medium))
                        .foregroundStyle(textSecondary)
                    Text("No paired devices")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(textPrimary)
                    Text("Pair an iPhone or iPad.")
                        .font(.system(size: 11))
                        .foregroundStyle(textSecondary)
                    Button("Add a device") {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showingManagement = false
                        }
                        store.beginPairing()
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(warmAmber)
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .background(RoundedRectangle(cornerRadius: 10).fill(cardSection))
            } else {
                VStack(spacing: 0) {
                    ForEach(store.devices) { device in
                        RemoteDeviceRow(
                            device: device,
                            isEditing: editingDeviceID == device.id,
                            renameDraft: $renameDraft,
                            onRename: {
                                editingDeviceID = device.id
                                renameDraft = device.displayName
                            },
                            onSaveRename: {
                                store.renameDevice(id: device.id, to: renameDraft)
                                editingDeviceID = nil
                            },
                            onCancelRename: {
                                editingDeviceID = nil
                            },
                            onRemove: {
                                deviceToRemove = device
                            },
                            onDisconnect: {
                                store.endRemoteSession()
                            }
                        )
                        if device.id != store.devices.last?.id {
                            Divider()
                                .background(textSecondary.opacity(0.15))
                                .padding(.leading, 48)
                        }
                    }
                }
                .background(RoundedRectangle(cornerRadius: 10).fill(cardSection))
            }

            privacyStatement
            messageView
        }
    }

    private var hostStatusCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: store.hostState.symbolName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(statusColor)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(store.hostState.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(textPrimary)
                Text(hostStatusDetail)
                    .font(.system(size: 11))
                    .foregroundStyle(textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(cardSection)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(statusColor.opacity(0.28), lineWidth: 1)
                )
        )
    }

    private func pairingInvitationCard(_ invitation: RemotePairingInvitation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            RemoteQRCodeView(payload: invitation.payload)
                .frame(maxWidth: .infinity)
                .frame(height: 142)

            Text("Scan with Coffeetosh Remote.")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(textSecondary)

            VStack(alignment: .leading, spacing: 3) {
                Text("PHRASE")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(textSecondary)
                Text(invitation.confirmationPhrase)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundStyle(warmAmber)
                    .textSelection(.enabled)
            }

            HStack {
                Label("Waiting for device", systemImage: "dot.radiowaves.left.and.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(warmAmber)
                Spacer()
                Button("Cancel") {
                    store.cancelPairing()
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(textSecondary)
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 10).fill(cardSection))
    }

    private func pairingRequestCard(_ request: RemotePairingRequest) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                RemoteDeviceArtwork(platform: request.platform, size: 50)

                VStack(alignment: .leading, spacing: 3) {
                    Text(request.displayName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(textPrimary)
                    Text(request.modelName)
                        .font(.system(size: 11))
                        .foregroundStyle(textSecondary)
                }
            }

            Text("Allow remote access from this device?")
                .font(.system(size: 11))
                .foregroundStyle(textSecondary)

            Text(request.confirmationPhrase)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(warmAmber)

            HStack(spacing: 8) {
                Button("Not Now") {
                    store.rejectPendingRequest()
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.06)))
                .buttonStyle(.plain)

                Button("Allow") {
                    store.approvePendingRequest()
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(popoverBase)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 8).fill(warmAmber))
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(cardSection)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(warmAmber.opacity(0.35), lineWidth: 1))
        )
    }

    private func activeSessionCard(device: PairedRemoteDevice, startedAt: Date) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Remote viewing active", systemImage: "dot.radiowaves.left.and.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(warmAmber)
                Spacer()
                Text(startedAt, style: .relative)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(textSecondary)
            }

            Text(device.displayName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(textPrimary)

            Button("End Remote Viewing") {
                store.endRemoteSession()
            }
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(warmAmber)
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(warmAmber.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(warmAmber.opacity(0.35), lineWidth: 1))
        )
    }

    private var deviceSummary: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("DEVICES")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(textSecondary)
                Spacer()
                Text("\(store.devices.count)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(warmAmber)
            }

            ForEach(store.devices.prefix(2)) { device in
                HStack(spacing: 8) {
                    RemoteDeviceArtwork(platform: device.platform, size: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(device.displayName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(textPrimary)
                        Text(device.state.title)
                            .font(.system(size: 10))
                            .foregroundStyle(textSecondary)
                    }
                    Spacer()
                }
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(cardSection))
    }

    private var privacyStatement: some View {
        Label("Approval required.", systemImage: "lock.shield")
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(textSecondary)
    }

    @ViewBuilder
    private var messageView: some View {
        if let message = store.lastMessage {
            Text(message)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(warmAmber)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var hostStatusDetail: String {
        switch store.availability {
        case .available:
            return store.hostState.detail
        case .permissionNeeded:
            return "Screen Recording permission required."
        case .unavailable(let reason):
            return reason
        }
    }

    private var statusColor: Color {
        switch store.hostState {
        case .connected, .ready:
            return warmAmber
        case .waitingForPhone, .pairingRequest:
            return warmAmber
        case .notSetUp:
            return textSecondary
        case .paused, .permissionNeeded, .hostUnavailable:
            return Color.orange
        case .rejected, .removed:
            return textSecondary
        }
    }

    private func openScreenRecordingSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") else { return }
        NSWorkspace.shared.open(url)
    }
}

private struct RemoteDeviceRow: View {
    let device: PairedRemoteDevice
    let isEditing: Bool
    @Binding var renameDraft: String
    let onRename: () -> Void
    let onSaveRename: () -> Void
    let onCancelRename: () -> Void
    let onRemove: () -> Void
    let onDisconnect: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            RemoteDeviceArtwork(platform: device.platform, size: 48)

            VStack(alignment: .leading, spacing: 4) {
                if isEditing {
                    TextField("Device name", text: $renameDraft)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12))
                    HStack(spacing: 10) {
                        Button("Cancel", action: onCancelRename)
                        Button("Save", action: onSaveRename)
                            .disabled(renameDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .font(.system(size: 10, weight: .semibold))
                    .buttonStyle(.plain)
                } else {
                    Text(device.displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(textPrimary)
                    Text(device.modelName)
                        .font(.system(size: 10))
                        .foregroundStyle(textSecondary)
                    HStack(spacing: 5) {
                        Text(device.state.title)
                        Text("·")
                        if let lastConnected = device.lastConnected {
                            Text(lastConnected, style: .relative)
                        } else {
                            Text("Not connected yet")
                        }
                    }
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(device.state == .connected ? warmAmber : textSecondary)
                }
            }

            Spacer(minLength: 0)

            if !isEditing {
                Menu {
                    Button("Rename", action: onRename)
                    if device.state == .connected || device.state == .paused {
                        Button("Disconnect", action: onDisconnect)
                    }
                    Divider()
                    Button("Remove", role: .destructive, action: onRemove)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(textSecondary)
                        .frame(width: 28, height: 28)
                }
                .menuStyle(.borderlessButton)
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 10)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(device.displayName), \(device.state.title)")
    }
}

private struct RemoteQRCodeView: View {
    let payload: String

    var body: some View {
        Group {
            if let image = qrImage {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .padding(8)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "qrcode")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(textSecondary)
            }
        }
    }

    private var qrImage: NSImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(payload.utf8)
        filter.correctionLevel = "H"

        guard let outputImage = filter.outputImage else { return nil }
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 8, y: 8))
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }

        return NSImage(
            cgImage: cgImage,
            size: NSSize(width: scaledImage.extent.width, height: scaledImage.extent.height)
        )
    }
}
