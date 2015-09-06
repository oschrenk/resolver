module Resolver

  class Cli
    def main
      if ARGV[0] =~ /\A#{URI::regexp(['http', 'https'])}\z/
        puts Url.new.resolve(ARGV[0])
      else
        puts "'#{ARGV[0]}' is not a valid url"
      end
    end
  end # of class

  class Url
    require 'uri'
    require 'net/https'

    def resolve url
      resolve_url (normalize_url url)
    end

    private

    def resolve_url url
      response = request url

      case response.code.to_i
      when 400...600
        raise HttpError.new(
          "server returned #{response.code} #{response.message}",
          url, response)
      when 301
        new_location = normalize_url response['location']
        resolve_url(new_location)
      else
        url
      end
    end

    def normalize_url url
      url.respond_to?(:host) ? url : URI(url.to_s)
    end

    def request url
      connection = Net::HTTP.new url.host, url.port
      head = Net::HTTP::Head.new url.request_uri

      connection.start do |http|
        http.request head
      end
    end

  end # of class
end # of module
