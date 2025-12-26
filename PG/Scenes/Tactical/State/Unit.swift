struct Unit: Hashable {
	var country: Country
	var position: XY
	var stats: Stats
}

typealias UID = Int

struct Stats: RawRepresentable, Hashable {
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
	var exp: UInt8 {
		get { get(width: 8, offset: 10) }
		set { set(newValue, width: 8, offset: 10) }
	}
	var ent: UInt8 {
		get { get(width: 3, offset: 18) }
		set { set(newValue, width: 3, offset: 18) }
	}
	var unitType: UnitType {
		get { UnitType(rawValue: get(width: 3, offset: 21)) ?? .inf }
		set { set(newValue.rawValue, width: 3, offset: 21) }
	}
	var moveType: MoveType {
		get { MoveType(rawValue: get(width: 2, offset: 24)) ?? .leg }
		set { set(newValue.rawValue, width: 2, offset: 24) }
	}
	var ini: UInt8 {
		get { get(width: 4, offset: 26) }
		set { set(newValue, width: 4, offset: 26) }
	}
	var softAtk: UInt8 {
		get { get(width: 4, offset: 30) }
		set { set(newValue, width: 4, offset: 30) }
	}
	var hardAtk: UInt8 {
		get { get(width: 4, offset: 34) }
		set { set(newValue, width: 4, offset: 34) }
	}
	var airAtk: UInt8 {
		get { get(width: 4, offset: 38) }
		set { set(newValue, width: 4, offset: 38) }
	}
	var groundDef: UInt8 {
		get { get(width: 4, offset: 42) }
		set { set(newValue, width: 4, offset: 42) }
	}
	var airDef: UInt8 {
		get { get(width: 4, offset: 46) }
		set { set(newValue, width: 4, offset: 46) }
	}
	var mov: UInt8 {
		get { get(width: 4, offset: 50) }
		set { set(newValue, width: 4, offset: 50) }
	}
	var rng: UInt8 {
		get { get(width: 3, offset: 54) }
		set { set(newValue, width: 3, offset: 54) }
	}
}

extension Stats {

	var stars: UInt8 {
		modifying(4) { stars in stars.decrement(by: UInt8(exp.leadingZeroBitCount)) }
	}

	func atk(_ dst: Stats) -> UInt8 {
		switch dst.moveType {
		case .leg, .wheel: softAtk
		case .track: hardAtk
		case .air: airAtk
		}
	}

	func def(_ src: Stats) -> UInt8 {
		src.moveType == .air ? airDef : groundDef
	}
}

enum MoveType: UInt8, Hashable, Codable {
	case leg, wheel, track, air
}

enum UnitType: UInt8, Hashable, Codable {
	case inf, ifv, tank, art, antiAir, air, engineer, supply
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
		position.distance(to: unit.position) <= stats.rng * 2 + 1
	}

	var cost: UInt16 {
		switch stats.unitType {
		case .inf: 80
		case .ifv: 180
		case .tank: 240
		case .art: 160
		case .antiAir: 220
		case .air: 320
		default: 120
		}
	}
}
