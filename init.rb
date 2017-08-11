require 'bundler'
require 'active_record'
require 'net/http'

ENV_NAME = ENV['RACK_ENV'] || 'development'
Bundler.require('default', ENV_NAME)

Dotenv.load(File.dirname(__FILE__) + "/.env.#{ENV_NAME}")

require_relative './api'
Api.connect
Api.require_all
