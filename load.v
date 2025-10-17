import os
import json

fn (mut app App) powers_load(){
	entries := os.ls(os.join_path("savs", "powers")) or { [] }

	for entry in entries {
		path := os.join_path("savs", "powers", entry)
		if os.is_dir(path) {
			println('dir: $entry')
		} else {
			temp_powers := (os.read_file(path) or {panic("No temp_powers to load")})

			app.powers_list << json.decode(Power_Description, temp_powers) or {panic('Failed to decode json, error: ${err}')}
		}
	} 
}

fn (mut app App) units_load(){
	entries := os.ls(os.join_path("savs", "units")) or { [] }

	// load units
	for entry in entries {
		path := os.join_path("savs", "units", entry)
		if os.is_dir(path) {
			println('dir: $entry')
		} else {
			temp_units := (os.read_file(path)  or {panic("No temp_units to load")})

			app.units_list << json.decode(Unit, temp_units) or {panic('Failed to decode json, error: ${err}')}
			app.units_list[app.units_list.len - 1].index_unit = app.units_list.len - 1
		}
	}

	// Load images
	for unit in app.units_list{
        path := "images/" + unit.name + ".png"
        app.img_pre << app.ctx.create_image(path) or { app.ctx.create_image("images/error.png") or {panic("No image")}}
    }
}