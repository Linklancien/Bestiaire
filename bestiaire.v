import gg
import gx
import os

const bg_color      = gg.Color{}
const font_path     = os.resource_abs_path('0xProtoNerdFontMono-Regular.ttf')


struct App {
mut:
    ctx    &gg.Context = unsafe { nil }
    text_cfg	gx.TextCfg

    win_width   int = 601
    win_height  int = 601

    x_mouse     int
    y_mouse     int

    powers_list []Power
    powers_ids  map[string]int
    index_power  int
    
    unit_view   bool = true
    global_view bool = true

    units_list  []Unit
    img_pre     []gg.Image
    index_unit  int

    modif       bool
    clique      bool
}

fn main() {
    mut app := &App{}
    app.ctx = gg.new_context(
        width: app.win_width
        height:app. win_height
        fullscreen: false
        create_window: true
        window_title: '- Bestiaire -'
        user_data: app
        bg_color: bg_color
        frame_fn: on_frame
        init_fn:  on_init
        event_fn: on_event
        sample_count: 2
        font_path: font_path
    )

    //lancement du programme/de la fenêtre
    app.ctx.run()
}

fn on_init(mut app App){
    size := app.ctx.window_size()
	app.win_width 		= size.width
	app.win_height 		= size.height

    app.powers_load()
    app.units_load()
}

fn resave(){
    mut temp := Power{}
    // Capas
    temp = Power{}
    os.write_file("savs/powers/capa1", "capa1\nBla bla bla\ntrue")   or {panic("No")}
    os.write_file("savs/powers/capa2", "capa2\nCa ca ca\ntrue")  or {panic("No")}

    // Units
    os.write_file("savs/units/coureur", "coureur\n4\n6\n3\n2\n")  or {panic("No")}
    os.write_file("savs/units/escaladeur", "escaladeur\n3\n5\n3\n2\n")     or {panic("No")}
    os.write_file("savs/units/soldat", "soldat\n2\n2\n6\n2\n")  or {panic("No")}

    // Testes
    os.write_file("savs/units/test", "test\n4\n2\n4\n2\ncapa1")  or {panic("No")}
    os.write_file("savs/units/test2", "test2\n5\n2\n4\n2\ncapa1\bcapa2")     or {panic("No")}
    os.write_file("savs/units/test3", "test3\n1\n2\n10\n2\n")     or {panic("No")}
}

fn on_frame(mut app App) {
    //Draw
    app.ctx.begin()
    
    if app.global_view{
        if app.unit_view{
            mut x   := 0
            mut y   := 0
            width   := app.win_width/3
            height  := app.win_height/3

            mut id := 0
            for unit in app.units_list[id..]{
                unit.previsulation(x, y, width, height, mut app)

                if app.clique{
                    if app.y_mouse > y &&  app.y_mouse < y + height{
                        if app.x_mouse > x && app.x_mouse < x + width{
                            app.clique      = false
                            app.index_unit  = id
                            app.global_view = false
                        }
                    }
                }

                id += 1
                if x < app.win_width*2/3{
                    x += width
                }
                else if y < app.win_height*2/3{
                    x = 0
                    y += height
                }
                else{
                    break
                }
            }
        }
        else{
            x := 0
            mut y := 0
            mut id := 0
            mut capa_description := ""

            for power in app.powers_list{
                power.previsulation(x, y, mut app)

                if app.y_mouse > y &&  app.y_mouse < y + 26{
                    if app.x_mouse > 0 && app.x_mouse < 0 + power.name.len * 8 + 10{
                        if app.clique{
                            app.clique      = false
                            app.index_power = id
                            app.global_view = false
                        }
                        capa_description = power.description
                    }
                }

                y += 26
                id += 1
            }

            if capa_description != ""{
                app.text_rect_render(int(app.x_mouse + 16), int(app.y_mouse), true, capa_description, 255)
            }
        }
    }
    else{
        mut index := -1
        if app.unit_view{
            index = app.index_unit
            app.units_list[app.index_unit].description(mut app)
        }
        else{
            index = app.index_power
            app.powers_list[app.index_power].description(mut app)
        }
        app.text_rect_render(0, 0, true, "Ind:${index}", 255)
    }

    app.clique      = false
    app.ctx.end()
}

fn on_event(e &gg.Event, mut app App){
    size := app.ctx.window_size()
	app.win_width 		= size.width
	app.win_height 		= size.height

    app.x_mouse, app.y_mouse = int(e.mouse_x), int(e.mouse_y)

    if e.char_code != 0 && e.char_code < 128 {
		// app.change += u8(e.char_code).ascii_str()
    }
    match e.typ {
        .key_down {
            match e.key_code {
                .escape {
                    if !app.modif {
                        app.global_view = !app.global_view
                    }
                }
                .backspace {

				}
                .right{
                    if !app.modif && !app.global_view {
                        if app.unit_view && app.index_unit < app.units_list.len - 1{
                            app.index_unit += 1
                        }
                        else if app.index_power < app.powers_list.len - 1{
                            app.index_power += 1
                        }
                    }
                }
                .left{
                    if !app.modif && !app.global_view {
                        if app.unit_view && app.index_unit > 0{
                            app.index_unit -= 1
                        }
                        else if app.index_power > 0{
                            app.index_power -= 1
                        }
                    }
                }
                .space{
                    if !app.modif {
                        app.unit_view = !app.unit_view
                    }
                }
                else {}
            }
        }
        .mouse_down{
            match e.mouse_button{
                .left{
                    app.clique = true
                }
                else{}
            }
        }
        else {}
    }
}

fn (app App) text_rect_render(x int, y int, corner bool, text string, transparence u8){
	lenght  := text.len * 8 + 10
	mut new_x   := x
	new_y       := y
    if corner == false{
        new_x -= lenght/2
    }
	app.ctx.draw_rounded_rect_filled(new_x, new_y, lenght, app.text_cfg.size + 10, 5, attenuation(gx.gray, transparence))
	app.ctx.draw_text(new_x + 5, new_y + 5, text, app.text_cfg)
}

fn attenuation (color gx.Color, new_a u8) gx.Color{
	return gx.Color{color.r, color.g, color.b, new_a}
}