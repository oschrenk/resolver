module Resolver

  class Cli
    def main
      ARGV.each do |i|
        puts "org: #{i}"
        if i =~ /\A#{URI::regexp(['http', 'https'])}\z/
          puts Url.new.resolve(i)
        else
          puts "'#{i}' is not a valid url"
        end
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
        raise "server returned #{response.code} #{response.message} for #{url}"
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
      connection.use_ssl = url.scheme == 'https'

      head = Net::HTTP::Head.new url.request_uri

      connection.start do |http|
        http.request head
      end
    end

  end # of class
end # of module
