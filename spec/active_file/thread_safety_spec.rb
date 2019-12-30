require 'spec_helper'

describe ActiveFile::Base, "thread safety" do
  before do
    ActiveYaml::Base.set_root_path File.expand_path(File.dirname(__FILE__) + "/../fixtures")

    class City < ActiveYaml::Base
      def self.load_file
        sleep rand(0...0.3)
        super
      end
    end
  end

  after do
    Object.send :remove_const, :City
  end

  it 'is thread-safe' do
    threads = []
    n = 1000

    n.times do |n|
      thread = Thread.new do
        City.find(2).name
      end
      thread.abort_on_exception = true

      threads << thread
    end

    threads.each(&:join)
  end

end
