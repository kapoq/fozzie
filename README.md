# Fozzie

Ruby gem for registering statistics to Statsd in various ways.

## Basic Usage

Send through statistics depending on the type you want to provide:

### Increment counter

    Stats.increment 'wat'

### Decrement counter

    Stats.decrement 'wat'

### Decrement counter - provide a value as integer

    Stats.count 'wat', 5

### Basic timing - provide a value in milliseconds

    Stats.timing 'wat', 500

### Timings - provide a block to time against (inline and do syntax supported)

    Stats.time 'wat' { sleep 5 }

    Stats.time_to_do 'wat' do
      sleep 5
    end

    Stats.time_for 'wat' { sleep 5 }

### Events - register different events


#### Commits

    Stats.commit

    Stats.committed

#### Builds

    Stats.built

    Stats.build

#### Deployments

    Stats.deployed

  With a custom app:

    Stats.deployed 'watapp'

    Stats.deploy

  With a custom app:

    Stats.deploy 'watapp'

#### Custom

    Stats.event 'pull'

  With a custom app:

    Stats.event 'pull', 'watapp'

### Boolean result - pass a value to be true or false, and increment on true

    Stats.increment_on 'wat', duck.valid?

## Sampling

Each of the above methods accepts a sample rate as the last argument (before any applicable blocks), e.g:

    Stats.increment 'wat', 10

    Stats.decrement 'wat', 10

    Stats.count 'wat', 5, 10

## Namespaces

Fozzie supports the following namespaces as default

    Stats.increment 'wat'
    S.increment 'wat'
    Statistics.increment 'wat'
    Warehouse.increment 'wat'

You can customise this via the YAML configuration (see instructions below)

## Configuration

Fozzie is configured via a YAML or by setting a block against the Fozzie namespace.

### YAML

Create a `fozzie.yml` within a `config` folder on the root of your app, which contains your settings for each env. Simple, verbose example below.

    development:
      appname: wat
      host: '127.0.0.1'
      port: 8125
      namespaces: %w{Foo Bar Wat}
    test:
      appname: wat
      host: 'localhost'
      port: 8125
      namespaces: %w{Foo Bar Wat}
    production:
      appname: wat
      host: 'stats.wat.com'
      port: 8125
      namespaces: %w{Foo Bar Wat}

### Configure block

    Fozzie.configure do |config|
      config.appname = "wat"
      config.host    = "127.0.0.1"
      config.port    = 8125
    end

## Middleware

To time and register the controller actions within your Rails application, Fozzie provides some middleware.

### Rack

    require 'rack'
    require 'fozzie'

    app = Rack::Builder.new {
      use Fozzie::Rack::Middleware
      lambda { |env| [200, {'Content-Type' => 'text/plain'}, 'OK'] }
    }

### Rails

Based on the Rack middleware above, but is more involved in it's construction of the bucket value.

Add the following to your `config/environment.rb`

    Rails::Initializer.run do |config|
      config.middleware.use 'Fozzie::Rails::Middleware'
    end

## Bucket name prefixes

Fozzie will construct bucket name prefixes according to your settings and environment. Example would be

    Stats.increment 'foo'

Would be represented as the following Graphite bucket:

    wat.your-computer-name.development.foo

When working on your development machine. This allows multiple application instances, in different environments, to be distinguished easily, and collated in Graphite quickly.

## Low level behaviour

The current implementation of Fozzie wraps the sending of the statistic in a timeout and rescue block, which prevent long host lookups (i.e. if your stats server disappears) and minimises impact on your code or application if something is erroring at a low level.

Fozzie will try to log these errors, but only if a logger has been applied (which by default it does not). Examples:

    Fozzie.logger = STDOUT

    require 'logger'
    Fozzie.logger = Logger.new 'log/fozzie.log'

This may change, depending on feedback and more production experience.

## Credits

Currently supported and maintained by [Marc Watts](marc.watts@lonelyplanet.co.uk) @Lonely Planet Online.

Big thanks to:

* [Mark Barger](mark.barger@lonelyplanet.co.uk) for support in trying to make this Gem useful.

* [Etsy](http://codeascraft.etsy.com/) who's [Statsd](https://github.com/etsy/statsd) product has enabled us to come such a long way in a very short period of time. We love Etsy.

* [https://github.com/reinh](https://github.com/reinh/statsd) for his [statsd](https://github.com/reinh/statsd) Gem.

## Comments and Feedback

Please [contact](marc.watts@lonelyplanet.co.uk) me on anything... improvements will be needed and are welcomed greatly.