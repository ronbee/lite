require 'minitest/autorun'

require "#{File.dirname(__FILE__)}/../lib/lite"

class TestVMM < MiniTest::Unit::TestCase
  def setup
    @test_data = "abracadabra" 
  end

  def test_sanity
    vmm = Lite::PPM.new( ['a','b','c','d','r'],2 )
    vmm.learn "abbbbabababrararara"
    vmm.learn "cabcabcabcabcabcabcabcabrararararararabracabra"
    p vmm
    puts "----"
    puts "... #{vmm.log_eval @test_data} ..."
    assert true
  end
end
