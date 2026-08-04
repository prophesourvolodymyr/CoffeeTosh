import SwiftUI

struct RemoteDevicesView: View {
    @ObservedObject var store: RemoteControlStore

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showingPairing = false
    @State private var editingDeviceID: UUID?
    @State private var renameDraft = ""
    @State private var deviceToRemove: PairedRemoteDevice?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                RemoteDevicesHeader(
                    showingPairing: showingPairing,
                    canStartPairing: store.canStartPairing,
                    onAddDevice: startPairing,
                    onCancelPairing: cancelPairing
                )

                RemoteHostCard(
                    hostName: store.hostDisplayName,
                    hostState: store.hostState,
                    connectedDevice: connectedDevice,
                    onEndRemoteViewing: store.endRemoteSession
                )

                if showingPairing {
                    RemotePairingPanel(
                        invitation: store.invitation,
                        request: store.pendingRequest,
                        hostState: store.hostState,
                        onCancel: cancelPairing,
                        onApprove: approvePendingRequest,
                        onReject: store.rejectPendingRequest,
                        onRestart: startPairing
                    )
                    .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                }

                RemotePairedDevicesSection(
                    devices: store.devices,
                    editingDeviceID: $editingDeviceID,
                    renameDraft: $renameDraft,
                    onRename: beginRename,
                    onSaveRename: saveRename,
                    onCancelRename: cancelRename,
                    onRemove: { deviceToRemove = $0 },
                    onDisconnect: store.endRemoteSession,
                    onAddDevice: startPairing
                )

                Label(
                    "Remote viewing begins only after you approve a connection. Adding a device does not start a remote session.",
                    systemImage: "lock.shield"
                )
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(textSecondary)
                .fixedSize(horizontal: false, vertical: true)

                if let message = store.lastMessage {
                    Text(message)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(warmAmber)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(32)
            .frame(maxWidth: 920, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .topLeading)
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

    private var connectedDevice: PairedRemoteDevice? {
        guard let session = store.session else { return nil }
        return store.devices.first { $0.id == session.deviceID }
    }

    private func startPairing() {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            showingPairing = true
        }
        store.beginPairing()
    }

    private func cancelPairing() {
        store.cancelPairing()
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            showingPairing = false
        }
    }

    private func approvePendingRequest() {
        store.approvePendingRequest()
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            showingPairing = false
        }
    }

    private func beginRename(_ device: PairedRemoteDevice) {
        editingDeviceID = device.id
        renameDraft = device.displayName
    }

    private func saveRename(_ device: PairedRemoteDevice) {
        store.renameDevice(id: device.id, to: renameDraft)
        editingDeviceID = nil
    }

    private func cancelRename() {
        editingDeviceID = nil
    }
}

private struct RemoteDevicesHeader: View {
    let showingPairing: Bool
    let canStartPairing: Bool
    let onAddDevice: () -> Void
    let onCancelPairing: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 7) {
                Label("Remote Control", systemImage: "rectangle.connected.to.line.below")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(textPrimary)
                Text("Connect your iPhone or iPad to this Mac, then see exactly which device is viewing it.")
                    .font(.system(size: 14))
                    .foregroundStyle(textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 20)

            Button {
                if showingPairing {
                    onCancelPairing()
                } else {
                    onAddDevice()
                }
            } label: {
                Label(showingPairing ? "Cancel" : "Add Device", systemImage: showingPairing ? "xmark" : "plus")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(showingPairing ? textPrimary : popoverBase)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(showingPairing ? Color.white.opacity(0.08) : warmAmber)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!showingPairing && !canStartPairing)
            .opacity(!showingPairing && !canStartPairing ? 0.45 : 1)
        }
    }
}

private struct RemoteHostCard: View {
    let hostName: String
    let hostState: RemoteHostState
    let connectedDevice: PairedRemoteDevice?
    let onEndRemoteViewing: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 24) {
            RemoteDeviceArtwork(platform: .mac, size: 190)

            VStack(alignment: .leading, spacing: 8) {
                Text("THIS MAC")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(textSecondary)
                Text(hostName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(textPrimary)
                Text("MacBook Pro")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(textSecondary)

                HStack(spacing: 8) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    Text(hostState.title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(statusColor)
                }

                if let connectedDevice {
                    Label("Connected to \(connectedDevice.displayName)", systemImage: connectedDevice.platform.systemImageName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(warmAmber)
                } else {
                    Text("No iOS device is connected")
                        .font(.system(size: 12))
                        .foregroundStyle(textSecondary)
                }

                if connectedDevice != nil {
                    Button("End Remote Viewing", action: onEndRemoteViewing)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(warmAmber)
                        .buttonStyle(.plain)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardSection)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(statusColor.opacity(0.35), lineWidth: 1)
                )
        )
    }

    private var statusColor: Color {
        switch hostState {
        case .connected, .ready, .waitingForPhone, .pairingRequest:
            return warmAmber
        case .notSetUp, .rejected, .removed:
            return textSecondary
        case .paused, .permissionNeeded, .hostUnavailable:
            return Color.orange
        }
    }
}

private struct RemotePairingPanel: View {
    let invitation: RemotePairingInvitation?
    let request: RemotePairingRequest?
    let hostState: RemoteHostState
    let onCancel: () -> Void
    let onApprove: () -> Void
    let onReject: () -> Void
    let onRestart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(request == nil ? "Add a device" : "Review connection request")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(textPrimary)
                    Text(request == nil ? "Scan this code from Coffeetosh Remote on your iPhone or iPad." : "Confirm the device before it becomes trusted by this Mac.")
                        .font(.system(size: 12))
                        .foregroundStyle(textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Button("Cancel", action: onCancel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(textSecondary)
                    .buttonStyle(.plain)
            }

            if let request {
                requestContent(request)
            } else if let invitation {
                invitationContent(invitation)
            } else {
                HStack(spacing: 12) {
                    Image(systemName: hostState.symbolName)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(warmAmber)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(hostState.title)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(textPrimary)
                        Text(hostState.detail)
                            .font(.system(size: 11))
                            .foregroundStyle(textSecondary)
                    }
                    Spacer()
                    Button("Start New Pairing", action: onRestart)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(warmAmber)
                        .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(warmAmber.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(warmAmber.opacity(0.30), lineWidth: 1)
                )
        )
    }

    private func invitationContent(_ invitation: RemotePairingInvitation) -> some View {
        HStack(alignment: .center, spacing: 24) {
            RemotePairingQRCode(payload: invitation.payload)
                .frame(width: 184, height: 184)

            VStack(alignment: .leading, spacing: 10) {
                Text("Waiting for your device")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(textPrimary)
                Text("Open Coffeetosh Remote, choose this Mac, and confirm the phrase below.")
                    .font(.system(size: 12))
                    .foregroundStyle(textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("CONFIRMATION PHRASE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(textSecondary)
                Text(invitation.confirmationPhrase)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(warmAmber)
                    .textSelection(.enabled)
                Label("This Mac is not visible or controllable until you approve the request.", systemImage: "lock.shield")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    private func requestContent(_ request: RemotePairingRequest) -> some View {
        HStack(alignment: .center, spacing: 20) {
            RemoteDeviceArtwork(platform: request.platform, size: 148)

            VStack(alignment: .leading, spacing: 8) {
                Text(request.displayName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(textPrimary)
                Text(request.modelName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(textSecondary)
                Text("Allow this device to become trusted? Approval does not start remote viewing by itself.")
                    .font(.system(size: 12))
                    .foregroundStyle(textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(request.confirmationPhrase)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(warmAmber)

                HStack(spacing: 10) {
                    Button("Not Now", action: onReject)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(Color.white.opacity(0.08)))
                        .buttonStyle(.plain)
                    Button("Allow", action: onApprove)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(popoverBase)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(warmAmber))
                        .buttonStyle(.plain)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

private struct RemotePairedDevicesSection: View {
    let devices: [PairedRemoteDevice]
    @Binding var editingDeviceID: UUID?
    @Binding var renameDraft: String
    let onRename: (PairedRemoteDevice) -> Void
    let onSaveRename: (PairedRemoteDevice) -> Void
    let onCancelRename: () -> Void
    let onRemove: (PairedRemoteDevice) -> Void
    let onDisconnect: () -> Void
    let onAddDevice: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("DEVICES CONNECTED TO THIS MAC")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(textSecondary)
                    Text("Every approved iPhone or iPad appears here.")
                        .font(.system(size: 12))
                        .foregroundStyle(textSecondary)
                }
                Spacer()
                Text("\(devices.count)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(warmAmber)
            }

            if devices.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "iphone.gen3")
                        .font(.system(size: 27, weight: .medium))
                        .foregroundStyle(textSecondary)
                    Text("No devices added yet")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(textPrimary)
                    Text("Add an iPhone or iPad to see its name, model, and connection state on this Mac.")
                        .font(.system(size: 12))
                        .foregroundStyle(textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Button("Add Device", action: onAddDevice)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(warmAmber)
                        .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(RoundedRectangle(cornerRadius: 14).fill(cardSection))
            } else {
                VStack(spacing: 0) {
                    ForEach(devices) { device in
                        RemotePairedDeviceRow(
                            device: device,
                            isEditing: editingDeviceID == device.id,
                            renameDraft: $renameDraft,
                            onRename: { onRename(device) },
                            onSaveRename: { onSaveRename(device) },
                            onCancelRename: onCancelRename,
                            onRemove: { onRemove(device) },
                            onDisconnect: onDisconnect
                        )
                        if device.id != devices.last?.id {
                            Divider()
                                .background(textSecondary.opacity(0.15))
                                .padding(.leading, 164)
                        }
                    }
                }
                .background(RoundedRectangle(cornerRadius: 14).fill(cardSection))
            }
        }
    }
}

private struct RemotePairedDeviceRow: View {
    let device: PairedRemoteDevice
    let isEditing: Bool
    @Binding var renameDraft: String
    let onRename: () -> Void
    let onSaveRename: () -> Void
    let onCancelRename: () -> Void
    let onRemove: () -> Void
    let onDisconnect: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            RemoteDeviceArtwork(platform: device.platform, size: 124)

            VStack(alignment: .leading, spacing: 5) {
                if isEditing {
                    TextField("Device name", text: $renameDraft)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 13))
                    HStack(spacing: 12) {
                        Button("Cancel", action: onCancelRename)
                        Button("Save", action: onSaveRename)
                            .disabled(renameDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .buttonStyle(.plain)
                } else {
                    Text(device.displayName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(textPrimary)
                    Text("\(device.platform.title) · \(device.modelName)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(textSecondary)
                    HStack(spacing: 6) {
                        Text(device.state.title)
                        Text("·")
                        if let lastConnected = device.lastConnected {
                            Text(lastConnected, style: .relative)
                        } else {
                            Text("Not connected yet")
                        }
                    }
                    .font(.system(size: 11, weight: .medium))
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
                    Label("Device actions", systemImage: "ellipsis.circle")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(textSecondary)
                        .frame(width: 44, height: 44)
                }
                .menuStyle(.borderlessButton)
            }
        }
        .padding(16)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(device.displayName), \(device.platform.title), \(device.state.title)")
    }
}
