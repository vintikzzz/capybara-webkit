require 'rake'
desc 'Starts webkit-server'
task 'webkit:server' do
  port = ENV['WEBKIT_PORT']
  path = File.expand_path("../../../../bin/webkit_server", __FILE__)
  path += " #{port}" unless port.nil?
  exec("#{path}")
end
