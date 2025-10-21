struct Unit: Hashable, Codable {
	var id: UnitID
	var player: PlayerID
	var position: Hex
	var stats: Stats
}

struct Stats: RawRepresentable, Hashable, Codable {
	var rawValue: UInt64
}

extension Stats: Monoid {
	static var empty: Self { .init(rawValue: 0) }
	mutating func combine(_ other: Self) { rawValue |= other.rawValue }
}

extension Stats {

	private static func mask(width: UInt8, offset: UInt8) -> RawValue {
		((1 << width) - 1) << offset
	}
	private func get(width: UInt8, offset: UInt8) -> UInt8 {
		let mask = Self.mask(width: width, offset: offset)
		return UInt8((rawValue & mask) >> offset)
	}
	private mutating func set(_ value: UInt8, width: UInt8, offset: UInt8) {
		let mask = Self.mask(width: width, offset: offset)
		rawValue &= ~mask
		rawValue |= RawValue(value) << offset & mask
	}

	static var base: Self {
		.make { stats in
			stats.hp = 15
			stats.mp = 1
			stats.ap = 1
			stats.ammo = 15
			stats.fuel = 15
		}
	}

	static var shop: Self {
		modifying(.base) { stats in
			stats.mp = 0
			stats.ap = 0
		}
	}

	var hp: UInt8 {
		get { get(width: 4, offset: 0) }
		set { set(newValue, width: 4, offset: 0) }
	}
	var mp: UInt8 {
		get { get(width: 1, offset: 4) }
		set { set(newValue, width: 1, offset: 4) }
	}
	var ap: UInt8 {
		get { get(width: 1, offset: 5) }
		set { set(newValue, width: 1, offset: 5) }
	}
	var ammo: UInt8 {
		get { get(width: 4, offset: 6) }
		set { set(newValue, width: 4, offset: 6) }
	}
	var fuel: UInt8 {
		get { get(width: 4, offset: 10) }
		set { set(newValue, width: 4, offset: 10) }
	}
	var exp: UInt8 {
		get { get(width: 8, offset: 14) }
		set { set(newValue, width: 8, offset: 14) }
	}
	var ent: UInt8 {
		get { get(width: 3, offset: 22) }
		set { set(newValue, width: 3, offset: 22) }
	}

	var moveType: MoveType {
		get { MoveType(rawValue: get(width: 2, offset: 25)) ?? .none }
		set { set(newValue.rawValue, width: 2, offset: 25) }
	}
	var armor: UInt8 {
		get { get(width: 2, offset: 27) }
		set { set(newValue, width: 2, offset: 27) }
	}
	var hardAttack: UInt8 {
		get { get(width: 2, offset: 29) }
		set { set(newValue, width: 2, offset: 29) }
	}
	var unitType: UnitType {
		get { UnitType(rawValue: get(width: 3, offset: 31)) ?? .inf }
		set { set(newValue.rawValue, width: 3, offset: 31) }
	}
	var atk: UInt8 {
		get { get(width: 5, offset: 34) }
		set { set(newValue, width: 5, offset: 34) }
	}
	var def: UInt8 {
		get { get(width: 5, offset: 39) }
		set { set(newValue, width: 5, offset: 39) }
	}
	var mov: UInt8 {
		get { get(width: 4, offset: 44) }
		set { set(newValue, width: 4, offset: 44) }
	}
	var rng: UInt8 {
		get { get(width: 3, offset: 48) }
		set { set(newValue, width: 3, offset: 48) }
	}
}

enum MoveType: UInt8, Hashable, Codable {
	case none, leg, wheel, track
}

enum UnitType: UInt8, Hashable, Codable {
	case inf, recon, tank, art, antiAir, air
}

extension Unit {
	var untouched: Bool { stats.mp != 0 && stats.ap != 0 }
	var hasActions: Bool { canMove || canFire }
	var canMove: Bool { stats.mp != 0 }
	var canFire: Bool { stats.ap != 0 && stats.ammo != 0 }

	func canHit(unit: Unit) -> Bool {
		position.distance(to: unit.position) <= stats.rng
	}

	mutating func nextTurn(_ terrain: Terrain) {
		if untouched { stats.ent.increment(by: 1, cap: 7) }
		if untouched || terrain == .city { resupply() }
		stats.mp = 1
		stats.ap = 1
	}

	mutating func reinforce() {
		guard untouched else { return }
		stats.hp.increment(by: 15 / 2, cap: 15)
		resupply()
		stats.ap = 0
		stats.mp = 0
	}

	mutating func resupply() {
		guard untouched else { return }
		stats.ammo.increment(by: 15 / 2, cap: 15)
		stats.fuel.increment(by: 15 / 2, cap: 15)
		stats.ap = 0
		stats.mp = 0
	}

	var cost: UInt16 {
		switch stats.unitType {
		case .inf: 80
		case .recon: 180
		case .tank: 240
		case .art: 160
		default: 120
		}
	}

	var status: String {
		"\(stats.unitType)"
	}

	var description: String {
		"""
		\(stats.unitType)
		
		ATK: \(stats.atk) - \(stats.hardAttack)
		DEF: \(stats.def) - \(stats.armor)
		MOV: \(stats.mov) - \(stats.moveType)
		RNG: \(stats.rng)
		
		
		
		- - - - - - - -
		Cost: \(cost)
		"""
	}
}

extension UInt8 {

	@discardableResult
	mutating func increment(by amount: UInt8, cap: UInt8) -> UInt8 {
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
