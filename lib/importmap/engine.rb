require "importmap/map"

module Importmap
  class Engine < ::Rails::Engine
    config.importmap = Importmap::Map.new.draw("config/importmap.rb")
    config.autoload_once_paths = %W( #{root}/app/helpers )

    initializer "importmap.reloader" do |app|
      app.config.paths.add "config/importmap.rb"

      Importmap::Reloader.new.tap do |reloader|
        reloader.execute
        app.reloaders << reloader
        app.reloader.to_run { reloader.execute }
      end
    end

    initializer "importmap.assets" do
      if Rails.application.config.respond_to?(:assets)
        Rails.application.config.assets.precompile += %w( es-module-shims.js )
        Rails.application.config.assets.paths << Rails.root.join("app/javascript")
      end
    end

    initializer "importmap.helpers" do
      ActiveSupport.on_load(:action_controller_base) do
        helper Importmap::ImportmapTagsHelper
      end
    end

    initializer "importmap.caching" do |app|
      if Rails.application.config.importmap.cached.nil?
        Rails.application.config.importmap.cached = true
      end
    end
  end
end
