require 'socket'
require 'timeout'

module Capybara::Webkit
  class PermanentConnection

    attr_reader :port

    def initialize(options = {})
      @socket_class = options[:socket_class] || TCPSocket
      @port = options[:port] || 40000
    end

    def puts(string)
      @socket.puts string
    end

    def print(string)
      @socket.print string
    end

    def gets
      @socket.gets
    end

    def read(length)
      @socket.read(length)
    end

    def connect
      Timeout.timeout(5) do
        while @socket.nil?
          attempt_connect
        end
      end
      if block_given?
        begin
          yield
        rescue StandardError => e
          close
          raise e
        end
        close
      end
    end
    private

    def close
      @socket.close
    end
    def attempt_connect
      @socket = @socket_class.open("127.0.0.1", @port)
      if defined?(Socket::TCP_NODELAY)
        @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, true)
      end
      at_exit do
        close
      end
    rescue Errno::ECONNREFUSED
    end
  end
end
