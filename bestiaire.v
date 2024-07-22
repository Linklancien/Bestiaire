
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
    units_list  []Unit
    img_pre     []gg.Image
    index       int

    modif       bool
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

    // os.write_file("savs/powers/capa1", "capa1\nBla bla bla\ntrue")   or {panic("No")}
    // os.write_file("savs/powers/capa2", "capa2\nCa ca ca\ntrue")  or {panic("No")}

    // capa := Power{name: "Test", description: "Bla bla bla"}
    // capa2 := Power{name: "Test2", description: "Ca ca ca"}

    // os.write_file("savs/units/test", "test\n4\n2\n4\n2\ncapa1")  or {panic("No")}
    // os.write_file("savs/units/test2", "test2\n5\n2\n4\n2\ncapa1\bcapa2")     or {panic("No")}

    // app.units_list << Unit{name: 'test' , pv: 4, mvt: 2, reach: 4, dmg: 2, powers: [capa]}
    // app.units_list << Unit{name: 'test2', pv: 5, mvt: 2, reach: 4, dmg: 2, powers: [capa, capa2]}

    app.powers_load()
    app.units_load()

    dump(app.units_list)
    dump(app.powers_list)
}

fn on_frame(mut app App) {
    //Draw
    app.ctx.begin()
    if app.index < app.units_list.len{
        app.units_list[app.index].description(mut app)
    }
    app.text_rect_render(0, 0, true, "Ind:${app.index}", 255)
    // app.ctx.draw_circle_filled(x_autre, y_autre, 2, gg.Color{255, 0, 0, 255})
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
                    
                }
                .backspace {

				}
                .right{
                    if !app.modif && app.index < app.units_list.len - 1{
                        app.index += 1
                    }
                }
                .left{
                    if !app.modif && app.index > 0{
                        app.index -= 1
                    }
                }
                else {}
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