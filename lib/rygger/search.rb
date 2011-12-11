module Rygger

  class Search
    def prepare_regexp(input, include_pattern, exclude_pattern, logical_or, ignore_case)
      regexp = []

      ignore = ""
      ignore = "i" if ignore_case

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

      "(#{regexp.join(' and ')})"
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
  # end
end
