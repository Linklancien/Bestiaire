struct Unit {
    index_unit  int
    mut:
        pv      int
        mvt     int
        reach   int
        dmg     int

        name    string

        powers  []Power
}

fn (unit Unit) render(x f32, y f32, width f32, height f32, mut app App){
    app.ctx.draw_image(x, y, width, height, app.img_pre[unit.index_unit])
}

fn (unit Unit) previsulation(x f32, y f32, w f32, h f32, mut app App){
    unit.render(x, y, w, h, mut app)
    app.text_rect_render(int(x), int(y), true,"$unit.name", 255)
    app.ctx.draw_rect_empty(x, y, w, h, bg_color)
}

fn (unit Unit) description(mut app App){
    x       := 0
    mut y   := 0
    app.text_rect_render(app.win_width/2, y, false,"$unit.name", 255)
    y += 26

    width   := 250
    height  := 250
    unit.render(x, y, width, height, mut app)
    y += height

    app.text_rect_render(x, y, true,"Pv: ${unit.pv} Mvt: ${unit.mvt} Reach: ${unit.reach} Dmg: ${unit.dmg}", 255)
    y += 26

    app.text_rect_render(x, y, true,"Capa:", 255)
    y += 26

    mut capa_description := ""
    for capa_render in unit.powers{
        app.text_rect_render(0, y, true, capa_render.name, 255)
        if app.y_mouse > y &&  app.y_mouse < y + 26{
            if app.x_mouse > 0 && app.x_mouse < 0 + capa_render.name.len * 8 + 10{
                capa_description = capa_render.description
            }
        }
        y += 26
    }
    if capa_description != ""{
        app.text_rect_render(int(app.x_mouse + 16), int(app.y_mouse), true, capa_description, 255)
    }
}
