require "capybara"

module Capybara
  module Webkit
  end
end

require "capybara/webkit/driver"

Capybara.register_driver :webkit do |app|
  Capybara::Webkit::Driver.new(app)
end
Capybara.register_driver :permanent_webkit do |app|
  ENV['WEBKIT_PORT'] ||= '40000'
  ENV['WEBKIT_HOST'] ||= 'localhost'
  connection = Capybara::Webkit::PermanentConnection.new(host: ENV['WEBKIT_HOST'], port: ENV['WEBKIT_PORT'].to_i)
  browser = Capybara::Webkit::Browser.new(connection)
  Capybara::Webkit::Driver.new(app, :browser => browser)
end

Capybara.register_driver :webkit_debug do |app|
  driver = Capybara::Webkit::Driver.new(app)
  driver.enable_logging
  driver
end
