require 'minitest/autorun'

require "#{File.dirname(__FILE__)}/../lib/lite.rb"

class TestCluster < MiniTest::Unit::TestCase
  def setup
    @test_data = 1000.times.inject([]){|a,_| a << 10.times.inject({}){|a,_| a[ rand(100) ] = rand; a }  }
  end

  def test_sanity
    clusty = Lite::AddC.new 7
    @test_data.each{|x| clusty.observe! x }
    puts "cenroids --" 
    clusty.centroids.each{|c| puts "#{c}"}
    assert true
  end
end
