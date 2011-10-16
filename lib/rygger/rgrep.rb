

module Rygger
  class Rgrep

    VC_DIRS = %w(blib CVS _darcs .git .pc RCS SCCS .svn pkg)

    def initialize
      @color_assigner = ColorAssigner.new
    end

    def color_for key
      @color_assigner.color_for key
    end


    def utils
      @utils ||= Utils.new
    end


    def build_glob_pattern( base, file_pattern, recurse )
      if recurse
        glob_pattern = "#{base}/**/#{file_pattern}"
      else
        glob_pattern = "#{base}/#{file_pattern}"
      end
    end


    def get_filenames( base, file_pattern, exclude_file_pattern, recurse )
      glob_pattern = build_glob_pattern( base, file_pattern, recurse )

      if @verbose
        puts "glob_pattern            #{glob_pattern}"
        puts "exclude_file_pattern    #{exclude_file_pattern.inspect}"
        # Dir.glob( glob_pattern )
      end

      fileList = FileList[ glob_pattern ]
      if @verbose
        puts "before excluding files, file list size: #{fileList.size}"
      end

      exclude_file_pattern.each do |exclude_pattern|
        fileList.exclude( exclude_pattern )
        if @verbose
          puts "after excluding pattern >#{exclude_pattern}< files, file list size: #{fileList.size}"
        end
      end
      if @verbose
        puts "after excluding files, file list size: #{fileList.size}"
      end

      fileList
    end


    def colorize_line( line, pat )
      return line if utils.is_jruby?

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


    def generalized_search( include_pattern,
                            exclude_pattern,
                            base                    = '.',
                            file_pattern            = '*',
                            exclude_file_pattern    = nil,
                            recurse                 = true,
                            logical_or              = false,
                            ignore_case             = false )

      file_names            = get_filenames( base, file_pattern, exclude_file_pattern, recurse )
      regexp                = prepare_regexp(include_pattern, exclude_pattern, logical_or, ignore_case)
      results               = []
      num_matching_lines    = 0
      num_matching_files    = 0


      file_names.each do |file_name|

        next if File.directory? file_name
        next if VC_DIRS.any?{ |vc| vc == File.basename(file_name) }

        if ! utils.readable? file_name
          puts $stderr, "File >#{file_name} is read-only, skipping..."
          next
        end

        next if utils.binary? file_name

        # next unless `file #{file_name}` =~ /text/

        line_number = 0
        File.foreach(file_name) do |line|
          line_number += 1

          if eval regexp
            # results << sprintf("%5d : %s", line_number, line)

            include_pattern.each do |pat|
              line = colorize_line line, pat
            end

            if @show_file_names
              results << sprintf("%5d : %s", line_number, line)
            else
              results << line
            end
          end
        end

        # puts "file_names_only         = #{@file_names_only}"

        if results.length > 0
          if @show_file_names  && ! @file_names_only
            puts
            puts ">>> #{file_name} : #{results.length} " + (results.length == 1 ? "match" : "matches")
            puts
          end
          if @show_file_names  && @file_names_only
            puts "#{file_name}"
          end

          unless @file_names_only
            results.each { |ln| print ln }
            puts
            print '    ', '-' * 75, "\n" if @show_file_names
          end

          num_matching_files += 1
          num_matching_lines += results.length
          results.clear
        end
      end

      if @show_file_names && ! @file_names_only
        puts
        puts "*** Found #{num_matching_lines} matching " + (num_matching_lines == 1 ?  "line" : "lines") + " in #{num_matching_files} " + (num_matching_files == 1 ? "file." : "files.")
        puts
      end

      num_matching_files
    end




    def prepare_regexp(include_pattern, exclude_pattern, logical_or, ignore_case)
      regexp = []

      ignore = ""
      ignore = "i" if ignore_case

      if include_pattern && include_pattern.length > 0
        include_pattern.each { |pat| regexp << "line =~ /#{pat}/#{ignore}" }
      end

      ipattern = logical_or ? "(#{regexp.join(' or ')})" : "(#{regexp.join(' and ')})"

      regexp = []

      if exclude_pattern && exclude_pattern.length > 0
        exclude_pattern.each { |pat| regexp << "line !~ /#{pat}/#{ignore}" }
      end

      xpattern = "(#{regexp.join(' and ')})"

      regexp = []
      regexp << ipattern if ipattern != '()'
      regexp << xpattern if xpattern != '()'

      "(#{regexp.join(' and ')})"
    end


    def slop_main
      require 'slop'

      opts = Slop.new do
        my_name = File.basename($0)

        banner <<-EOS.gsub(/^ {4}/, "")

        #{my_name} is a utility for quickly finding matching lines in multiple files.
        Where #{my_name} is better than a simple grep is in accommodating multiple
        include and exlude patterns in one go.  Similar to egrep, the include and
        exclude patterns can be regular expressions.

        Usage:

          #{my_name} OPTIONS [pattern1 pattern2]

        where OPTIONS can be
        EOS

        on :V, :version, 'print out version number' do
          puts 'Version 0.1.0'
          exit
        end

        on :v, :verbose, 'verbose mode'
        on :m, :match, '<match pattern>, can be specified multiple times', :optional => false, :as => Array
        on :x, :exclude, '<exclude pattern>, can be specified multiple times', :optional => false, :as => Array
        on :l, :filenamesonly, 'only show file names'

        on :B, :basedir, '<search base directory>, can be specified only once;
                         if given multiple times, the last one survives;
                         defaults to current directory', :optional => false

        on :f, :filepat, '<file pattern>, can be specified only once; if given
                         multiple times, the last one survives; defaults to *', :optional => false

        on :e, :exclpat, '<exclude file pattern>, can be specified only once; if given
                         multiple times, the last one survives; defaults to *', :optional => false, :as => Array

        on :r, :recurse, '<yes|no>, can be specified only once; if given multiple
                          times, the last one survives; defaults to yes'

        on :o, :or, 'logically OR the include patterns; default is to logically
                         AND them'

        on :i, :ignore_case, 'ignore case when matching'

        on :s, :no_file_names, "don't show file names"

        on :h, :help, 'Print this help message', :tail => true do
          puts help
          puts
          exit
        end
      end

      #   Add matches from the end of the line, that aren't specified via '-i'
      extra_matches = []
      opts.parse do |arg|
        extra_matches << arg
      end

      utils.log_options opts

      include_pattern       = opts[:include] || []
      exclude_pattern       = opts[:exclude] || []
      base                  = opts[:basedir] || '.'
      file_pattern          = opts[:filepat] || '*'
      exclude_file_pattern  = opts[:exclpat] || []
      recursive             = opts[:recurse].nil? ? true : opts[:recurse]
      logical_or            = opts[:or]
      ignore_case           = opts[:ignore_case]
      @verbose              = opts.verbose?
      @file_names_only      = opts[:filenamesonly]
      @show_file_names      = opts[:no_file_names] ? false : true

      base = base.gsub( /\\/, '/' )
      include_pattern += extra_matches

      if @verbose
        puts <<-EOS.gsub(/^ {4}/, "" )
        include_pattern       = #{include_pattern.inspect}
        exclude_pattern       = #{exclude_pattern.inspect}
        base                  = #{base}
        file_pattern          = #{file_pattern}
        exclude_file_pattern  = #{exclude_file_pattern.inspect}
        recursive             = #{recursive}
        logical_or            = #{logical_or}
        ignore_case           = #{ignore_case}
        file_names_only       = #{@file_names_only}
        show_file_names       = #{@show_file_names}

        EOS
      end

      check_pattern_specified include_pattern

      res = generalized_search( include_pattern,
                                exclude_pattern,
                                base,
                                file_pattern,
                                exclude_file_pattern,
                                recursive,
                                logical_or,
                                ignore_case )
    end


    # Returns the first instance variable whose value == x
    # Returns nil if no name maps to the given value
    def instance_variable_name_for(x)
      self.instance_variables.find do |var|
        x == self.instance_variable_get(var)
      end
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
  end
end
