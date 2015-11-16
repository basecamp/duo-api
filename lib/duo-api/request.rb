require "net/http"
require "time"
require "duo-api/header_signature"
require "duo-api/response"
require "duo-api/util"

module DuoApi
  class Request
    extend Util
    include Util

    def self.request(client, path, options = {})
      options = stringify_hash(options)
      hostname = options["hostname"] || client.hostname
      instance = new(client, options["method"], hostname, path, options["params"], options["headers"])
      instance.run
    end

    attr_reader :method
    attr_reader :signature
    attr_reader :query_string
    attr_reader :headers
    attr_reader :uri

    def initialize(client, method, hostname, path, params, headers)
      @method = method.to_s.upcase
      @method = "GET" if @method.length == 0
      hostname = hostname.to_s.downcase.sub(/\/\z/, "")
      path = "/#{path.to_s.sub(/\A\//, "")}"

      params = stringify_hash(params)
      @query_string = params.
        sort_by { |k| k }.
        map {|k,v| "#{URI.encode(k.to_s)}=#{URI.encode(v.to_s)}" }.
        join("&")

      @signature = HeaderSignature.new(client, method, path, query_string)

      @headers = stringify_hash(headers)
      @headers["Date"] = signature.date_header

      uri_suffix = "?#{query_string}" if use_query_string? && params.length > 0
      @uri = URI.parse("https://#{hostname}#{path}#{uri_suffix}")
    end

    def run
      Response.new(http.request(build))
    end

    def inspect
      inspects = "#<DuoApi::Request Method:#{method} URI:\"#{uri}\""
      inspects << " Body:\"#{query_string}\"" if !use_query_string?
      inspects << " Headers:#{headers.inspect}"
      inspects << " BasicAuth:#{signature.basic_auth.inspect}"
      inspects << ">"
      inspects
    end

    private

      def build
        request = request_class.new(uri.request_uri)
        request.basic_auth(*signature.basic_auth)
        headers.each { |header, value| request[header] = value }

        if !use_query_string?
          request.body = query_string
          request.content_type = 'application/x-www-form-urlencoded'
        end
        request
      end

      def http
        @http ||= Net::HTTP.new(uri.host, uri.port).tap { |http|
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        }
      end

      def use_query_string?
        method == "GET"
      end

      def request_class
        case method
        when "GET"
          Net::HTTP::Get
        when "POST"
          Net::HTTP::Post
        end
      end
  end
end
