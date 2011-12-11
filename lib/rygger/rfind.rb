require 'find'
# require 'Time'


module Rygger


  #
  #    Find files whose name matches a given regular expression
  #
  class Rfind

    def utils
      @utils ||= Utils.new
    end


    def search
      @search ||= Search.new @ignore_case, @show_colors
    end


    def find( base, includes, excludes, logical_or )

      search.prepare_regexp( "path", includes, excludes, logical_or)
      # puts regexp

      Find.find(base) do |path|
        if FileTest.directory? path
          if excludes.include?( File.basename( path ) )
            Find.prune       # Don't look any further into this directory.
          else
            next
          end
        elsif path =~ /\.class/
          Find.prune       # Don't look any further into this directory.
        elsif path =~ /\.metadata/
          Find.prune       # Don't look any further into this directory.
        else
          search.check_for_match(path) do |path|
            output path
          end
        end
      end
    end


    def output( path )
      output = path

      if @basename_only
        output = File.basename( path )
      elsif @trim_to
        output = output.gsub( /.*rbps/, "" )
      end
        # mtime = File.mtime(path).strftime("%m/%d/%Y %H:%M:%S")
      if utils.is_windows?
        puts "#{output.colorize :cyan}"
      elsif
        puts output
      end
        # p path
        # p File.mtime(path)
    end


    def slop_main
      require 'slop'
      #utils.try_require 'lolize/auto', ! utils.is_windows?

      opts = Slop.new do
        my_name = File.basename($0)

        banner <<-EOS.gsub(/^ {4}/, "")

        #{my_name} is a utility for quickly finding files
        whose name matches given regular expressions

        Usage:

          #{my_name} OPTIONS

        where OPTIONS can be
        EOS

        on :V, :version, 'print out version number' do
          puts Rygger::VERSION
          exit
        end

        on :v, :verbose, 'verbose mode'
        # on :i, :include, '<include pattern>, can be specified multiple times', :optional => false, :as => Array
        on :x, :exclude, '<exclude pattern>, can be specified multiple times', :optional => false, :as => Array


        on :b, :basename, 'output only the basename, overrides trim_to'
        on :B, :basedir,  '<search base directory>, can be specified only once;
                         if given multiple times, the last one survives;
                         defaults to current directory', :optional => false

        on :r, :recurse, '<yes|no>, can be specified only once; if given multiple
                          times, the last one survives; defaults to yes'

        on :o, :or, 'logically OR the include patterns; default is to logically
                         AND them'
        on :i, :ignore_case, 'ignore case when matching'
        on :c, :colors,    'show colors, defaults to true'

        on :t, :trim_to, 'trim the beginning of the output path up to and including this string', :optional => false

        on :h, :help, 'Print this help message', :tail => true do
          puts help
          exit
        end
      end

      extra_matches = []
      opts.parse do |arg|
        extra_matches << arg
      end

      utils.log_options opts

      default_excludes    = [ "CVS",
                              ".svn",
                              "classes",
                              ".git",
                              # "images",
                              # "lib",
                              # "tlds",
                              ".metadata",
                              # "bin",
                              # "target",
                               ]


      include_pattern       = opts[:include] || []
      exclude_pattern       = opts[:exclude] || []
      # base                  = opts[:base]    || base
      recursive             = opts[:recurse].nil? ? true : opts[:recurse]
      logical_or            = opts[:or].nil? ? false : true
      @trim_to              = opts[:trim_to]
      @basename_only        = opts[:basename]
      base_dir              = opts[:basedir] || "."
      @ignore_case          = opts[:ignore_case]
      @show_colors          = opts[:colors].nil? ? true : false
      exclude_pattern      += default_excludes
      base_dir              = base_dir.gsub( /\\/, '/' )
      include_pattern      += extra_matches

      if opts.verbose?
        puts <<-EOS.gsub(/^ {4}/, "" )
        include_pattern       = #{include_pattern.inspect}
        exclude_pattern       = #{exclude_pattern.inspect}
        trim_to               = #{@trim_to}
        recursive             = #{recursive}
        logical_or            = #{logical_or}
        basename_only         = #{@basename_only}
        base_dir              = #{base_dir}
        ignore_case           = #{@ignore_case}
        show_colors           = #{@show_colors}

        EOS
      end

      search.check_pattern_specified include_pattern

      find( base_dir, include_pattern, exclude_pattern, logical_or )
    end
  end

  # def diff( first, sedond )
  #     seconds = first - second

  # end

  # dirs        = ["."]

  # for dir in dirs
  #   Find.find(dir) do |path|
  #     if FileTest.directory?(path)
  #       if excludes.include?(File.basename(path))
  #         Find.prune       # Don't look any further into this directory.
  #       else
  #         next
  #       end
  #     elsif path =~ /\.class/
  #       Find.prune       # Don't look any further into this directory.
  #     elsif path =~ /\.metadata/
  #       Find.prune       # Don't look any further into this directory.
  #     else
  #         if (File.mtime(path) - Time.parse( '07/04/2011' )) > 0
  #             output = path.gsub( "./rbps-core-r1/src/main/java/gov/va/vba/rbps/", "" )
  #             output = output.gsub( "./rbps-core-r1/src/test/java/gov/va/vba/rbps/", "" )
  #             output = output.gsub( "./rbps-common-r1/src/main/java/gov/va/vba/rbps/", "" )
  #             output = output.gsub( "./rbps-lettergen-r1/src/main/java/gov/va/vba/rbps/", "" )
  #             output = output.gsub( "./rbps-lettergen-r1/src/main/resources/gov/va/vba/rbps/", "" )
  #             output = output.gsub( "./rbps-lettergen-r1/src/test/java/gov/va/vba/rbps/", "" )
  #             output = output.gsub( "./rbps-web-r1/src/main/resources/", "" )

  #             # p output.colorize( :red )
  #             mtime = File.mtime(path).strftime("%m/%d/%Y %H:%M:%S")
  #             puts "#{mtime.colorize :blue}    #{output.colorize :green}"
  #             # p path
  #             # p File.mtime(path)
  #         end
  #     end
  #   end
  # end
end
