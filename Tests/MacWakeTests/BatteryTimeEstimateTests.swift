import XCTest
@testable import MacWake

final class BatteryTimeEstimateTests: XCTestCase {
    func testOnBatteryShowsTimeToEmpty() {
        let label = BatteryTimeEstimate.label(isPluggedIn: false, timeToFullCharge: 1800, timeToEmpty: 3600)
        XCTAssertEqual(label, 3600)
    }

    func testWhileChargingShowsTimeToFull() {
        // The reported gap: Time Remaining showed nothing at all while charging, because
        // remainingBatteryEstimate is deliberately discharge-only and nothing picked a
        // charging-side figure to show instead.
        let label = BatteryTimeEstimate.label(isPluggedIn: true, timeToFullCharge: 1800, timeToEmpty: 3600)
        XCTAssertEqual(label, 1800)
    }

    func testWhileChargingWithNoEstimateYetShowsNothing() {
        // Already full, at the charge limit, or macOS hasn't settled on a number yet — all
        // resolve to nil upstream, and there is deliberately no fallback to the discharge
        // figure while plugged in (it would read as time until empty on a charging Mac).
        let label = BatteryTimeEstimate.label(isPluggedIn: true, timeToFullCharge: nil, timeToEmpty: 3600)
        XCTAssertNil(label)
    }

    func testOnBatteryWithNoEstimateShowsNothing() {
        let label = BatteryTimeEstimate.label(isPluggedIn: false, timeToFullCharge: 1800, timeToEmpty: nil)
        XCTAssertNil(label)
    }
}
