# apt install libsdl2-dev libsdl2-ttf-dev

require 'sdl2'
require 'json'

require_relative 'lib/sdl-gui-loop'
include SdlGuiLoop
sdl_init


window   = sdl_window_test
renderer = window.create_renderer -1, 0

RPM 12345

DIM_W_LETTER = 11
DIM_H_LETTER = 26

font = sdl_default_font

def draw_text(text, renderer:, font:, x:, y:)
  letters_count = text.size
  width = letters_count * DIM_W_LETTER

  texture = renderer.create_texture_from(
    font.render_blended text, [0, 0, 0]
  )
  rect = SDL2::Rect.new x, y, width, DIM_H_LETTER
  renderer.copy(
    texture,
    nil,
    rect
  )
end


# p font.style
# p font.outline
# p font.hinting
# p font.kerning
# p font.height
# p font.ascent
# p font.descent
# p font.line_skip
# p font.num_faces
# p font.face_is_fixed_width?
# p font.face_family_name
# p font.face_style_name
# p font.size_text("Foo")

renderer.draw_color = [255, 255, 255]
apply_bg renderer: renderer


# --------------

log = File.open "./VESC_LOG.TXT"


text = "RPM: 1234"
text = "RPM: 12345678"

draw_text text, renderer: renderer, font: font, x: 10, y: 10


gui_loop renderer: renderer
# save_to_video
