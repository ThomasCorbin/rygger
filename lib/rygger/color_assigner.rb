module Rygger
  class ColorAssigner

    def initialize
      @colors             = [ :cyan, :green, :red, :blue, :magenta ]
      @pattern_color_hash = Hash.new{|hash,key| hash[key] = next_color( @colors ) }
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
  end
end
