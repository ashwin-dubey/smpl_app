class Handler < Sinatra::Base
  before do
    @start_time = Time.now
  end

  after do
    log_time
  end

  configure do
    disable :lock
  end

  set(:request_type) do |*methods|
    methods = methods.flatten.map{|m| m.to_s.upcase}
    condition { methods.include?(request.request_method) }
  end

  configure :development do
    register Sinatra::Reloader
    also_reload(File.join(Api.root, '{app,lib}/**/**.rb'))
    set :show_exceptions, :after_handler
  end

  def log_time
    time_taken = "#{'%.3f' % ((Time.now - @start_time)*1000)} ms"
    Api.log("➜ [#{Time.now}] #{request.request_method} #{response.status} \"#{request.path}\" in #{time_taken}")
  end

  def return_errors(error, status=500)
    Api.error("Returning Error", {error: error})
    halt status, {'Content-Type'=>'application/json'}, {
      error: error
    }.to_json
  end

  at_exit {
    Api.log("Before Exit Process")
    begin
      ActiveRecord::Base.connection_pool.disconnect!
      Api.log("Successfully removed connections")
    rescue => e
      Api.error(e)
    end
  }
end
