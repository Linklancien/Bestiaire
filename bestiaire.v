
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

    bestiaire   []Unit
    img_pre     []gg.Image
    index       int

    modif       bool
}

struct Unit {
    mut:
        pv      int
        mvt     int
        reach   int
        dmg     int

        name    string

        powers  []Power
}

fn (unit Unit) render(x f32, y f32, width f32, height f32, mut app App){
    path := "images/" + unit.name + ".png"
    if os.is_file(os.resource_abs_path(path)){  
        app.ctx.draw_image(x, y, width, height, app.img_pre[app.index])
    }
    else{
        print("No image")
    }
}

fn (unit Unit) description(mut app App){
    x       := 0
    mut y   := 26
    width   := 250
    height  := 250
    unit.render(x, y, width, height, mut app)
    y += height
    app.text_rect_render(0, y, true,"Pv: ${unit.pv} Mvt: ${unit.mvt} Reach: ${unit.reach} Dmg: ${unit.dmg}", 255)
    y += 26
    app.text_rect_render(0, y, true,"Capa:", 255)
    y += 26
    for capa_render in unit.powers{
        app.text_rect_render(0, y, true, capa_render.name, 255)
        if app.y_mouse > y &&  app.y_mouse < y + 26{
            if app.x_mouse > 0 && app.x_mouse < 0 + capa_render.name.len * 8 + 10{
                capa_render.render_description(app.x_mouse, app.y_mouse, app)
            }
        }
        y += 26
    }
}

struct Power {
    name        string
    description string

    active  bool
}

fn (power Power) render_description(x f32, y f32, app App){
    app.text_rect_render(int(x), int(y), true, power.description, 255)
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

    capa := Power{name: "Test", description: " Bla bla bla"}
    capa2 := Power{name: "Test2", description: " Bla bla bla"}

    app.bestiaire << Unit{name: 'test' , pv: 4, mvt: 2, reach: 4, dmg: 2, powers: [capa]}
    app.bestiaire << Unit{name: 'test2', pv: 5, mvt: 2, reach: 4, dmg: 2, powers: [capa, capa2]}

    for unit in app.bestiaire{
        path := "images/" + unit.name + ".png"
        if os.is_file(os.resource_abs_path(path)){  
            app.img_pre << app.ctx.create_image(path) or {panic("No image")}
        }
    }
}

fn on_frame(mut app App) {
    //Draw
    app.ctx.begin()
    if app.index < app.bestiaire.len{
        app.bestiaire[app.index].description(mut app)
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
                    if !app.modif && app.index < app.bestiaire.len - 1{
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