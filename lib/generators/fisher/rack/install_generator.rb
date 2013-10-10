module Fisher
  module Rack
    class InstallGenerator < Rails::Generators::Base
      desc "Install Fisher statsd tracking"

      class_option :environment, :type => :string, :default => "all", :desc => "Environment to install this do"
      class_option :host, :type => :string, :default => "localhost", :desc => "The hostname of your Statsd server"
      class_option :port, :type => :string, :default => "8125", :desc => "The port your Statsd server is running on"

      def self.source_root
        @source_root ||= File.join(File.dirname(__FILE__), 'templates')
      end

      def update_application
        if options[:environment] != "all"
          opts = { :env => options[:environment] }
        else
          opts = {}
        end

        application "Fisher::Rack.statsd = Statsd.new('#{options[:host]}', #{options[:port]})", opts
        application "require 'statsd'", opts
      end
    end
  end
end
