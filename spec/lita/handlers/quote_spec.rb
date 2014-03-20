require "spec_helper"

describe Lita::Handlers::Quote, lita_handler: true do

  before do
    Lita.configure do |config|
      config.handlers.quote.date_format = "%Y%m%d-%H%M"
    end
  end

  it { routes_command("qadd dat funny guy").to(:add_quote) }
  it { doesnt_route("qadd").to(:add_quote) }
  it { doesnt_route("yo qadd dat funny guy").to(:add_quote) }

  it { routes_command("qget").to(:get_quote) }
  it { routes_command("qget 22").to(:get_quote) }
  it { doesnt_route("yo qget").to(:get_quote) }
  it { doesnt_route("qget dat").to(:get_quote) }

  it { routes_command("qdel 22").to(:del_quote) }
  it { doesnt_route("qdel").to(:del_quote) }
  it { doesnt_route("yo qdel dat").to(:del_quote) }

  describe "#add_quote" do
  end

  describe "#get_quote" do
  end

  describe "#del_quote" do
  end
end
