module Resolver

  class Cli
    def main
      opts, args = ARGV.partition {|i| i == "--fail-fast"}
      failfast = !opts.empty?
      args.each do |i|
        if i =~ /\A#{URI::regexp(['http', 'https'])}\z/
          eitherUrl = Url.new(failfast).resolve(i)
          if eitherUrl.left?
            STDERR.puts eitherUrl.value
          else
            puts eitherUrl.value
          end
        else
          msg = "'#{i}' is not a valid url"
          if failfast
            raise msg
          else
            STDERR.puts msg
          end
        end
      end
    end
  end

  class Url
    require 'uri'
    require 'net/https'

    attr_reader :failfast

    def initialize(failfast = false)
        @failfast = failfast
    end

    def resolve url
      resolve_url url
    end

    private

    def resolve_url abs_url
      response = request abs_url

      case response.code.to_i
      when 400...600
        msg = "#{response.code} #{response.message} for #{abs_url}"
        if @failfast
          raise IOError, msg
        else
          Either.left msg
        end
      when 301
        new_location =  URI.join(abs_url, response['location'])

        resolve_url(new_location)
      else
        Either.right URI.unescape(abs_url.to_s)
      end
    end

    def request abs_url
      url = abs_url.respond_to?(:host) ? abs_url : URI(abs_url.to_s)

      connection = Net::HTTP.new url.host, url.port
      connection.use_ssl = url.scheme == 'https'

      head = Net::HTTP::Head.new url.request_uri

      connection.start do |http|
        http.request head
      end
    end

  end

  class Either
    class << self

      def left(value)
        new(value, true).freeze
      end

      def right(value)
        new(value, false).freeze
      end
    end

    def left
      left? ? @value : nil
    end

    def right
      right? ? @value : nil
    end

    def left?
      @is_left
    end

    def right?
      ! left?
    end

    def value
      @value
    end

    private

    def initialize(value, is_left)
      @value = value
      @is_left = is_left
    end
  end

end # of module
