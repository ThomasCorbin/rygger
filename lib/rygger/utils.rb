module Rygger
  class Utils

    Opt = Struct.new( :key, :value )

    #
    #   Utilitly to load stuff into irb and
    #   have nice messages on failure (w/o screwing up irb)
    #   and to do initialization (if desired) on success
    #
    def try_require(what, condition = true, &block)
      loaded, require_result = false, nil

      if ! condition
        puts "Not installing #{what}"
        return require_result
      end

      begin
        require_result = require what
        loaded = true

      rescue Exception => ex
        puts "** Unable to require '#{what}'"
        puts "--> #{ex.class}: #{ex.message}"
      end

      yield if loaded and block_given?

      require_result
    end


    def log_options( opts )
      return unless opts.verbose?

      require 'hirb'
      extend Hirb::Console
      require 'hirb/import_object'

      contents = opts.to_hash.inject( [] ){ |l,(k,v)| l << Opt.new( k, v.inspect) }
      contents << Opt.new( 'host_os',         Config::CONFIG[ 'host_os']  )
      contents << Opt.new( 'RUBY_PLATFORM',   RUBY_PLATFORM               )
      contents << Opt.new( 'is_jruby?',       is_jruby?                   )
      contents << Opt.new( 'is_windows?',     is_windows?                 )

      table contents, :fields => [:key, :value]
      puts
    end


    def is_jruby?
      # RUBY_PLATFORM == 'java'
      ((defined? RUBY_ENGINE) && RUBY_ENGINE == 'jruby') ? true : false
    end


    def is_windows?
      # (Config::CONFIG['host_os'] =~ /mswin|mingw/) ? true : false
      result = (RbConfig::CONFIG['host_os'] =~ /windows|cygwin|bccwin|cygwin|djgpp|mingw|mswin|wince/i) ? true : false

      # puts "is_windows? #{result}"

      result
    end


    def binary?( name )
      if ! is_windows?
        require 'ptools'
        return File.binary? name
      end

      open name do |f|
        while (b = f.read(256)) do
          return true if b[ "\0" ]
        end
      end

      false
    end


    def long_binary?( name )
      if ! is_windows?
        return File.binary? name
      end

      open name do |f|
        f.each_byte { |x|
          x.nonzero? or return true
        }
      end

      false
    end


    def readable?( name )
      if ! is_windows?
        return File.readable? name
      end

      begin
        open name do |f|
          f.read(256)
          return true
        end
      rescue
        # puts "File #{name} is not readable."
        return false
      end

      false
    end
  end
end
