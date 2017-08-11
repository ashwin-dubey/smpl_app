require 'sinatra/base'

class ApiHandler < Handler
  include CurrentRequest
  include PaginationHelpers

  def self.inherited(subclass)
    super
    subclass.instance_eval { cattr_accessor :skip_validation }
  end

  before do
    content_type 'application/json'
    validate_auth_token
  end

  after do
    CurrentRequest.clear!
  end

  error 500 do
    if env['sinatra.error']&.message
      { error: (env['sinatra.error']&.message || 'Unknown')}.to_json
    else
      response.body[0]
    end
  end

  def validate_auth_token
    return_errors("Unauthorized", 401) if !skip_validation? && current_user.blank?
  end

  def skip_validation?
    self.class.skip_validation.is_a?(Proc) ? self.class.skip_validation.() : self.class.skip_validation
  end

  def current_auth_token
    env["HTTP_AUTHORIZATION"]
  end

  def json(data)
    data.to_json
  end

end
