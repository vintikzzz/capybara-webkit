require 'socket'
require 'timeout'

module Capybara::Webkit
  class PermanentConnection

    attr_reader :port

    def initialize(options = {})
      @socket_class = options[:socket_class] || TCPSocket
      @port    = options[:port] || 40000
      @host    = options[:host] || '127.0.0.1'
      @timeout = options[:timeout] || 30
    end
    def close
      unless @socket.nil?
        @socket.close()
        @socket = nil
      end
    end
    def socket
      Timeout.timeout(@timeout) do
        while @socket.nil?
          begin
            @socket = @socket_class.open(@host, @port)
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
      @socket
    end

    def restart
      @socket = nil
    end

    def with_retry
      tries ||= 3
      yield(socket)
    rescue Errno::EPIPE, EOFError => e
      @socket = nil
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
