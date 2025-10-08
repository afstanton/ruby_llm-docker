# frozen_string_literal: true

RSpec.describe RubyLLM::Docker do
  it 'has a version number' do
    expect(RubyLLM::Docker::VERSION).not_to be_nil
  end
end
