require 'socket'
require 'securerandom'
require 'uri'

class NetworkHandler
    attr_reader :logger, :network_log_data

    def initialize(logger:)
        @logger = logger
    end

    def call
        @network_log_data = {}
        random_request_value = SecureRandom.hex(rand(50..100))
        request_data = { sensitive_data: random_request_value}.to_json

        uri = URI.parse("http://www.google.com/")

        network_log_data[:protocol] = uri.scheme

        # getting request size with a newline character added because puts call on line:31 adds a newline char
        request_size = (request_data + "\n").bytesize

        network_log_data[:request_size] = "#{request_size} bytes"

        TCPSocket.open(uri.host, uri.port) do |socket|
            network_log_data[:destination_address] = socket.peeraddr[3]
            network_log_data[:destination_port] = socket.peeraddr[1]
            network_log_data[:source_address] = socket.addr[3]
            network_log_data[:source_port] = socket.addr[1]

            socket.puts(request_data)
        end

        logger.log_network_traffic(network_log_data)
    end

    private

    attr_writer :network_log_data
end
