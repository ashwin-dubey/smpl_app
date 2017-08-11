module CurrentRequest

  def self.included(klass)
    klass.send(:include, InstanceMethods)
    klass.send(:extend, InstanceMethods)
  end

  def self.clear!
    Thread.current[:usr] = {}
  end

  def self.current_thread_usr
    Thread.current[:usr] ||= {}
  end

  def self.set_defaults(env)
    clear!
    env_auth = env["HTTP_AUTHORIZATION"]
    if env_auth
      # Most of the clients use bearer with access token, so remove it if exists!
      env_auth.gsub!(/bearer/i, '')
      env_auth.strip!
      begin
        # Decode Public key as pull user data
        #hash = JWT.decode token, ENV['AUTH_PUBLIC_KEY'], false
        #return nil if data[:exp].blank? || data[:exp] < Time.now.utc.to_i
        current_thread_usr[:user] = {name: "XYZ"}
      rescue => e
        Api.error("With Login Credentials:", e)
        current_thread_usr[:user] = nil
      end
    end
    current_thread_usr[:user]
  end

  module InstanceMethods

    def current_thread_usr
      Thread.current[:usr] ||= {}
    end

    def current_user
      current_thread_usr[:user]
    end

    def current_resource
      current_thread_usr[:resource]
    end

  end
end
