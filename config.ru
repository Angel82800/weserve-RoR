require 'rack/rewrite'
require ::File.expand_path('../config/environment', __FILE__)

use Rack::Rewrite do
  r301(/.*/, ->(_match, rack_env) { "https://#{rack_env['SERVER_NAME']}#{rack_env['REQUEST_URI']}" },
       scheme: 'http', if: proc { Rails.env.staging? || Rails.env.production? })
end

run Rails.application
