require "msgpack"

module VMM

class PPM

  def initialize ab,d=5
    @trie = Trie.new
    @ab = ABet.new ab
    @d = d
  end

  def learn str
    (str.size - @d-1 ).times{|i| @trie.grow(str[i..i+@d-1].chars.map{|sym| @ab.sym_to_i( sym )}, @ab.sym_to_i( str[i+@d] ) ) }
  end

  def log_eval str
    (str.size - @d).times.inject(0.0) do |agg,i|
      agg += path_predict( @ab.sym_to_i(str[@d]) , @trie.path( str[i..i+@d-1].chars.map{|sym| @ab.sym_to_i(sym)} ) )
    end
  end

  def path_predict sym, path
    path.reverse.inject( 0.0 ) do |agg, context|
      agg += Math.log( single_pr( sym, context ), 2.0 )
      break( agg ) if context===@trie.root or !context[0].has_key?( sym )
      agg
    end
  end

  def single_pr sym, context
    ( context[1].has_key?( sym ) ? context[1][sym] : context[1].size ) /  
      (context[1].values.inject(:+) + context[1].size).to_f  
  end

  def to_file file_path 
    msg = { 'trie' => @trie.root, 'ab' => @ab.sym_arr, 'd' => @d }.to_msgpack
    out = File.new( file_path, "w" )
    out.print msg
    out.close
  end

  def self.from_file file_path
    model = MessagePack.unpack( File.new( file_path,"rb").readlines.join )
    ppm = PPM.new( model['ab'],model['d'] )
    ppm.instance_variable_set( :@trie, Trie.new( model['trie'] ) )
    ppm
  end
end

class Trie
  def initialize(root=nil)
    @root = root.nil? ? ( [{}, {} ]) : root
  end

  def root
    @root
  end

  def grow(context, symbol) 
    node = @root
    @root[1][symbol]||=0
    @root[1][symbol]+=1
    context.each do |ch|
      node[0][ch] ||= new_node symbol
      node[1][symbol]||=0 
      node[1][symbol] += 1
      node = node[0][ch]
    end
    true
  end

  def path sym_arr
    sym_arr.inject([@root]) do |agg,ch|
      next(agg) unless agg.last[0][ch]
      agg << agg.last[0][ch]
      agg
    end
  end

  def new_node( v )
    [{}, { v => 1}]
  end
end

class ABet
  def initialize sym_arr
    @ab = sym_arr
    @sym_to_i = Hash[ sym_arr.zip( (0..sym_arr.size-1).to_a ) ]
  end

  def sym_to_i sym
    @sym_to_i[ sym ] || @ab.size
  end

  def i_to_sym id
    @ab[ id ] || @ab[ size ]
  end

  def sym_arr
    @ab
  end

  def size
    @ab.size + 1
  end
end

end
