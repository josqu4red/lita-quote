require "spec_helper"

describe Lita::Handlers::Quote, lita_handler: true do

  before do
    Lita.configure do |config|
      config.handlers.quote.date_format = "%Y%m%d-%H%M"
    end
  end

  it { is_expected.to route_command("qadd dat funny guy").to(:add_quote) }
  it { is_expected.not_to route_command("qadd").to(:add_quote) }
  it { is_expected.not_to route_command("yo qadd dat funny guy").to(:add_quote) }

  it { is_expected.to route_command("qget").to(:get_quote) }
  it { is_expected.to route_command("qget 22").to(:get_quote) }
  it { is_expected.not_to route_command("yo qget").to(:get_quote) }
  it { is_expected.not_to route_command("qget dat").to(:get_quote) }

  it { is_expected.to route_command("qdel 22").with_authorization_for(:admins).to(:del_quote) }
  it { is_expected.not_to route_command("qdel").to(:del_quote) }
  it { is_expected.not_to route_command("yo qdel dat").to(:del_quote) }

  describe "#add_quote" do
  end

  describe "#get_quote" do
  end

  describe "#del_quote" do
  end
end
