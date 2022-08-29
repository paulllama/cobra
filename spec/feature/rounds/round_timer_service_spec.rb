RSpec.describe 'round timer service' do
  let(:tournament) { create(:tournament) }
  let(:round) { create(:round, stage: tournament.current_stage) }
  delegate :timer, to: :round

  it 'has a default round length' do
    expect(round.length_minutes).to be(65)
  end

  it 'computes finish time' do
    travel_to Time.zone.local(2022, 8, 29, 15, 0)
    timer.start!
    expect(timer.finish_time).to eq Time.zone.local(2022, 8, 29, 16, 5)
    expect(timer.running?).to be(true)
  end

  it 'has no finish time if stopped before end' do
    travel_to Time.zone.local(2022, 8, 29, 15, 0)
    timer.start!
    travel_to Time.zone.local(2022, 8, 29, 15, 30)
    timer.stop!
    expect(timer.finish_time).to be_nil
    expect(timer.running?).to be(false)
  end

  it 'has finish time if stopped after end' do
    travel_to Time.zone.local(2022, 8, 29, 15, 0)
    timer.start!
    travel_to Time.zone.local(2022, 8, 29, 16, 10)
    timer.stop!
    expect(timer.finish_time).to eq Time.zone.local(2022, 8, 29, 16, 5)
    expect(timer.running?).to be(false)
  end

  it 'computes finish time after resuming paused timer' do
    travel_to Time.zone.local(2022, 8, 29, 15, 0)
    timer.start!
    travel_to Time.zone.local(2022, 8, 29, 15, 30)
    timer.stop!
    travel_to Time.zone.local(2022, 8, 29, 16, 0)
    timer.start!
    expect(timer.finish_time).to eq Time.zone.local(2022, 8, 29, 16, 35)
    expect(timer.running?).to be(true)
  end

  it 'is not running after end time even if not stopped' do
    travel_to Time.zone.local(2022, 8, 29, 15, 0)
    timer.start!
    travel_to Time.zone.local(2022, 8, 29, 16, 10)
    expect(timer.finish_time).to eq Time.zone.local(2022, 8, 29, 16, 5)
    expect(timer.running?).to be(false)
  end

  it 'reports when no timer started yet' do
    expect(timer.finish_time).to be_nil
    expect(timer.running?).to be(false)
  end
end
