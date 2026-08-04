//
//  CoffeeToshTests.swift
//  CoffeeToshTests
//
//  Created by Volodymur Vasualkiw on 3/3/26.
//

import Testing
import Foundation
@testable import CoffeeTosh

struct CoffeeToshTests {

    @Test func pairingApprovalCreatesTrustedDevice() {
        let suiteName = "RemoteControlStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = RemoteControlStore(defaults: defaults)
        #expect(store.hostState == .notSetUp)

        store.beginPairing()
        #expect(store.hostState == .waitingForPhone)

        guard let phrase = store.invitation?.confirmationPhrase else {
            #expect(Bool(false))
            return
        }

        #expect(!store.receivePairingRequest(
            displayName: "My iPhone",
            modelName: "iPhone",
            confirmationPhrase: "wrong-phrase"
        ))
        #expect(store.receivePairingRequest(
            displayName: "My iPhone",
            modelName: "iPhone",
            confirmationPhrase: phrase
        ))
        #expect(store.hostState == .pairingRequest)

        store.approvePendingRequest()
        #expect(store.hostState == .ready)
        #expect(store.devices.count == 1)
        #expect(store.devices.first?.displayName == "My iPhone")
    }

    @Test func endingRemoteSessionRetainsPairing() {
        let suiteName = "RemoteControlStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = RemoteControlStore(defaults: defaults)
        store.beginPairing()

        guard let phrase = store.invitation?.confirmationPhrase else {
            #expect(Bool(false))
            return
        }

        _ = store.receivePairingRequest(
            displayName: "Travel phone",
            modelName: "iPhone",
            confirmationPhrase: phrase
        )
        store.approvePendingRequest()

        guard let deviceID = store.devices.first?.id else {
            #expect(Bool(false))
            return
        }

        #expect(store.markRemoteSessionConnected(for: deviceID))
        #expect(store.hostState == .connected)
        store.endRemoteSession()
        #expect(store.hostState == .ready)
        #expect(store.devices.first?.state == .disconnected)
        #expect(store.devices.count == 1)
    }

    @Test func pairingPreservesDevicePlatform() {
        let suiteName = "RemoteControlStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = RemoteControlStore(defaults: defaults)
        store.beginPairing()

        guard let phrase = store.invitation?.confirmationPhrase else {
            #expect(Bool(false))
            return
        }

        #expect(store.receivePairingRequest(
            displayName: "Desk iPad",
            modelName: "iPad Pro",
            confirmationPhrase: phrase,
            platform: .iPad
        ))
        store.approvePendingRequest()

        #expect(store.devices.first?.platform == .iPad)
        #expect(store.devices.first?.modelName == "iPad Pro")
    }

    @Test func legacyDeviceDataInfersIPhonePlatform() throws {
        let id = UUID()
        let object: [String: Any] = [
            "id": id.uuidString,
            "displayName": "Legacy phone",
            "modelName": "iPhone",
            "lastConnected": NSNull(),
            "state": "disconnected"
        ]
        let data = try JSONSerialization.data(withJSONObject: object)
        let device = try JSONDecoder().decode(PairedRemoteDevice.self, from: data)

        #expect(device.id == id)
        #expect(device.platform == .iPhone)
    }

}
