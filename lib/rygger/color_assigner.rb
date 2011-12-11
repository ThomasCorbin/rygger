module Rygger


  #
  #    Colorize lines, track which things are assigned which colors.
  #
  class ColorAssigner

    attr_accessor :show_colors

    def initialize( show_colors = true )
      @show_colors        = show_colors
      @colors             = [ :cyan, :green, :red, :blue, :magenta ]
      @pattern_color_hash = Hash.new{|hash,key| hash[key] = next_color( @colors ) }
    end


    def utils
      @utils ||= Utils.new
    end


    def next_color colors
      color  = @colors.shift
      colors = @colors << color

      # puts color
      # puts colors
      # puts "=" * 40

      color
    end

    def color_for key
      @pattern_color_hash[key]
    end


    def colorize_line( line, pat )
      return line if utils.is_jruby?
      return line if ! @show_colors

      require 'colorize'

      begin
        if utils.is_windows? && ! utils.is_jruby?
          require 'win32/console/ansi'
        end
      rescue
        puts "couldn't load win32console"
      end

      pat_color = color_for pat
      line.gsub( /(#{pat})/i ) { |re| re.colorize pat_color }
    end
  end
end
