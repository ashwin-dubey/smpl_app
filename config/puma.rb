
require './init'

unless Api.env == "development"
  threads 1, 20
  workers 2
  preload_app!

  before_fork do
    ActiveRecord::Base.connection.disconnect! # rescue ActiveRecord::ConnectionNotEstablished
  end

  on_worker_boot do
    Api.connect_db
  end
end
