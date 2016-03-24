God.watch do |w|
  w.name          = 'webkit_server'
  w.interval      = 30.seconds
  w.dir           = ENV['APP_DIR']
  w.start         = "xvfb-run --server-args='-screen 0, #{ENV['XVFB_RES']}' bundle exec rake"
  w.log           = ENV['WEBKIT_LOG']
  w.stop          = "kill `cat #{ENV['PIDFILE']}`"
  w.pid_file      = ENV['PIDFILE']


  w.start_grace   = 60.seconds
  w.stop_grace    = 60.seconds
  w.restart_grace = 60.seconds

  w.behavior(:clean_pid_file)
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 10.seconds
      c.running  = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.interval = 10.seconds
      c.above    = 500.megabytes
      c.times    = 5
    end
    restart.condition(:cpu_usage) do |c|
      c.interval = 10.seconds
      c.above    = 50.percent
      c.times    = 5
    end
    restart.condition(:socket_responding) do |c|
      c.interval = 10.seconds
      c.family   = 'tcp'
      c.port     = ENV['WEBKIT_PORT']
    end
  end

  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end
