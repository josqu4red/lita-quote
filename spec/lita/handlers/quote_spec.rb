# coding: utf-8
require "spec_helper"

describe Lita::Handlers::Quote, lita_handler: true do

  before do
    Lita.configure do |config|
      config.handlers.quote.date_format = "%Y%m%d-%H%M"
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
  it { is_expected.not_to route_command("yo qget").to(:get_quote) }
  it { is_expected.not_to route_command("yo getquote").to(:get_quote) }
  it { is_expected.not_to route_command("qget dat").to(:get_quote) }
  it { is_expected.not_to route_command("getquote dat").to(:get_quote) }

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
      expect(Lita.redis.hget("handlers:quote:list", 1)).to match(/^#1: #{Regexp.escape(message)} \d{8}-\d{4}$/)
    end
    it "adds quote in right position" do
      send_command("qadd #{message}")
      send_command("qadd next message")
      expect(Lita.redis.hget("handlers:quote:list", 2)).to match(/^#2: next message \d{8}-\d{4}$/)
    end
    it "reports it added a quote" do
      send_command("qadd #{message}")
      expect(replies.last).to match(/Added quote #\d+/)
    end
  end

  describe "#get_quote" do
    it "reports no quotes were found" do
      send_command("qget")
      expect(replies.last).to match("No quote found")
    end
    it "reports given quote not found" do
      send_command("qget 1")
      expect(replies.last).to match("No quote found")
    end
  end

  describe "#del_quote" do
  end
end
