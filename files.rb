require 'rubygems'
require 'sinatra'
require '../rack-cors/lib/rack/cors'
require 'yaml'
require 'yajl'
require 'dir_walker'

use Rack::Cors do |origins|
  origins.allow ['localhost:3000', '127.0.0.1:3000'], '/file/list_all/', :allow_headers => 'x-domain-token'
  origins.allow ['localhost:3000', '127.0.0.1:3000'], '/file/at', :methods => [:get, :post, :put, :delete], :allow_headers => 'x-domain-token'
end

set :mount_points, YAML.load_file(File.join(File.dirname(__FILE__), 'mount_points.yml'))

get '/file/list_all/' do
  headers(
      'Cache-Control' => 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0, private',
      'Content-Type'  => 'application/json; charset=UTF-8',
      'Pragma'        => 'no-cache',
      'X-Bespin-API'  => '4'
      )

  files = []
  options.mount_points.each_pair do |name, path|
    files.concat(DirWalker.new(name).walk(path))
  end

  Yajl::Encoder.encode(files)
end

get '/file/at/*' do
  path = params[:splat].first
  mount_point = path[0..path.index('/')-1]

  file = Rack::File.new('')
  file.path = File.join(options.mount_points[mount_point], path[path.index('/')..-1])
  file
end

