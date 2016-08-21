#!/usr/bin/ruby

require 'gtk2'
require 'gst'

if ARGV.size != 1
  puts "Usage: #{$0} <file>"
  exit 0
end

class VideoWidget < Gtk::DrawingArea

  def initialize(file)
    super()

    widget_present
  end

  def widget_present
    @playbin  = Gst::ElementFactory.make 'playbin'
    @video    = Gst::ElementFactory.make 'xvimagesink'
    # audiosink = Gst::ElementFactory.make 'autoaudiosink' # not reqiuired for purely video file - good to be enabled by default though
    @overlay  = Gst::ElementFactory.make 'textoverlay'

    # @playbin = Gst::ElementFactory.make('playbin2')
    @video.force_aspect_ratio = true

    bin = Gst::Bin.new
    bin.add @overlay
    pad         = @overlay.get_static_pad 'video_sink'
    ghost_pad   = Gst::GhostPad.new 'sink', pad
    bin.add_pad   ghost_pad
    bin.add       @video
    @overlay.link @video

    @playbin.text_sink  = @overlay
    @playbin.video_sink = bin
    @playbin.audio_sink = audiosink

    @playbin.uri = "file://#{File.absolute_path(file)}"
    @playbin.ready

    # write test text
    @overlay.text   = 'it works!!!'
    Thread.new do
      sleep 6
      @overlay.text = 'it works!!!!!!!!!'
    end
    #               = # indenting like that can be useful - improves code scanning/glancing ability
  end




  def play
    @playbin.play
  end

  def seek(time)
    pbin_seek = [
                  1.0, Gst::Format::TIME,
                  Gst::Seek::FLAG_FLUSH | Gst::Seek::FLAG_KEY_UNIT,
                  Gst::Seek::TYPE_CUR, time * Gst::SECOND,
                  Gst::Seek::TYPE_NONE, -1
                ]
    @playbin.seek *pbin_seek
  end
end

module UIElements # UIUtils

  def default_button
    button = Gtk::Button.new Gtk::Stock::MEDIA_PLAY
    button.label = label
  end

end


include UIElements


FILE_NAME = ARGV.first

window    = Gtk::Window.new
video     = VideoWidget.new  FILE_NAME
buttonbox = Gtk::HButtonBox.new


# button / start-label
label  = "Playing video with VESC data log"
button = default_button # (self.default_button)
buttonbox.add button

Thread.new do
  4.times do |i|
    button.label = "#{label} in #{4 - i}..."
  end
  sleep 1
end


# draw ui
hbox = Gtk::HBox.new
hbox.pack_start buttonbox, false

vbox = Gtk::VBox.new
vbox.pack_start video
vbox.pack_start hbox, false

window.add vbox
window.signal_connect 'destroy' do
  video.stop
  Gtk.main_quit
end



# draw window

WINDOW_W = 200
WINDOW_H = 90

# BOX_W
# BOX_H

window.set_default_size WINDOW_W, WINDOW_H
window.window_position = Gtk::Window::POS_CENTER
window.show_all



# ---

Gtk.main
