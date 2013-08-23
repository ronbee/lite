require "json"

module VMM

class PPM

  def initialize ab,d=5
    @trie = Trie.new
    @ab = ab
    @d = d
  end

  def learn str
    (str.size - @d-1 ).times{|i| @trie.grow(str[i..i+@d-1],str[i+@d]) }
  end

  def log_eval str
    (str.size - @d).times.inject(0.0) do |agg,i|
      agg += path_predict( str[@d], @trie.path( str[i..i+@d-1] ) )
    end

  end

  def path_predict sym, path
    path.reverse.inject( 0.0 ) do |agg, context|
      agg += Math.log( single_pr( sym, context ), 2.0 )
      break( agg ) if context===@trie.root or !context[:c].has_key?(sym)
      agg
    end
  end

  def single_pr sym, context
    p context
    ( context[:v].has_key?( sym ) ? context[:v][sym] : context[:v].size ) /  
      (context[:v].values.inject(:+) + context[:v].size).to_f  
  end


  def to_json 
    { :trie => @trie.root, :ab => @ab, :d => @d }.to_json
  end

  def self.load json
    model = JSON.parse json
    ppm = PPM.new( model[:ab],model[:d] )
    ppm.trie = model[:trie]
    ppm
  end
end

class Trie
  def initialize(root=nil)
    @root = root.nil? ? ({ :c => {}, :v => { } }) : root
  end

  def root
    @root
  end

  def grow(context, symbol) 
    node = @root
    @root[:v][symbol]||=0
    @root[:v][symbol]+=1
    context.each_char do |ch|
      node[:c][ch] ||= new_node symbol
      node[:v][symbol]||=0 
      node[:v][symbol] += 1
      node = node[:c][ch]
    end
    true
  end

  def path str
    str.chars.inject([@root]) do |agg,ch|
      next(agg) unless agg.last[:c][ch]
      agg << agg.last[:c][ch]
      agg
    end
  end

  def new_node( v )
    { :c => {}, :v => { v => 1} }
  end
end


end
