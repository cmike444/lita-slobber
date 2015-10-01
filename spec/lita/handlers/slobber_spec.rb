require "spec_helper"
require "securerandom"

describe Lita::Handlers::Slobber, lita_handler: true do
  it { is_expected.to route_command("start taking notes").to(:start_taking_notes) }

  describe '#start_taking_notes' do
    it "starts taking notes" do
      send_command("start taking notes")
      expect(replies.last).to eq("Alright, it's #{Time.now.strftime('%l:%M %P')} and I'm ready to take notes.")
    end
  end

  it { is_expected.to route_command("stop taking notes").to(:stop_taking_notes) }

  describe '#stop_taking_notes' do
    it "stops taking notes" do
      send_command("stop taking notes")
      expect(replies.last).to eq("Ok, it's #{Time.now.strftime('%l:%M %P')} and I'm done taking notes.")
    end
  end
end
