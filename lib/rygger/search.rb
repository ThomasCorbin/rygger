module Rygger

  class Search


    def initialize( ignore_case, show_colors = true)
      @ignore_case = ignore_case
      color_assigner show_colors
    end


    def color_assigner( show_colors = true )
      @color_assigner ||= ColorAssigner.new( show_colors )
    end


    def check_for_any_match( path, includes, excludes )

      includes.each do |include|
        if @ignore_case
          match = path =~ /#{include}/i
        else
          match = path =~ /#{include}/
        end

        if match
          output path, include
        end
      end
    end


    def check_for_excludes( path )
      @excludes.each do |exclude|
        return true if path =~ /#{exclude}/
      end

      false
    end


    def check_for_match( path, &block )
      return if check_for_excludes( path )

      # check_for_any_match( path, includes, excludes ) if logical_or
      # check_for_any_match( path, includes, excludes )

      if eval @regexp
        @includes.each do |pat|
          path = color_assigner.colorize_line path, pat
        end

        block.call path
        # output path
      end
    end


    def prepare_regexp(input, include_pattern, exclude_pattern, logical_or)
      @includes = include_pattern
      @excludes = exclude_pattern

      regexp = []

      ignore = ""
      ignore = "i" if @ignore_case

      if include_pattern && include_pattern.length > 0
        include_pattern.each { |pat| regexp << "#{input} =~ /#{pat}/#{ignore}" }
      end

      ipattern = logical_or ? "(#{regexp.join(' or ')})" : "(#{regexp.join(' and ')})"

      regexp = []

      if exclude_pattern && exclude_pattern.length > 0
        exclude_pattern.each { |pat| regexp << "#{input} !~ /#{pat}/#{ignore}" }
      end

      xpattern = "(#{regexp.join(' and ')})"

      regexp = []
      regexp << ipattern if ipattern != '()'
      regexp << xpattern if xpattern != '()'

      @regexp = "(#{regexp.join(' and ')})"
    end


    def check_pattern_specified( include_pattern )

      # if include_pattern.length == 0 and exclude_pattern.length == 0
      if include_pattern.length == 0
        puts <<-EOS.gsub(/^\s+/, "").strip
        --- Hmm ... looks like you don\'t want to search for any pattern.  Quitting!
        --- Try -h if you are looking for some help.

        EOS
        exit
      end
    end


  # from rgrep
  #   def prepare_regexp(include_pattern, exclude_pattern, logical_or, ignore_case)
  #     regexp = []

  #     ignore = ""
  #     ignore = "i" if ignore_case

  #     if include_pattern && include_pattern.length > 0
  #       include_pattern.each { |pat| regexp << "line =~ /#{pat}/#{ignore}" }
  #     end

  #     ipattern = logical_or ? "(#{regexp.join(' or ')})" : "(#{regexp.join(' and ')})"

  #     regexp = []

  #     if exclude_pattern && exclude_pattern.length > 0
  #       exclude_pattern.each { |pat| regexp << "line !~ /#{pat}/#{ignore}" }
  #     end

  #     xpattern = "(#{regexp.join(' and ')})"

  #     regexp = []
  #     regexp << ipattern if ipattern != '()'
  #     regexp << xpattern if xpattern != '()'

  #     "(#{regexp.join(' and ')})"
  #   end
  end
end
