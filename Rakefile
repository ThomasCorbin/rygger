require "bundler/gem_tasks"

desc "convert the README.md file to html"
task :markdown do
  require 'redcarpet'
  markdown = Redcarpet::Markdown.new( Redcarpet::Render::HTML,
                                      :autolink => true,
                                      :space_after_headers => true )
  puts markdown.render( File.new( 'README.md' ).read )
  # puts markdown.to_html
end
