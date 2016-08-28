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

apply_bg renderer: renderer
renderer.draw_color = [255, 255, 255]


# --------------


LOG = File.open "./VESC_LOG.TXT"

CALC_R = 0.00003728226

#
# text = "RPM: 1234"
#

# draw data: data, gif: gif

def draw(data:, renderer:)
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
    draw_text text, renderer: renderer, font: FONT, x: 10, y: 10 + height
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
    draw data: data, renderer: r
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
    # draw_graph(data: data, key: :rpm, renderer: r)
    draw_graph(data: data, key: :avgMotorCurrent, renderer: r)
    draw_graph(data: data, key: :avgInputCurrent, renderer: r, color: [100, 150, 50])
    draw_graph(data: data, key: :dutyCycleNow, renderer: r, color: [20, 20, 250])
    draw_bar(data: data["rpm"], key: :rpm, renderer: r)
    @xs -= 10
    IDX[:idx] += 1
    # sleep 1
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

def draw_graph(data:, key:, renderer:, color: [200, 0, 0])
  y = 0

  key = key.to_s

  d = data[key]

  TS[key].push d

  max_h = 300

  key_max = key
  key_max = "avgCurrent" if %w(avgMotorCurrent avgInputCurrent).include? key_max
  key_max = key_max.to_sym
  MAX[key_max] = d if d > MAX[key_max] # redundant if drawing bar as well
  max = MAX[key_max]
  max = 1 if max == 0


  PREV[key] = [20, 320]

  TS[key].each_with_index do |p, idx|

    y_rel = p.to_f / max
    y = - y_rel * 300 + 300

    # x = 20 + idx*5
    x_scroll = @xs

    # t_max = 10
    t_max = 3
    x = 20 + x_scroll + TS["t"][idx] / t_max * 300

    y_len = 300 - y + 5 + 20
    y_len = [5, y_len].max

    y = y + 20
    rect = SDL2::Rect.new x, y, 5, y_len

    renderer.draw_color = color

    renderer.draw_line PREV[key][0], PREV[key][1], x, y
    PREV[key] = [x, y]
  end

  renderer.draw_color = [255, 255, 255]
end


def draw_bar(data:, key:, renderer:)
  y = 0
  d = data

  max_h = 300
  MAX[key] = d if d > MAX[key]
  max = MAX[key]
  max = 1 if max == 0
  y_rel = d.to_f / max
  y = - y_rel * 300 + 300

  # x = 20
  x = 400

  y = y + 20

  y_len = 300 - y + 10 + 20
  y_len = [10, y_len].max
  # rect = SDL2::Rect.new 20, y, 4, 4
  rect = SDL2::Rect.new x, y, 10, y_len

  renderer.draw_color = [200, 0, 0]

  # renderer.draw_color = [0, 255, 255]
  # renderer.draw_rect(SDL2::Rect.new(500, 20, 40, 60))
  # renderer.fill_rect(SDL2::Rect.new(20, 400, 60, 40))

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
