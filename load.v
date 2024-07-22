import os

fn (mut app App) powers_load(){
	entries := os.ls(os.join_path("savs", "powers")) or { [] }

	for entry in entries {
		path := os.join_path("savs", "powers", entry)
		if os.is_dir(path) {
			println('dir: $entry')
		} else {
			temp_powers := (os.read_file(path) or {panic("No")}).split('\n')

			name		:= temp_powers[0]
			description	:= temp_powers[1]
			mut active		:= false
			if temp_powers[2] == "true"{
				active = true
			}

			app.powers_ids[temp_powers[0]] = app.powers_list.len
			app.powers_list << Power{name: name, description: description, active:  active}
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
			temp_units := (os.read_file(path)  or {panic("No")}).split('\n')

			name	:= temp_units[0]
			pv		:= temp_units[1].int()
			mvt		:= temp_units[2].int()
			reach	:= temp_units[3].int()
			dmg		:= temp_units[4].int()

			// TODO Capas temp_units[5]
			capas_names := temp_units[5].split('\b')
			mut powers	:= []Power{}
			for capa in capas_names{
				id := app.powers_ids[capa]
				powers << app.powers_list[id]
			}

			app.units_list << Unit{name: name , pv: pv, mvt: mvt, reach: reach, dmg: dmg, powers: powers}
		}
	}

	// Load images
	for unit in app.units_list{
        path := "images/" + unit.name + ".png"
        app.img_pre << app.ctx.create_image(path) or { app.ctx.create_image("images/error.png") or {panic("No image")}}
    }
}