require 'spec_helper'
require 'fozzie/mill'

module Fozzie
  describe Mill do
    let(:str) { "userAgent;Mozilla/5.0%20%28Macintosh%3B%20Intel%20Mac%20OS%20X%2010_7_3%29%20AppleWebKit/535.19%20%28KHTML%2C%20like%20Gecko%29%20Chrome/18.0.1025.165%20Safari/535.19;vendorSub;;vendor;Google%20Inc.;onLine;true;appCodeName;Mozilla;cookieEnabled;true;product;Gecko;language;en-US;appVersion;5.0%20%28Macintosh%3B%20Intel%20Mac%20OS%20X%2010_7_3%29%20AppleWebKit/535.19%20%28KHTML%2C%20like%20Gecko%29%20Chrome/18.0.1025.165%20Safari/535.19;appName;Netscape;productSub;20030107;platform;MacIntel;domainLookupStart;1335538507546;domInteractive;1335538508237;domComplete;1335538508323;loadEventEnd;0;requestStart;1335538507546;connectEnd;1335538507546;domContentLoadedEventEnd;1335538508237;unloadEventStart;1335538508050;domainLookupEnd;1335538507546;fetchStart;1335538507545;unloadEventEnd;1335538508050;connectStart;1335538507546;secureConnectionStart;0;redirectEnd;0;domContentLoadedEventStart;1335538508237;loadEventStart;1335538508323;responseStart;1335538508049;redirectStart;0;domLoading;1335538508182;responseEnd;1335538508050;navigationStart;1335538507545;href;http://localhost:8080/" }
    subject   { Mill }

    describe "with environment arguments" do

      it "creates args hash from string" do
        inst = subject.register(str)
        inst.args['appCodeName'].should eq 'Mozilla'
        inst.args['cookieEnabled'].should eq 'true'
      end

      it "handles escaped values" do
        inst = subject.register(str)
        inst.args['userAgent'].should eq 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.165 Safari/535.19'
        inst.args['appVersion'].should eq '5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.165 Safari/535.19'
      end

      it "skips if not passed" do
        S.should_receive(:timing).never
        subject.register("")
      end

      describe "registers all mapped metrics" do
        let!(:expects) {
          S.should_receive(:timing).with(["page", "ttfb"], 504)
          S.should_receive(:timing).with(["page", "load"], 778)
        }

        it "dom complete" do
          subject.register(str)
        end

      end

    end

  end
end