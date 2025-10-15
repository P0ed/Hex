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

struct Stats: RawRepresentable, Hashable, Codable {
	var rawValue: UInt32
}

extension Stats: Monoid {
	static var empty: Self { .init(rawValue: 0) }
	mutating func combine(_ other: Self) { rawValue |= other.rawValue }
}

extension Stats {

	private static func mask(width: UInt8, shift: UInt8) -> RawValue {
		((1 << width) - 1) << shift
	}
	private func get(width: UInt8, shift: UInt8) -> UInt8 {
		let mask = Self.mask(width: width, shift: shift)
		return UInt8((rawValue & mask) >> shift)
	}
	private mutating func set(_ value: UInt8, width: UInt8, shift: UInt8) {
		let mask = Self.mask(width: width, shift: shift)
		rawValue &= ~mask
		rawValue |= RawValue(value) << shift & mask
	}

	var moveType: MoveType {
		get { MoveType(rawValue: get(width: 2, shift: 0)) ?? .none }
		set { set(newValue.rawValue, width: 2, shift: 0) }
	}
	var armor: UInt8 {
		get { get(width: 2, shift: 2) }
		set { set(newValue, width: 2, shift: 2) }
	}
	var hardAttack: UInt8 {
		get { get(width: 2, shift: 4) }
		set { set(newValue, width: 2, shift: 4) }
	}
	var unitType: UnitType {
		get { UnitType(rawValue: get(width: 3, shift: 6)) ?? .inf }
		set { set(newValue.rawValue, width: 3, shift: 6) }
	}
	var atk: UInt8 {
		get { get(width: 5, shift: 9) }
		set { set(newValue, width: 5, shift: 9) }
	}
	var def: UInt8 {
		get { get(width: 5, shift: 14) }
		set { set(newValue, width: 5, shift: 14) }
	}
	var mov: UInt8 {
		get { get(width: 4, shift: 19) }
		set { set(newValue, width: 4, shift: 19) }
	}
	var rng: UInt8 {
		get { get(width: 3, shift: 23) }
		set { set(newValue, width: 3, shift: 23) }
	}
}

enum MoveType: UInt8, Hashable, Codable {
	case none, leg, wheel, track
}

enum UnitType: UInt8, Hashable, Codable {
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

	@discardableResult
	mutating func refill(amount: UInt8, cap: UInt8) -> UInt8 {
		let old = self
		self = UInt8(Swift.min(UInt16(cap), UInt16(self + amount)))
		return self - old
	}

	@discardableResult
	mutating func decrement(by amount: UInt8 = 1) -> UInt8 {
		let old = self
		self -= self < amount ? self : amount
		return old - self
	}
}
