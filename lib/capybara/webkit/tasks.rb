require 'rake'
require 'open3'
desc 'Starts webkit-server'
task 'webkit:server' do
  port = ENV['WEBKIT_PORT']
  path = File.expand_path("../../../../bin/webkit_server", __FILE__)
  path += " #{port}" unless port.nil?
  pipe_stdin, pipe_stdout, pipe_stderr, wait_thr = Open3.popen3(path)
  pid = wait_thr[:pid]
  File.open(ENV['PIDFILE'], 'w') { |f| f << pid } if ENV['PIDFILE']
  Thread.new do
    Thread.current.abort_on_exception = true
    IO.copy_stream(pipe_stdout, $stdout)
  end
  Thread.new do
    Thread.current.abort_on_exception = true
    IO.copy_stream(pipe_stderr, $stderr)
  end
  exit = wait_thr.value
end
