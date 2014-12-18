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
    it "adds a quote to database" do
      send_command("qadd <+renchap> t'as un user et pas d'accès ? <+josqu4red> nan mais allow")
      expect(replies.last).to match(/Added quote #\d+/)
    end
  end

  describe "#get_quote" do
  end

  describe "#del_quote" do
  end
end
