require 'rubygems'
require 'sinatra'
require 'rack/cors'
require 'yaml'
require 'yajl'
require 'dir_walker'
require 'fileutils'

use Rack::Cors do |config|
  config.allow do |allow|
    # allow.origins 'localhost:3000', '127.0.0.1:3000'
    allow.origins '*'
    allow.resource '/file/list_all/', :headers => :any
    allow.resource '/file/at/*',
        :methods => [:get, :post, :put, :delete],
        :headers => :any,
        :max_age => 0
  end
end

config = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))
set :mount_points, config['mount_points']
set :ignores, config['ignores'] ? config['ignores'].collect{|i|Regexp.compile(i)} : nil

helpers do
  def mount_point
    path = params[:splat].first
    path[0..path.index('/')-1]
  end

  def translated_path
    path = params[:splat].first
    File.join(options.mount_points[mount_point], path[path.index('/')..-1])
  end
end

get '/file/list_all/' do
  headers(
      'Cache-Control' => 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0, private',
      'Content-Type'  => 'application/json; charset=UTF-8',
      'Pragma'        => 'no-cache',
      'X-Bespin-API'  => '4'
      )

  files = []
  options.mount_points.each_pair do |name, path|
    walker = DirWalker.new(name)
    walker.ignores = options.ignores
    files.concat(walker.walk(path))
  end

  Yajl::Encoder.encode(files)
end

get '/file/at/*' do
  file = Rack::File.new('')
  file.path = translated_path
  file
end

put '/file/at/*' do
  if request.content_length.nil? || request.content_length.to_i == 0
    FileUtils.mkdir_p translated_path
  else
    File.open(translated_path, 'w') {|f| FileUtils.copy_stream(request.body, f)}
  end
end

delete '/file/at/*' do
  FileUtils.rm translated_path
end
