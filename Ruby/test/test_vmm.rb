require 'minitest/autorun'
require "#{File.dirname(__FILE__)}/../lib/lite"

class TestVMM < MiniTest::Unit::TestCase
  def setup
    @test_data = [ "abracadabra", "zzzzzzzzzzzzzzzzzzasdfasdfqwerqwer", "Rufen Sie mich Ishmael. Vor einigen Jahren - unter - nie,", 
                   "wie lange genau dagegen wenig oder kein Geld in meinem Geldbeutel, und nichts Besonderes, um mich auf interessante Ufer", 
                    "The casting of Hollywood A-lister Ben Affleck as the new Batman sparked fan outrage, with petitions calling for the coveted role to be recast and widespread howling on Twitter."]
    @training = File.new( "#{File.dirname(__FILE__)}/pg2701.txt", "r" ).readlines.map{|x| x.force_encoding("UTF-8").gsub(/\s+$/,"")}.reject{|x| x.nil? or x.empty? or x.size < 20}.shuffle
  end

  def test_one
    vmm = Lite::PPM.new( ('a'..'z').to_a + ('0'..'9').to_a+[".","~","/",":","#",",","?","!",";","\""],5 )
    pivot = @training[0..100].join(' ')
    @training[101..@training.size].each{|x| vmm.learn x }
    
    pivot_score = -vmm.log_eval( pivot )/pivot.size
    @test_data.each{|x| assert( ( - vmm.log_eval(x)/x.size ) > pivot_score ) }
  end


  def test_serialization
    vmm = Lite::PPM.new( ('a'..'z').to_a + ('0'..'9').to_a+[".","~","/",":","#",",","?","!",";","\""],5 )
    pivot = @training[0..100].join(' ')
    @training[101..@training.size].each{|x| vmm.learn x }

    vmm2 = Lite::PPM.deserialize( vmm.serialize )
    @test_data.each{|x| assert( ( - vmm.log_eval(x) ) ==  ( - vmm2.log_eval(x) )) }
  end

end
