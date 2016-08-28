module SdlGuiLoop
  MAIN_RECT_W = 640
  MAIN_RECT_H = 400

  def gui_loop(renderer:)
    loop do
      while ev = SDL2::Event.poll
        case ev
        when SDL2::Event::KeyDown
          if ev.scancode == SDL2::Key::Scan::ESCAPE
            exit
          end
        when SDL2::Event::Quit
          exit
        end
      end

      gui_loop_tick renderer: renderer

      renderer.present
      #GC.start
      sleep 0.1
    end
  end

  # SDL utils

  def sdl_init
    SDL2.init SDL2::INIT_EVERYTHING
    SDL2::TTF.init
  end

  def sdl_window_test(title: "Test window")
    SDL2::Window.create(
      title,
      SDL2::Window::POS_CENTERED, SDL2::Window::POS_CENTERED,
      MAIN_RECT_W, MAIN_RECT_H, 0
    )
  end

  def sdl_default_font(monospace: true, width: 20)
    SDL2::TTF.open "font.ttf", width
  end

  def apply_bg(renderer:)
    renderer.fill_rect( SDL2::Rect.new 0, 0, MAIN_RECT_W, MAIN_RECT_H )

   
  end
end
