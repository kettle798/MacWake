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

    // MARK: - Plausibility ceiling (the live "~107:56" report)

    func testAnImplausiblyLongDischargeEstimateIsHidden() {
        // ~108 hours from a thin-sample statistical skew, not a real prediction.
        let label = BatteryTimeEstimate.label(isPluggedIn: false, timeToFullCharge: nil, timeToEmpty: 388_560)
        XCTAssertNil(label)
    }

    func testAnImplausiblyLongChargeEstimateIsHidden() {
        // macOS's own kIOPSTimeToFullChargeKey can be unreliable during near-full trickle
        // charging — the same failure mode, on the charging side.
        let label = BatteryTimeEstimate.label(isPluggedIn: true, timeToFullCharge: 388_560, timeToEmpty: nil)
        XCTAssertNil(label)
    }

    func testAnEstimateRightAtTheCeilingIsStillShown() {
        XCTAssertEqual(
            BatteryTimeEstimate.label(isPluggedIn: false, timeToFullCharge: nil, timeToEmpty: BatteryTimeEstimate.plausibleCeiling),
            BatteryTimeEstimate.plausibleCeiling
        )
    }

    func testAnEstimateJustOverTheCeilingIsHidden() {
        XCTAssertNil(BatteryTimeEstimate.label(
            isPluggedIn: false, timeToFullCharge: nil, timeToEmpty: BatteryTimeEstimate.plausibleCeiling + 1
        ))
    }
}
