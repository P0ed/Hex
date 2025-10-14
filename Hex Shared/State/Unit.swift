struct Unit: Hashable, Codable {
	var id: UnitID
	var player: PlayerID
	var position: Hex
	var hp: UInt8
	var mp: UInt8
	var ammo: UInt8
	var fuel: UInt8
	var exp: UInt8
	var fired: Bool
	var stats: Stats
}

extension Unit {

	init(
		id: UnitID,
		player: PlayerID,
		position: Hex,
		stats: Stats
	) {
		self.id = id
		self.player = player
		self.position = position
		self.hp = 15
		self.mp = stats.mov
		self.ammo = 15
		self.fuel = 15
		self.exp = 0
		self.fired = false
		self.stats = stats
	}
}

struct Stats: Hashable, Codable {
	var typ: UnitType
	var atk: UInt8
	var def: UInt8
	var mov: UInt8
	var rng: UInt8
//	var flg: Flags
}

//struct Flags: RawRepresentable, Hashable, Codable {
//	var rawValue: UInt16
//}
//
//extension Flags {
//
//	private func bits(width: UInt8, shift: UInt8) -> UInt8 {
//		let mask: RawValue = 1 << (width + 1) - 1
//		return UInt8((rawValue & mask) >> shift)
//	}
//
//	var moveType: MoveType {
//		MoveType(rawValue: bits(width: 2, shift: 0)) ?? .leg
//	}
//	var armor: UInt8 {
//		/// # Soft, Light, Meduim, Heavy
//		bits(width: 2, shift: 2)
//	}
//	var hardAttack: UInt8 {
//		/// # None, Light, Medium, Heavy
//		bits(width: 2, shift: 4)
//	}
//	var airAttack: UInt8 {
//		bits(width: 2, shift: 6)
//	}
//	var isArty: Bool {
//		bits(width: 1, shift: 8) == 1
//	}
//	var isAntiAir: Bool {
//		bits(width: 1, shift: 9) == 1
//	}
//}

enum MoveType: UInt8, Hashable, Codable {
	case leg, wheel, track, air
}

enum UnitType: Hashable, Codable {
	case inf, recon, tank, art, antiAir, air
}

extension Unit {
	var hasActions: Bool { canMove || canFire }
	var canMove: Bool { mp != 0 }
	var canFire: Bool { !fired && ammo != 0 }

	func canHit(unit: Unit) -> Bool {
		position.distance(to: unit.position) <= stats.rng
	}

	mutating func nextTurn() {
		if mp == stats.mov, !fired { resupply() }
		mp = stats.mov
		fired = false
	}

	mutating func heal() {
		hp.refill(amount: 15 / 2, cap: 15)
		resupply()
	}

	mutating func resupply() {
		ammo.refill(amount: 15 / 2, cap: 15)
		fuel.refill(amount: 15 / 2, cap: 15)
	}
}

extension UInt8 {

	mutating func refill(amount: UInt8, cap: UInt8) {
		self = UInt8(Swift.min(UInt16(cap), UInt16(self + amount)))
	}

	mutating func decrement(by amount: UInt8 = 1) {
		self -= self < amount ? self : amount
	}
}
