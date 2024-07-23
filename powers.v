struct Power {
    name        string
    description string
	
    active  bool
}

fn (power Power) description(mut app App){
    x       := 0
    mut y   := 0
    app.text_rect_render(app.win_width/2, y, true,"$power.name", 255)
    y += 26
    app.text_rect_render(x, y, true,"Active: $power.active", 255)
    y += 26
    app.text_rect_render(x, y, true,"$power.description", 255)
}
