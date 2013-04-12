require 'minitest/autorun'

require "#{File.dirname(__FILE__)}/../lib/lite"

class TestGrammy < MiniTest::Unit::TestCase
  def setup
    @test_data = 100.times.inject([]){|acc,_| acc << rand(20).times.inject(""){|s,_| s+= "#{['a a','b','c b'].sample} " }.chop.split }
  end

  def test_sanity
    grammy = Lite::Grammy.new
    @test_data.each{|x| grammy.digest! x }
    p grammy.extract
    assert true
  end
end
