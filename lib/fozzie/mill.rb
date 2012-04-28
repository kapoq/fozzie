require 'uri'

module Fozzie
  class Mill

    DELIMETER = ';'
    METRICS   = %w{ttfb load}

    attr_reader :str, :args

    def initialize(str = "")
      @str          = str
      escaped_split = str.split(DELIMETER).map!{|x| URI.unescape(x) }
      @args         = Hash[*escaped_split]
    end

    def self.register(str = "")
      new(str).register
    end

    def register
      return self unless self.has_href?
      METRICS.each do |k|
        next unless self.respond_to?(k.to_sym)
        S.timing((namespace << ['page', k]).flatten, self.send(k.to_sym))
      end

      self
    end

    def load
      @load ||= @args['domComplete'].to_i - @args['fetchStart'].to_i
    end

    def ttfb
      @ttfb ||= @args['responseStart'].to_i - @args['fetchStart'].to_i
    end

    def has_href?
      !@args['href'].nil?
    end

    def namespace
      @uri  ||= URI(@args['href'])
      @path ||= @uri.path.strip.split('/').reject(&:empty?)
      @path.dup
    end

  end
end