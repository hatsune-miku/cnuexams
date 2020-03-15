# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
require 'rack/cors'

run Rails.application

# allow cors.
use Rack::Cors do
    allow do
        origins '*'
        resource '*', 
            headers: :any,
            methods: [:get, :post, :options]
    end
end
