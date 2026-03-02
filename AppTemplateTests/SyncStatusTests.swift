import Testing
@testable import AppTemplate

@Suite("SyncStatus")
struct SyncStatusTests {

    @Test("idle is not active")
    func idleNotActive() {
        let status = SyncStatus.idle
        #expect(status.isActive == false)
    }

    @Test("syncing is active")
    func syncingIsActive() {
        let status = SyncStatus.syncing
        #expect(status.isActive == true)
    }

    @Test("error is not active")
    func errorNotActive() {
        let status = SyncStatus.error("test error")
        #expect(status.isActive == false)
    }

    @Test("offline is not active")
    func offlineNotActive() {
        let status = SyncStatus.offline
        #expect(status.isActive == false)
    }

    @Test("equatable works for all cases")
    func equatable() {
        #expect(SyncStatus.idle == SyncStatus.idle)
        #expect(SyncStatus.syncing == SyncStatus.syncing)
        #expect(SyncStatus.offline == SyncStatus.offline)
        #expect(SyncStatus.error("a") == SyncStatus.error("a"))
        #expect(SyncStatus.error("a") != SyncStatus.error("b"))
        #expect(SyncStatus.idle != SyncStatus.syncing)
    }
}
