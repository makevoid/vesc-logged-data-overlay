# apt install libsdl2-dev libsdl2-ttf-dev

require 'sdl2'
require 'json'

require_relative 'lib/sdl-gui-loop'
include SdlGuiLoop
sdl_init


window   = sdl_window_test
renderer = window.create_renderer -1, 0

# RPM 12345

DIM_W_LETTER = 12
DIM_H_LETTER = 26

FONT = sdl_default_font

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

renderer.draw_color = [255, 255, 255]


# --------------


LOG = File.open "./VESC_LOG.TXT"

#
# text = "RPM: 1234"
#

# draw data: data, gif: gif

def draw(data:, renderer:)
  d = data
  row_h = DIM_H_LETTER * 1.3

  rows =  []
  rows << ["motor current: ", "#{d["avgMotorCurrent"]}A"]
  rows << ["input current: ", "#{d["avgInputCurrent"]}A"]
  rows << ["duty cycle:    ", "#{d["dutyCycleNow"]}%"]
  rows << ["RPM:           ", "#{d["rpm"]}"]
  rows << ["input voltage: ", "#{d["inpVoltage"]}V"]
  rows << ["consumed:      ", "#{d["ampHours"]}Ah"]
  rows << ["charged:       ", "#{d["ampHoursCharged"]}A"]
  # table.rows << ["speed:", "#{d["tachometer"]}"]
  # table.rows << ["max speed:", "#{d["tachometerAbs"]}"]
  rows.each_with_index do |row, row_idx|
    text = row.join(" ")

    height = row_h * row_idx
    draw_text text, renderer: renderer, font: FONT, x: 10, y: 10 + height
  end
end


LAST = { "data" => { "t" => 0 } }
TIMER = Time.new

def gui_loop_tick(renderer:)
  t = (Time.now - TIMER) * 1000.0

  last_data = LAST["data"]

  if t >= last_data["t"]
    line = LOG.gets
    return if line.nil?
    data = JSON.parse line.strip

    apply_bg renderer: renderer
    draw data: data, renderer: renderer
    # puts data
    LAST["data"] = data
  end
end

# --------------


gui_loop renderer: renderer
# save_to_video
