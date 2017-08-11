module Api
  class <<self
    def connect
      connect_db
      ActiveRecord::Base.logger = logger
      I18n.load_path += Dir[File.join(root, 'config', 'locales', '*.yml')]
      I18n.available_locales += %w(en de es)
    end

    def connect_db
      u = URI.parse(ENV['DB'])
      conf = {
        adapter: u.scheme, encoding: 'utf8', database: u.path.sub('/',''),
        host: u.host, port: u.port
      }.merge(Rack::Utils.parse_query(u.query))
      ActiveRecord::Base.establish_connection(conf)
    end

    def root
      File.dirname(__FILE__)
    end

    def logger
      @logger ||= begin
        obj = Logger.new($stdout)
        obj.formatter = proc { |severity, datetime, progname, msg|
          progname = rand(1111) # Replace rand with Unique ID here
          obj.instance_variable_get(:@default_formatter).call(severity, datetime, progname, msg)
        }
        obj
      end
    end

    def log(*data)
      data.each{|d| logger.info(d)}
      # logger.info(*data)
    end

    def error(*data)
      data.each{|d| logger.error(d)}
      # logger.error(error)
    end

    def root_path(path)
      File.join(Api.root, path)
    end

    def env
      ENV_NAME
    end

    # Donot change.
    def require_all
      require_files(Dir[root_path 'initializers/**/*.rb'])

      libs = %w(current_request).map{|name| root_path "lib/#{name}.rb"} + Dir[root_path 'lib/**/*.rb'].reject{|f| f.include?('/tasks/')}
      helpers = Dir[root_path 'app/helpers/*.rb']
      models = %w(application_record).map{|name| root_path "app/models/#{name}.rb"} + Dir[root_path('app/models/**/*.rb')]
      handlers = %w(handler api_handler basic_crud).map{|name| root_path "app/handlers/#{name}.rb"} + Dir[root_path('app/handlers/**/*.rb')]
      require_files(libs + models + helpers + handlers + Dir[root_path 'app/**/*.rb'])
    end

    def require_files(files)
      files.uniq.each {|f| require f}
    end

  end

  module V1
    # class Constants;end
  end
end
