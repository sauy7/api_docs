require 'yaml'
require 'sinatra/base'
require "bundler/setup"

module ApiDocs
  class Web < Sinatra::Base
    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
    end

    dir = File.expand_path(File.dirname(__FILE__))

    set :public_folder, "#{dir}/assets"
    set :views,  "#{dir}/views"

    helpers do
      def controllers
        @controllers ||= begin
          Dir.glob(ApiDocs.config.docs_path.join('*.yml')).sort.inject({}) do |memo, file_path|
            memo[File.basename(file_path, '.yml')] = YAML.load_file(file_path)
            memo
          end
        end
      end

      def asset_path
        self.class.public_folder
      end

      def stylesheets
        @stylesheets ||= begin
          ["bootstrap.min.css", "main.css"].map{|file| File.read("#{asset_path}/#{file}")}.join("\n")
        end
      end

      def javascripts
        @javascripts ||= begin
          ["bootstrap.min.js"].map{|file| File.read("#{asset_path}/#{file}")}.join("\n")
        end
      end

      def markdown_not_exist? controller_name
        !File.exist?(ApiDocs.config.docs_path.join("#{controller_name}.md"))
      end
    end

    get '/' do
      haml :index
    end

  end

end
