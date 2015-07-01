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
      @port    = options[:port] || 40000
      @host    = options[:host] || '127.0.0.1'
      @timeout = options[:timeout] || 30
    end
    def key
      @host + @port.to_s
    end
    def close
      sockets = self.class.sockets
      if sockets.key?(key)
        socket.close()
        sockets.delete(key)
      end
    end
    def socket
      sockets = self.class.sockets
      s = nil
      if !sockets.key?(key)
        Timeout.timeout(@timeout) do
          while s.nil?
            begin
              s = @socket_class.open(@host, @port)
              if defined?(Socket::TCP_NODELAY)
                s.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, true)
              end
              at_exit do
                close
              end
            rescue Errno::ECONNREFUSED
            end
          end
          sockets[key] = s
        end
      else
        s = sockets[key]
      end
      s
    end

    def with_retry
      tries ||= 3
      yield(socket)
    rescue Errno::EPIPE => e
      sockets = self.class.sockets
      sockets.delete(key)
      retry unless (tries -= 1).zero?
    end

    def puts(string)
      with_retry do |s|
        s.puts string
      end
    end

    def print(string)
      with_retry do |s|
        s.print string
      end
    end

    def gets
      response = ""
      until response.match(/\n/) do
        response += read(1)
      end
      response
    end

    def read(length)
      with_retry do |s|
        response = ""
        begin
          while response.length < length do
            response += s.read_nonblock(length - response.length)
          end
        rescue IO::WaitReadable
          Thread.new { IO.select([s]) }.join
          retry
        end
        response
      end
    end
  end
end
