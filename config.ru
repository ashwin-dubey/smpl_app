require 'sinatra'
require 'sinatra/base'


begin
  Api.root
rescue
  require './init'
end

use Rack::Parser, parsers: {
  'application/json'  => Proc.new{|body| JSON.parse(body)}
}


ApiRoutes = Rack::Builder.new do

  # All descendants of ApiHandler will turn to routes
  ApiHandler.descendants.each do |file|
    matches = file.to_s.match(/(V\d)::([A-Za-z]+)Handler/)
    version, handler = matches[1].downcase, matches[2].underscore.pluralize
    route = "/api/#{version}/#{handler}"
    map route do
      use Rack::Config do |env|
        CurrentRequest.set_defaults(env)
      end
      run file
    end
  end

end

run ApiRoutes
