require 'set'

class SparseVector
  attr_accessor :attr
    
  def initialize( attr_map )
    @attr = attr_map
  end
    
  def dist( v )
    Math.sqrt( Set.new( @attr.keys + v.attr.keys ).inject(0){|d,k|  u_i = (@attr.has_key? k) ? @attr[k] : 0; v_i =  (v.attr.has_key? k) ? v.attr[k] : 0; d + (u_i-v_i)*(u_i-v_i) } )       
  end
    
  def -(v)
    SparseVector.new( Set.new( v.attr.keys + @attr.keys ).inject( { } ) { |a,c| a[c] = (@attr.has_key?(c) ? @attr[c] : 0) -  (v.attr.has_key?(c) ? v.attr[c] : 0); a } )
  end  
    
  def +(v)
    SparseVector.new( Set.new( v.attr.keys + @attr.keys ).inject( { } ) { |a,c| a[c] = (@attr.has_key?(c) ? @attr[c] : 0) + (v.attr.has_key?(c) ? v.attr[c] : 0); a } )
  end
    
  def mult_scalar( c )
    SparseVector.new( @attr.inject( { } ){ |a, kv| a[ kv.first ] = kv.last * c; a })
  end 
end  
