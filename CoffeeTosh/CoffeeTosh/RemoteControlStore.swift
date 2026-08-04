import Combine
import Foundation


enum RemoteHostState: String, Codable, CaseIterable {
    case notSetUp
    case waitingForPhone
    case pairingRequest
    case ready
    case connected
    case paused
    case permissionNeeded
    case hostUnavailable
    case rejected
    case removed

    var title: String {
        switch self {
        case .notSetUp: return "Not set up"
        case .waitingForPhone: return "Waiting for device"
        case .pairingRequest: return "Pairing request"
        case .ready: return "Ready"
        case .connected: return "Connected"
        case .paused: return "Paused"
        case .permissionNeeded: return "Permission needed"
        case .hostUnavailable: return "Host unavailable"
        case .rejected: return "Request rejected"
        case .removed: return "Device removed"
        }
    }

    var detail: String {
        switch self {
        case .notSetUp:
            return "Pair a device to access this Mac."
        case .waitingForPhone:
            return "Waiting for device."
        case .pairingRequest:
            return "Review connection."
        case .ready:
            return "Ready for an approved device."
        case .connected:
            return "Remote viewing active."
        case .paused:
            return "Device temporarily unavailable."
        case .permissionNeeded:
            return "Screen Recording permission required."
        case .hostUnavailable:
            return "Remote Control unavailable."
        case .rejected:
            return "Connection request declined."
        case .removed:
            return "Device no longer trusted."
        }
    }

    var symbolName: String {
        switch self {
        case .notSetUp, .rejected, .removed:
            return "iphone"
        case .waitingForPhone:
            return "qrcode"
        case .pairingRequest:
            return "checkmark.shield"
        case .ready:
            return "checkmark.circle"
        case .connected:
            return "rectangle.connected.to.line.below"
        case .paused:
            return "pause.circle"
        case .permissionNeeded:
            return "lock.shield"
        case .hostUnavailable:
            return "exclamationmark.triangle"
        }
    }
}

enum RemoteHostAvailability: Equatable {
    case available
    case permissionNeeded
    case unavailable(String)
}

enum RemoteDevicePlatform: String, Codable, CaseIterable, Equatable {
    case iPhone
    case iPad
    case mac

    var title: String {
        switch self {
        case .iPhone: return "iPhone"
        case .iPad: return "iPad"
        case .mac: return "Mac"
        }
    }

    var imageAssetName: String {
        switch self {
        case .iPhone: return "device-iphone-17"
        case .iPad: return "device-ipad-pro-m5"
        case .mac: return "device-macbook-pro-m5"
        }
    }

    var systemImageName: String {
        switch self {
        case .iPhone: return "iphone.gen3"
        case .iPad: return "ipad"
        case .mac: return "laptopcomputer"
        }
    }

    static func inferred(from modelName: String) -> Self {
        let normalized = modelName.lowercased()
        if normalized.contains("ipad") {
            return .iPad
        }
        if normalized.contains("mac") {
            return .mac
        }
        return .iPhone
    }
}


enum RemoteDeviceState: String, Codable {
    case ready
    case connected
    case paused
    case disconnected
    case occupied

    var title: String {
        switch self {
        case .ready: return "Ready"
        case .connected: return "Connected"
        case .paused: return "Paused"
        case .disconnected: return "Disconnected"
        case .occupied: return "Host occupied"
        }
    }
}

struct PairedRemoteDevice: Identifiable, Codable, Equatable {
    let id: UUID
    var displayName: String
    var modelName: String
    var lastConnected: Date?
    var state: RemoteDeviceState
    var platform: RemoteDevicePlatform
    var peerName: String?
    var hostToken: String?

    private enum CodingKeys: String, CodingKey {
        case id, displayName, modelName, lastConnected, state, platform, peerName, hostToken
    }

    init(
        id: UUID,
        displayName: String,
        modelName: String,
        lastConnected: Date?,
        state: RemoteDeviceState,
        platform: RemoteDevicePlatform,
        peerName: String? = nil,
        hostToken: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.modelName = modelName
        self.lastConnected = lastConnected
        self.state = state
        self.platform = platform
        self.peerName = peerName
        self.hostToken = hostToken
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        displayName = try container.decode(String.self, forKey: .displayName)
        modelName = try container.decode(String.self, forKey: .modelName)
        lastConnected = try container.decodeIfPresent(Date.self, forKey: .lastConnected)
        state = try container.decode(RemoteDeviceState.self, forKey: .state)
        platform = try container.decodeIfPresent(RemoteDevicePlatform.self, forKey: .platform)
            ?? .inferred(from: modelName)
        peerName = try container.decodeIfPresent(String.self, forKey: .peerName)
        hostToken = try container.decodeIfPresent(String.self, forKey: .hostToken)
    }
}

struct RemotePairingInvitation: Identifiable, Codable, Equatable {
    let id: UUID
    let hostName: String
    let token: String
    let confirmationPhrase: String
    let createdAt: Date
    let expiresAt: Date

    var payload: String {
        var components = URLComponents()
        components.scheme = "coffeetosh"
        components.host = "pair"
        components.queryItems = [
            URLQueryItem(name: "host", value: hostName),
            URLQueryItem(name: "token", value: token),
            URLQueryItem(name: "phrase", value: confirmationPhrase)
        ]
        return components.url?.absoluteString ?? "coffeetosh://pair?token=\(token)"
    }

    func hasExpired(at date: Date = Date()) -> Bool {
        date >= expiresAt
    }
}

struct RemotePairingRequest: Identifiable, Equatable {
    let id: UUID
    let displayName: String
    let modelName: String
    let platform: RemoteDevicePlatform
    let confirmationPhrase: String
    let receivedAt: Date
    let peerName: String?
    let hostToken: String?

    init(
        id: UUID = UUID(),
        displayName: String,
        modelName: String,
        platform: RemoteDevicePlatform,
        confirmationPhrase: String,
        receivedAt: Date = Date(),
        peerName: String? = nil,
        hostToken: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.modelName = modelName
        self.platform = platform
        self.confirmationPhrase = confirmationPhrase
        self.receivedAt = receivedAt
        self.peerName = peerName
        self.hostToken = hostToken
    }
}


struct RemoteSession: Identifiable, Equatable {
    let id: UUID
    let deviceID: UUID
    let startedAt: Date
}

final class RemoteControlStore: ObservableObject {
    @Published private(set) var hostState: RemoteHostState
    @Published private(set) var availability: RemoteHostAvailability = .available
    @Published private(set) var devices: [PairedRemoteDevice]
    @Published private(set) var invitation: RemotePairingInvitation?
    @Published private(set) var pendingRequest: RemotePairingRequest?
    @Published private(set) var session: RemoteSession?
    @Published private(set) var lastMessage: String?

    private let defaults: UserDefaults
    private let hostName: String
    private let devicesKey = "remoteControl.pairedDevices"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.hostName = Host.current().localizedName ?? ProcessInfo.processInfo.hostName

        let loadedDevices: [PairedRemoteDevice]
        if let data = defaults.data(forKey: "remoteControl.pairedDevices"),
           let savedDevices = try? JSONDecoder().decode([PairedRemoteDevice].self, from: data) {
            loadedDevices = savedDevices
        } else {
            loadedDevices = []
        }

        self.devices = loadedDevices
        self.hostState = loadedDevices.isEmpty ? .notSetUp : .ready
    }

    var hostDisplayName: String { hostName }
    var canStartPairing: Bool { availability == .available }

    func beginPairing() {
        guard canStartPairing else { return }

        let invitation = RemotePairingInvitation(
            id: UUID(),
            hostName: hostName,
            token: UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased(),
            confirmationPhrase: Self.makeConfirmationPhrase(),
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(10 * 60)
        )

        self.invitation = invitation
    var onPairingStateChanged: (() -> Void)?
    var onPairingDecision: ((UUID, Bool, String?) -> Void)?
    var onRemoteSessionEnded: ((UUID) -> Void)?
        pendingRequest = nil
        lastMessage = nil
        hostState = .waitingForPhone
    }

    func cancelPairing() {
        guard invitation != nil || pendingRequest != nil else { return }
        invitation = nil
        pendingRequest = nil
        lastMessage = nil
        restoreBaseState()
    }

    func expirePairingIfNeeded(at date: Date = Date()) {
        guard let invitation, invitation.hasExpired(at: date) else { return }
        self.invitation = nil
        pendingRequest = nil
        lastMessage = "The pairing code expired. Start a new pairing to try again."
        restoreBaseState()
    }

    func receivePairingRequest(
        displayName: String,
        modelName: String,
        confirmationPhrase: String,
        platform: RemoteDevicePlatform = .iPhone
    ) -> Bool {
        expirePairingIfNeeded()
        guard let invitation,
              invitation.confirmationPhrase.caseInsensitiveCompare(confirmationPhrase) == .orderedSame,
              availability == .available else {
            return false
        }

        pendingRequest = RemotePairingRequest(
            id: UUID(),
            displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
            modelName: modelName.trimmingCharacters(in: .whitespacesAndNewlines),
            platform: platform,
            confirmationPhrase: invitation.confirmationPhrase,
            receivedAt: Date()
        )
        hostState = .pairingRequest
        return true
    }

    func approvePendingRequest() {
        guard let request = pendingRequest else { return }

        let device = PairedRemoteDevice(
            id: request.id,
            displayName: request.displayName.isEmpty ? request.platform.title : request.displayName,
            modelName: request.modelName.isEmpty ? request.platform.title : request.modelName,
            lastConnected: nil,
            state: .disconnected,
            platform: request.platform
        )

        devices.removeAll { $0.id == device.id }
        devices.append(device)
        persistDevices()
        invitation = nil
        pendingRequest = nil
        lastMessage = "\(device.displayName) is now paired with this Mac."
        hostState = .ready
    }

    func rejectPendingRequest() {
        guard pendingRequest != nil else { return }
        invitation = nil
        pendingRequest = nil
        hostState = .rejected
        lastMessage = "The connection request was declined."
    }

    func renameDevice(id: UUID, to name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty,
              let index = devices.firstIndex(where: { $0.id == id }) else { return }

        devices[index].displayName = trimmedName
        persistDevices()
        lastMessage = "Device renamed to \(trimmedName)."
    }

    func removeDevice(id: UUID) {
        guard let device = devices.first(where: { $0.id == id }) else { return }
        if session?.deviceID == id {
            endRemoteSession()
        }

        devices.removeAll { $0.id == id }
        persistDevices()
        hostState = devices.isEmpty ? .notSetUp : .ready
        lastMessage = "\(device.displayName) was removed from this Mac."
    }

    func markRemoteSessionConnected(for deviceID: UUID, at date: Date = Date()) -> Bool {
        guard availability == .available,
              session == nil,
              let index = devices.firstIndex(where: { $0.id == deviceID }) else {
            return false
        }

        for otherIndex in devices.indices where otherIndex != index {
            if devices[otherIndex].state == .connected {
                devices[otherIndex].state = .occupied
            }
        }

        devices[index].state = .connected
        devices[index].lastConnected = date
        session = RemoteSession(id: UUID(), deviceID: deviceID, startedAt: date)
        hostState = .connected
        persistDevices()
        return true
    }

    func markRemoteSessionPaused() {
        guard let session,
              let index = devices.firstIndex(where: { $0.id == session.deviceID }) else { return }
        devices[index].state = .paused
        hostState = .paused
    }

    func endRemoteSession() {
        guard let session else { return }
        if let index = devices.firstIndex(where: { $0.id == session.deviceID }) {
            devices[index].state = .disconnected
        }
        self.session = nil
        hostState = devices.isEmpty ? .notSetUp : .ready
        persistDevices()
    }

    func setAvailability(_ availability: RemoteHostAvailability) {
        self.availability = availability
        guard availability == .available else {
            invitation = nil
            pendingRequest = nil
            hostState = availability == .permissionNeeded ? .permissionNeeded : .hostUnavailable
            return
        }
        restoreBaseState()
    }

    func clearMessage() {
        lastMessage = nil
    }

    private func restoreBaseState() {
        guard availability == .available else {
            hostState = availability == .permissionNeeded ? .permissionNeeded : .hostUnavailable
            return
        }
        if session != nil {
            hostState = .connected
        } else {
            hostState = devices.isEmpty ? .notSetUp : .ready
        }
    }

    private func persistDevices() {
        guard let data = try? JSONEncoder().encode(devices) else { return }
        defaults.set(data, forKey: devicesKey)
    }

    private static func makeConfirmationPhrase() -> String {
        let first = ["amber", "quiet", "warm", "steady", "open", "calm"].randomElement() ?? "amber"
        let second = ["coffee", "roast", "signal", "window", "cocoa", "morning"].randomElement() ?? "coffee"
        return "\(first)-\(second)-\(Int.random(in: 100...999))"
    }
}
