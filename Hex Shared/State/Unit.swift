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
	var atk: UInt8
	var def: UInt8
	var mov: UInt8
	var rng: UInt8
	var flg: Flags
}

struct Flags: RawRepresentable, Hashable, Codable {
	var rawValue: UInt16
}

extension Flags: Monoid {
	static var empty: Flags { .init(rawValue: 0) }
	mutating func combine(_ other: Flags) { rawValue |= other.rawValue }
}

extension Flags {

	private static func mask(width: UInt8, shift: UInt8) -> RawValue {
		(1 << (width + 1) - 1) << shift
	}

	private func bits(width: UInt8, shift: UInt8) -> UInt8 {
		let mask = Self.mask(width: width, shift: shift)
		return UInt8((rawValue & mask) >> shift)
	}

	private mutating func setBits(_ value: UInt8, width: UInt8, shift: UInt8) {
		let mask = Self.mask(width: width, shift: shift)
		rawValue &= ~mask
		rawValue |= RawValue(value) << shift & mask
	}

	var moveType: MoveType {
		get { MoveType(rawValue: bits(width: 2, shift: 0)) ?? .none }
		set { setBits(newValue.rawValue, width: 2, shift: 0) }
	}
	var armor: UInt8 {
		get { bits(width: 2, shift: 2) }
		set { setBits(newValue, width: 2, shift: 2) }
	}
	var hardAttack: UInt8 {
		get { bits(width: 2, shift: 4) }
		set { setBits(newValue, width: 2, shift: 4) }
	}
	var isArty: Bool {
		get { bits(width: 1, shift: 6) == 1 }
		set { setBits(newValue ? 1 : 0, width: 1, shift: 6) }
	}
	var isAntiAir: Bool {
		get { bits(width: 1, shift: 7) == 1 }
		set { setBits(newValue ? 1 : 0, width: 1, shift: 7) }
	}
}

enum MoveType: UInt8, Hashable, Codable {
	case none, leg, wheel, track
}

enum UnitType: Hashable, Codable {
	case inf, recon, tank, art, antiAir, air
}

extension Unit {
	var hasActions: Bool { canMove || canFire }
	var canMove: Bool { mp != 0 }
	var canFire: Bool { !fired && ammo != 0 }

	var type: UnitType {
		switch stats.flg.armor {
		case 0: stats.flg.isArty ? .art : .inf
		case 1: .recon
		case 2: .tank
		default: .tank
		}
	}

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
