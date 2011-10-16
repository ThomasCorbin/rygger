module Rygger
  class Utils

    Opt = Struct.new( :key, :value )

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
      (Config::CONFIG['host_os'] =~ /windows|cygwin|bccwin|cygwin|djgpp|mingw|mswin|wince/i) ? true : false
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
