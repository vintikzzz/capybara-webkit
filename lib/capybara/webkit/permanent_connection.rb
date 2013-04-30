require 'socket'
require 'timeout'

module Capybara::Webkit
  class PermanentConnection

    def self.sockets
      @sockets ||= {}
    end
    attr_reader :port

    def initialize(options = {})
      @socket_class = options[:socket_class] || TCPSocket
      @port = options[:port] || 40000
      @host = options[:host] || '127.0.0.1'
    end

    def socket
      sockets = self.class.sockets
      s = nil
      if(!sockets.key?(@port))
        Timeout.timeout(5) do
          while s.nil?
            begin
              s = @socket_class.open(@host, @port)
              if defined?(Socket::TCP_NODELAY)
                s.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, true)
              end
              at_exit do
                s.close
              end
            rescue Errno::ECONNREFUSED
            end
          end
          sockets[@port] = s
        end
      else
        s = sockets[@port]
      end
      s
    end

    def puts(string)
      socket.puts string
    end

    def print(string)
      socket.print string
    end

    def gets
      socket.gets
    end

    def read(length)
      socket.read(length)
    end
  end
end
