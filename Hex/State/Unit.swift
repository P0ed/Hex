struct Unit: Hashable, Codable {
	var country: Country
	var position: XY
	var stats: Stats
}

typealias UID = Int

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
		get { MoveType(rawValue: get(width: 2, offset: 25)) ?? .leg }
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

	var stars: UInt8 {
		modifying(4) { stars in stars.decrement(by: UInt8(exp.leadingZeroBitCount)) }
	}
}

enum MoveType: UInt8, Hashable, Codable {
	case leg, wheel, track, air
}

enum UnitType: UInt8, Hashable, Codable {
	case inf, recon, tank, art, antiAir, air, engineer, supply
}

extension Unit: DeadOrAlive {

	static var dead: Unit {
		.init(country: .dnr, position: .zero, stats: .empty)
	}

	var alive: Bool { stats.hp > 0 }
}

extension Unit {

	var untouched: Bool { stats.mp != 0 && stats.ap != 0 }
	var hasActions: Bool { canMove || canAttack }
	var canMove: Bool { stats.mp != 0 }
	var canAttack: Bool { stats.ap != 0 && stats.ammo != 0 }

	func canHit(unit: Unit) -> Bool {
		position.distance(to: unit.position) <= stats.rng * 2
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
}
