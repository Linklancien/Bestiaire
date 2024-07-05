
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

    bestiaire   []Unit
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
        img := app.ctx.create_image(path) or {panic("No image")}
        app.ctx.draw_image(x, y, width, height, img)
    }
}

fn (unit Unit) description(mut app App){
    x       := app.win_width/5
    y       := app.win_height/3
    width   := 100
    height  := 100
    unit.render(x, y, width, height, mut app)
    app.text_rect_render(0, 0, true, "Pv:${unit.pv}
    Mvt:${unit.mvt}
    Reach:${unit.reach}
    Dmg:${unit.dmg}", 255)
}

interface Power {
    render_description(x f32, y f32, app App)
    description string

    active  bool
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

    app.bestiaire << Unit{name: 'test'}
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
                    if app.modif && app.index < app.bestiaire.len{
                        app.index += 1
                    }
                }
                .left{
                    if app.modif && app.index > 0{
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