# apt install libsdl2-dev libsdl2-ttf-dev

require 'sdl2'
require 'json'

require_relative 'lib/sdl-gui-utils'
include SdlGuiUtils
sdl_init


window   = sdl_window_test
renderer = window.create_renderer -1, 0

# RPM 12345

DIM_W_LETTER = 12
DIM_H_LETTER = 26

# colors
#
C_RED   = [200, 0, 0]    # motor current
C_GREEN = [100, 150, 50] # batt current
C_BLUE  = [20, 20, 250]  # rpm

FONT = sdl_default_font

def draw_text(text, renderer:, font:, x:, y:, color: [20, 20, 20])
  letters_count = text.size
  width = letters_count * DIM_W_LETTER

  texture = renderer.create_texture_from(
    font.render_blended text, color
  )
  rect = SDL2::Rect.new x, y, width, DIM_H_LETTER
  renderer.copy(
    texture,
    nil,
    rect
  )
end

apply_bg renderer: renderer
renderer.draw_color = [255, 255, 255]


# --------------


LOG = File.open "./VESC_LOG.TXT"

CALC_R = 0.00003728226

#
# text = "RPM: 1234"
#

# draw data: data, gif: gif

def draw_info(data:, renderer:)
  x_start = 400

  d = data
  row_h = DIM_H_LETTER * 1.3

  rows =  []
  rows << ["motor current: ", "#{d["avgMotorCurrent"]} A"]
  rows << ["input current: ", "#{d["avgInputCurrent"]} A"]
  rows << ["duty cycle:    ", "#{(d["dutyCycleNow"]*100).round 2}%"]
  rows << ["RPM:           ", "#{d["rpm"]}"]
  rows << ["input voltage: ", "#{d["inpVoltage"]} V"]
  rows << ["consumed:      ", "#{d["wattHours"]} Wh"]
  rows << ["charged:       ", "#{d["wattHoursCharged"]} W"]
  # rows << ["consumed:      ", "#{d["ampHours"]}Ah"]
  # rows << ["charged:       ", "#{d["ampHoursCharged"]}A"]
  # table.rows << ["tacho:", "#{d["tachometer"]}"]
  # table.rows << ["tacho abs:", "#{d["tachometerAbs"]}"]

  rows.each_with_index do |row, row_idx|
    text = row.join(" ")

    height = row_h * row_idx
    case row_idx
    when 0 # motor current
      color = C_RED
    when 1 # input current
      color = C_GREEN
    when 3 # rpm
      color = C_BLUE
    else
      color = [20, 20, 20]
    end
    draw_text text, renderer: renderer, font: FONT, x: 10 + x_start, y: 10 + height, color: color
  end
end


LAST = { "data" => { "t" => 0 } }
TIMER = Time.new

IDX = {
  idx: 0
}
LIMIT = 0 # no limit
# LIMIT = 9

def gui_loop_tick(renderer:)
  r = renderer
  t = (Time.now - TIMER) * 1000.0

  last_data = LAST["data"]

  if t >= last_data["t"]
    line = LOG.gets
    sleep_and_exit(renderer: r) if line.nil? || (LIMIT != 0  && IDX[:idx] > LIMIT)
    begin
      data = JSON.parse line.strip
    rescue JSON::ParserError
      puts "Error in parsing JSON line, skipping..."
      puts "DEBUG - skipped_line: '#{line.strip}'"
      return
    end

    apply_bg renderer: r
    draw_info data: data, renderer: r
    # puts data
    LAST["data"] = data

    TS["t"].push data["t"]

    # graph
    #
    # input current: green
    # motor current: red
    # duty cycle: blue
    #
    #

    draw_graph_axis renderer: r

    # draw_graph(data: data, key: :rpm, renderer: r)
    draw_graph(data: data, key: :avgMotorCurrent, renderer: r)
    draw_graph(data: data, key: :avgInputCurrent, renderer: r, color: C_GREEN)
    draw_graph(data: data, key: :dutyCycleNow,    renderer: r, color: C_BLUE)

    x_bar_space = 720
    draw_bar(data: data["dutyCycleNow"],    key: :dutyCycleNow,    renderer: r, x_s: x_bar_space+40, color: C_BLUE)
    draw_bar(data: data["avgInputCurrent"], key: :avgInputCurrent, renderer: r, x_s: x_bar_space, color: C_GREEN)
    draw_bar(data: data["avgMotorCurrent"], key: :avgMotorCurrent, renderer: r, x_s: x_bar_space+20)
    @xs -= 10
    IDX[:idx] += 1
    sleep 0.2
  end
end

MAX = {
  rpm:          0,
  dutyCycleNow: 0,
  avgCurrent:   0,
  # avgMotorCurrent:  0,
  # avgInputCurrent:  0,
}
TS = { # time-series
  "t"               => [],
  "rpm"             => [],
  "avgMotorCurrent" => [],
  "avgInputCurrent" => [],
  "dutyCycleNow"    => [],
}
PREV = {
  "rpm"             => [0, 0],
  "avgMotorCurrent" => [0, 0],
  "avgInputCurrent" => [0, 0],
  "dutyCycleNow"    => [0, 0],
}

@xs = 0

def draw_graph_axis(renderer:)
  x = MAIN_RECT_W
  y = 270
  renderer.draw_color = [40, 40, 40]
  renderer.draw_line 0, y, x, y
  x = 353
  renderer.draw_color = [120, 120, 120]
  renderer.draw_line x, 0, x, 500
  renderer.draw_color = [255, 255, 255]
end

def draw_graph(data:, key:, renderer:, color: C_RED)
  y = 0

  key = key.to_s

  d = data[key]

  TS[key].push d

  max_h = 250

  key_max = key
  key_max = "avgCurrent" if %w(avgMotorCurrent avgInputCurrent).include? key_max
  key_max = key_max.to_sym
  MAX[key_max] = d if d > MAX[key_max] # redundant if drawing bar as well
  max = MAX[key_max]
  max = 1 if max == 0

  x_scroll = @xs
  x_sp = 150 # x_space

  PREV[key] = [20 + x_scroll, 270]

  TS[key].each_with_index do |p, idx|

    y_rel = p.to_f / max
    y = - y_rel * 250 + 250

    # x = 20 + idx*5

    # t_max = 10
    t_max = 3
    x = 20 + x_scroll + TS["t"][idx] / t_max * 250

    y = y + 20

    renderer.draw_color = color

    x_start = PREV[key][0]
    y_start = PREV[key][1]
    x += x_sp

    renderer.draw_line x_start, y_start, x, y
    PREV[key] = [x, y]
  end

  renderer.draw_color = [255, 255, 255]
end


def draw_bar(data:, key:, renderer:, x_s:, color: C_RED) # x_s (x_spacing)
  y = 0
  d = data

  key = key.to_s
  key_max = key
  key_max = "avgCurrent" if %w(avgMotorCurrent avgInputCurrent).include? key_max
  key_max = key_max.to_sym
  MAX[key_max] = d if d > MAX[key_max] # redundant if drawing bar as well
  max = MAX[key_max]
  max = 1 if max == 0

  y_rel = d.to_f / max
  y = - y_rel * 250 + 250

  # x = 20
  x = 10 + x_s

  y = y + 20

  y_len = 250 - y + 20

  if y > 270
    y_len = y - 270
    y = 250 + 20
  end
  y_len = [1, y_len].max


  # rect = SDL2::Rect.new 20, y, 4, 4
  rect = SDL2::Rect.new x, y, 10, y_len

  renderer.draw_color = color
  renderer.draw_rect rect
  renderer.fill_rect rect
  renderer.draw_color = [255, 255, 255]
end


def sleep_and_exit(renderer:)
  # p MAX
  sleep 1
  # sleep 10
  #
  # data = {
  #   "avgMotorCurrent" => 0,
  #   "avgInputCurrent" => 0,
  #   "dutyCycleNow" => 0,
  #   "rpm" => 0,
  #   "inpVoltage" => 0,
  #   "ampHours" => 0,
  #   "ampHoursCharged" => 0,
  # }
  # draw data: data, renderer: renderer
  exit
end

# --------------


gui_loop renderer: renderer
# save_to_video
