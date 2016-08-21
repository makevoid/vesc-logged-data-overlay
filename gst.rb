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

    @playbin = Gst::ElementFactory.make('playbin')
    # @playbin = Gst::ElementFactory.make('playbin2')

    @video = Gst::ElementFactory.make('xvimagesink')
    @video.force_aspect_ratio = true

    @overlay = Gst::ElementFactory.make('textoverlay')
    @overlay.text = 'Foo bar'

    bin = Gst::Bin.new
    bin.add(@overlay)
    # raise (@overlay.methods - Object.methods).sort.select{|m| m.to_s =~ /pad/}.inspect
    ghost_pad = Gst::GhostPad.new('sink', @overlay.get_static_pad('video_sink'))
    bin.add_pad(ghost_pad)
    bin.add(@video)
    @overlay.link(@video)

    #
    # @playbin.audio_sink = @audio

    # @playbin.ready


    #

    @playbin.text_sink = @overlay
    # @playbin.video_sink = @video
    @playbin.video_sink = bin
    @playbin.audio_sink = Gst::ElementFactory.make('autoaudiosink')
    @playbin.signal_connect('notify') do
      # @playbin.video_sink.xwindow_id = self.window.xid if self.window
      # @playbin.video_sink.expose
    end
    @playbin.uri = "file://#{File.absolute_path(file)}"
    @playbin.ready
    @overlay.text = 'it works!!!'
    Thread.new do
      sleep 6
      @overlay.text = 'it works!!!!!!!!!'
    end
  end

  def play
    @playbin.play
  end

  def pause
    @playbin.pause
  end

  def stop
    @playbin.stop
  end

  def seek(time)
    @playbin.seek(1.0, Gst::Format::TIME,
                  Gst::Seek::FLAG_FLUSH | Gst::Seek::FLAG_KEY_UNIT,
                  Gst::Seek::TYPE_CUR, time * Gst::SECOND,
                  Gst::Seek::TYPE_NONE, -1);
  end
end



window = Gtk::Window.new
video = VideoWidget.new(ARGV.first)

buttonbox = Gtk::HButtonBox.new

button = Gtk::Button.new(Gtk::Stock::MEDIA_PLAY)
button.signal_connect('clicked') { video.play }
buttonbox.add(button)

button = Gtk::Button.new(Gtk::Stock::MEDIA_PAUSE)
button.signal_connect('clicked') { video.pause }
buttonbox.add(button)
button = Gtk::Button.new(Gtk::Stock::MEDIA_STOP)
button.signal_connect('clicked') { video.stop }
buttonbox.add(button)

button = Gtk::Button.new(Gtk::Stock::MEDIA_REWIND)
button.signal_connect('clicked') { video.seek(-10) }
buttonbox.add(button)

button = Gtk::Button.new(Gtk::Stock::MEDIA_FORWARD)
button.signal_connect('clicked') { video.seek(10) }
buttonbox.add(button)

hbox = Gtk::HBox.new
hbox.pack_start(buttonbox, false)

vbox = Gtk::VBox.new
vbox.pack_start(video)
vbox.pack_start(hbox, false)

window.add(vbox)
window.signal_connect('destroy') do
  video.stop
  Gtk.main_quit
end
window.set_default_size(640, 480)
window.window_position = Gtk::Window::POS_CENTER
window.show_all

Gtk.main
