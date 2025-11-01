void main() {
	float px = v_tex_coord.x * u_sprite_width;
	float py = v_tex_coord.y * u_sprite_height;
	float col = floor(px / u_horizontal_spacing);

	float offsetY = mod(col, 2.0) * (u_hex_height * 0.5);
	float row = floor((py - offsetY) / u_vertical_spacing);

	vec2 mapUV = vec2(col / u_cols, row / u_rows);

	float terrainID = texture2D(u_terrain_data, mapUV).r * 255.0;

	float cellU = fract(v_tex_coord.x * u_cols);
	float cellV = fract(v_tex_coord.y * u_rows);

	int id = int(floor(terrainID + 1.5));
	int atlasX = id % 2;
	int atlasY = id / 2;

	vec2 atlasUV = vec2(
		(float(atlasX) + cellU) / 2.0,
		(float(atlasY) + cellV) / 2.0
	);

	gl_FragColor = texture2D(u_texture, atlasUV);
}
