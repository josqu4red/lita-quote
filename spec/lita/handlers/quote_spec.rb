# coding: utf-8
require "spec_helper"

describe Lita::Handlers::Quote, lita_handler: true do

  before do
    Lita.configure do |config|
      config.handlers.quote.date_format = "%Y%m%d-%H%M"
      config.handlers.quote.metaphone_exclusions = [/<@[A-Z0-9]+>/]
    end
  end

  it { is_expected.to route_command("qadd dat funny guy").to(:add_quote) }
  it { is_expected.to route_command("addquote dat funny guy").to(:add_quote) }
  it { is_expected.not_to route_command("qadd").to(:add_quote) }
  it { is_expected.not_to route_command("addquote").to(:add_quote) }
  it { is_expected.not_to route_command("yo qadd dat funny guy").to(:add_quote) }
  it { is_expected.not_to route_command("yo addquote dat funny guy").to(:add_quote) }

  it { is_expected.to route_command("qget").to(:get_quote) }
  it { is_expected.to route_command("getquote").to(:get_quote) }
  it { is_expected.to route_command("qget 22").to(:get_quote) }
  it { is_expected.to route_command("getquote 22").to(:get_quote) }
  it { is_expected.to route_command("qget dat").to(:get_quote) }
  it { is_expected.to route_command("getquote dat").to(:get_quote) }
  it { is_expected.not_to route_command("yo qget").to(:get_quote) }
  it { is_expected.not_to route_command("yo getquote").to(:get_quote) }

  it { is_expected.to route_command("qdel 22").with_authorization_for(:quote_admins).to(:del_quote) }
  it { is_expected.to route_command("delquote 22").with_authorization_for(:quote_admins).to(:del_quote) }
  it { is_expected.not_to route_command("qdel").to(:del_quote) }
  it { is_expected.not_to route_command("delquote").to(:del_quote) }
  it { is_expected.not_to route_command("yo qdel dat").to(:del_quote) }
  it { is_expected.not_to route_command("yo delquote dat").to(:del_quote) }

  describe "#add_quote" do
    let (:message) { "<+renchap> t'as un user et pas d'accès ? <+josqu4red> nan mais allow" }
    it "adds quote to database" do
      send_command("qadd #{message}")
      expect(Lita.redis.hget("handlers:quote:quotes", 1)).to match(/^#1: #{Regexp.escape(message)} \d{8}-\d{4}$/)
    end
    it "adds quote in right position" do
      send_command("qadd #{message}")
      send_command("qadd next message")
      expect(Lita.redis.hget("handlers:quote:quotes", 2)).to match(/^#2: next message \d{8}-\d{4}$/)
    end
    it "reports it added a quote" do
      send_command("qadd #{message}")
      expect(replies.last).to match(/Added quote #\d+/)
    end
    it "adds quote to search index" do
      send_command("qadd #{message}")
      expect(Lita.redis.smembers("handlers:quote:words:RNXP")).to include("1")
    end
    it "respects metaphone_exclusion configuration" do
      send_command("qadd this last word is excluded <@U041CBXPN>")
      expect(Lita.redis.sismember("handlers:quote:words:<@U041CBXPN>", 1)).to equal(true)
    end
  end

  describe "#get_quote" do
    context "unpopulated quote list" do
      it "reports no quotes were found" do
        send_command("qget")
        expect(replies.last).to match("No quote found")
      end
      it "reports given quote not found" do
        send_command("qget 1")
        expect(replies.last).to match("No quote found")
        send_command("qget two")
        expect(replies.last).to match("No quote found")
      end
    end
    context "populated quote list" do
      before :each do
        Lita.redis.hset("handlers:quote:quotes", 1, "one")
        Lita.redis.hset("handlers:quote:quotes", 2, "one two")
        Lita.redis.hset("handlers:quote:quotes", 3, "one two three <@U048ATR5C>")
        Lita.redis.hset("handlers:quote:quotes", 4, "one two three four")
        Lita.redis.sadd("handlers:quote:words:ON", 1)
        Lita.redis.sadd("handlers:quote:words:ON", 2)
        Lita.redis.sadd("handlers:quote:words:ON", 3)
        Lita.redis.sadd("handlers:quote:words:ON", 4)
        Lita.redis.sadd("handlers:quote:words:TW", 2)
        Lita.redis.sadd("handlers:quote:words:TW", 3)
        Lita.redis.sadd("handlers:quote:words:TW", 4)
        Lita.redis.sadd("handlers:quote:words:0R", 3)
        Lita.redis.sadd("handlers:quote:words:0R", 4)
        Lita.redis.sadd("handlers:quote:words:FR", 4)
        Lita.redis.sadd("handlers:quote:words:<@U048ATR5C>", 3)
      end
      it "reports specified quote" do
        send_command("qget 2")
        expect(replies.last).to match("one two")
      end
      it "reports a quote containing quote string" do
        send_command("qget two")
        expect(replies.last).to include("two")
      end
      it "respects metaphone exclusion configuration" do
        send_command("qget <@U048ATR5C>")
        expect(replies.last).to include("<@U048ATR5C>")
      end
    end
  end

  describe "#del_quote" do
    let (:user) { Lita::User.create(1, name: "authed_user") }  
    before do
      robot.auth.add_user_to_group!(user, :quote_admins)
    end
    context "unpopulated quotes list" do
      it "reports given quote not found" do
        send_command("qdel 1", as: user)
        expect(replies.last).to match("Quote #1 does not exist")
      end
    end
    context "populated quote list" do
      before :each do
        Lita.redis.hset("handlers:quote:quotes", 1, "one")
        Lita.redis.hset("handlers:quote:quotes", 2, "one two")
        Lita.redis.hset("handlers:quote:quotes", 3, "one two three <@U048ATR5C>")
        Lita.redis.hset("handlers:quote:quotes", 4, "one two three four")
        Lita.redis.sadd("handlers:quote:words:ON", 1)
        Lita.redis.sadd("handlers:quote:words:ON", 2)
        Lita.redis.sadd("handlers:quote:words:ON", 3)
        Lita.redis.sadd("handlers:quote:words:ON", 4)
        Lita.redis.sadd("handlers:quote:words:TW", 2)
        Lita.redis.sadd("handlers:quote:words:TW", 3)
        Lita.redis.sadd("handlers:quote:words:TW", 4)
        Lita.redis.sadd("handlers:quote:words:0R", 3)
        Lita.redis.sadd("handlers:quote:words:0R", 4)
        Lita.redis.sadd("handlers:quote:words:FR", 4)
        Lita.redis.sadd("handlers:quote:words:<@U048ATR5C>", 3)
      end
      it "reports given quote not found" do
        send_command("qdel 5", as: user)
        expect(replies.last).to match("Quote #5 does not exist")
      end
      it "deletes quote from list" do
        send_command("qdel 3", as: user)
        expect(Lita.redis.hget("handlers:quote:quotes", 3)).to eq(nil)
      end
      it "removes quote from search word sets" do
        send_command("qdel 3", as: user)
        expect(Lita.redis.sismember("handlers:quote:words:ON", 3)).to eq(false)
        expect(Lita.redis.sismember("handlers:quote:words:TW", 3)).to eq(false)
        expect(Lita.redis.sismember("handlers:quote:words:0R", 3)).to eq(false)
        expect(Lita.redis.sismember("handlers:quote:words:<@U048ATR5C>", 3)).to eq(false)
      end
      it "reports quote was deleted" do
        send_command("qdel 3", as: user)
        expect(replies.last).to match("Deleted quote #3")
      end
    end
  end
end
