struct Unit: Hashable, Codable {
	var id: UnitID
	var player: PlayerID
	var position: Hex
	var hp: Cap
	var mp: Cap
	var ammo: Cap
	var exp: UInt8 = 0
	var fired: Bool = false
	var stats: Stats
}

struct Stats: Hashable, Codable {
	var typ: UnitType
	var atk: UInt8
	var def: UInt8
	var mov: UInt8
	var rng: UInt8
}

enum UnitType: Hashable, Codable {
	case inf, recon, tank, art, antiAir, air
}

struct Cap: Hashable, Codable {
	var value: UInt8
	var max: UInt8

	init(_ cap: UInt8) {
		value = cap
		max = cap
	}
}

extension Unit {
	var hasActions: Bool { canMove || canFire }
	var canMove: Bool { !mp.isEmpty }
	var canFire: Bool { !fired && !ammo.isEmpty }

	func canHit(unit: Unit) -> Bool {
		position.distance(to: unit.position) <= stats.rng
	}

	mutating func nextTurn() {
		mp.refill()
		fired = false
	}
}

extension Cap {

	var isEmpty: Bool { value == 0 }

	mutating func refill(amount: UInt8? = .none) {
		value = amount.map { dv in min(max, value + dv) } ?? max
	}

	mutating func decrement(amount: UInt8 = 1) {
		value -= value < amount ? value : amount
	}
}
