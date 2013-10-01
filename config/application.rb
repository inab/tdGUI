require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'rack/jsonp' # for jsonp middleware!!!!

# !!!!! to avoid to use activeRecord (and, then, any db)
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"
require "sprockets/railtie"
require "ostruct"

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
	#Bundle.with_clean_env do
	#	system("ruby pgm.rb")
	#end

  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module TdGUI
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
		config.autoload_paths += %W(#{config.root}/lib)  #{Rails.root}/app/models) # otherwise won't load lib classes

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
#    config.assets.enabled = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

		# IntAct db configuration
		opts = {:intact_server => 'localhost', :intact_user => 'intact',
						:intact_pass => '1ntakt', :intact_port => '5432'}
		# opts = {:intact_server => 'padme.cnio.es', :intact_user => 'gcomesana',
		# 				:intact_pass => 'appform', :intact_port => '5432'}
		opts_mysql = {:mysql_host => 'localhost', :mysql_user => 'root', :mysql_passwd => ''}

    config.intactdb = OpenStruct.new(opts)
    config.mysql_cache = OpenStruct.new(opts_mysql)

		require File.expand_path(File.join(File.dirname(__FILE__), '../lib/app_settings'))
		AppSettings.config = YAML.load_file("config/app_settings.yml")[Rails.env]

		config.paths.add "app/api", :glob => "**/*.rb"
		config.autoload_paths += Dir["#{Rails.root}/app/api/*"]

        # This is a middleware in order to the api works with swagger-ui
		require 'middleware/access_control_allow_all_origin'
		config.middleware.insert_after Rack::ETag, Middleware::AccessControlAllowAllOrigin

		config.middleware.use Rack::JSONP
  end

end
