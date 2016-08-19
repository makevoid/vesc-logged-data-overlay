#! /usr/local/bin/ruby -w

# installation:

require 'rmagick'
require 'json'
# OJ

include Magick


IMG_W = 240
IMG_H = 120

log = File.open "./VESC_LOG.TXT"

gif = ImageList.new
gif.new_image IMG_W, IMG_H

last_data = {"t" => 0}

def decorate(text:)
  # text.font_family = 'helvetica'
  text.font_family = 'Liberation Mono'
  text.pointsize = 14
  text.gravity = WestGravity
  text.kerning = 0
end

def draw(data:, gif:)
  d = data

  # cont = " motor current: #{d["avgMotorCurrent"]}A \n input current: #{d["avgInputCurrent"]}A \n duty cycle: #{d["dutyCycleNow"]}% \n RPM: #{d["rpm"]} \n input voltage: #{d["inpVoltage"]}V \n consumed: #{d["ampHours"]}Ah \n charged: #{d["ampHoursCharged"]}A"
  #  \n speed: #{d["tachometer"]} \n max speed: #{d["tachometerAbs"]}"

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
  cont = rows.map{ |r| r.join(" ") }.join("\n").to_s

  frame = Image.new IMG_W, IMG_H
  text = Draw.new
  decorate text: text
  text.annotate(frame, 0, 0, 3, 3, cont) {
     self.fill = 'gray40'
  }
  gif << frame
end

t = 0
while true
  t += 100

  if t >= last_data["t"]
    line = log.gets
    break if line.nil?
    data = JSON.parse line.strip

    draw data: data, gif: gif
    last_data = data
  else
    draw data: last_data, gif: gif
  end

end

gif.write('vesc_log.gif')
