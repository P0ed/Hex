struct Unit: Hashable, Codable {
	var id: UnitID
	var player: PlayerID
	var position: Hex
	var hp: HP
	var stats: Stats
}

struct HP: Hashable, Codable {
	var value: UInt8
	var max: UInt8

	init(_ hp: UInt8) {
		value = hp
		max = hp
	}
}

struct Stats: Hashable, Codable {
	var atk: UInt8
	var def: UInt8
	var mov: UInt8
}
