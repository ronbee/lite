module Cluster
  class Grammy
  
    def initialize
      @word        = Hash.new
      @word_next   = Hash.new
      @word_bigram = Hash.new
      @perms = Hash.new
    end
  
    def digest!( arg )
      word_seq_array = arg.first
      (0..word_seq_array.size-1).each do |i|
        w = word_seq_array[i]
        @word[ w ] ||= 0
        @word[ w ] += 1
        next if i == word_seq_array.size-1
        next_w = word_seq_array[i+1]
        @word_bigram[ w ] ||= {}
        @word_bigram[ w ][next_w] ||= 0
        @word_bigram[ w ][next_w] += 1          
        @word_next[ next_w] ||= 0
        @word_next[ next_w ] += 1
      end
    end
  
  
    def deep_traverse( depth=3, cutoffs=[10,3,2] )    
      a = { :w => @word.delete_if{|key, value| value <= cutoffs.first } , :wb => @word_bigram } #{  :w=>{}, :wb=>{} }
      depth.times do |i|
        cutoff = cutoffs[ i ]
        @word = a[:w]
        @word_bigram = a[:wb]      
        a = a[:w].keys.inject( a ) do |a, uni|
          cs = sig_bigrams(uni, cutoff)
          cs.keys.each do |x| 
            new_uni = "#{uni} #{x}"
            a[:w][new_uni] = a[:wb][uni][x] rescue 0; 
            a[:wb][x].keys.each{|z| a[:wb][new_uni] ||= {}; a[:wb][new_uni][z] ||= {}; a[:wb][new_uni][z] = ( (a[:wb][uni][x]/@word_next[x].to_f)* (a[:wb][x][z]||0) ).to_i  } rescue ""
          end
          a[:w].delete(uni) if cs.size > 0 or a[:w][uni] < cutoff
          a
        end
      end
      a
    end
  
  
    def sig_bigrams(word, min)
      return { } if @word_bigram[ word ].nil?||@word_bigram[ word ].empty?
       
      total = @word.values.inject(:+)  
      count = @word_bigram[word].values.inject(:+)
      sig_big = { }    
      scores = word_scores( count, @word, @word_bigram[word], total, min )
      scores.to_a.sort{|wc,zc| zc[1] <=> wc[1] }.each do |w,c|
        next if @word_bigram[word][w] < min 
        null_score = null_score( count, @word, total, 0.1, 10 )
        sig_big[w] = c if c > null_score 
      end
      sig_big
    end
  
    def word_scores( count, unigram, bigram, total, min_count )
      val = Hash.new
      bigram.keys.each do |v|
        uni = unigram[v]||0
        big = bigram[v]||0
        next if big < min_count
    
        log_pi_vu = safelog(big) - safelog(count)
        log_pi_vnu = safelog(uni - big) - safelog(total - big)
        log_pi_v_old = safelog(uni) - safelog(total)
        log_1mp_v = safelog(1 - Math.exp(log_pi_vnu))
        log_1mp_vu = safelog(1 - Math.exp(log_pi_vu))
            
        val[v] = 2 * (big * log_pi_vu + \
                     (uni - big) * log_pi_vnu - \
                     uni * log_pi_v_old + \
                     (count - big) * (log_1mp_vu - log_1mp_v))
      end
      val
    end
  
    def null_score( count, bigram, total, pvalue, perm_hash )
    
      perm_key =  count/perm_hash # int div ..
    
      return @perms[perm_key] if @perms.has_key?  perm_key 
    
      max_score = 0
      nperm = (1.0 / pvalue).to_i
      table = bigram.to_a.sort{|a,b| b[1]<=>a[1]}
      (0..nperm).each do |perm|
        #perm_bigram = sample_no_replace(total, table, count)
        perm_bigram = new_sample_no_replace(total, bigram, count)
        obs_score = word_scores(count, bigram, perm_bigram, total, 1)
        obs_score = obs_score.values.max
        max_score = obs_score if (obs_score > max_score or perm == 0)
      end             
      @perms[perm_key] = max_score
    
      max_score
    end
  
    def safelog x
      x< 0 ? x : x==0? -1000000 : Math.log( x ) 
    end
  
    def new_sample_no_replace(total, table, nitems)
      cdf = CDFast.new table

      cdf.sample( nitems ).inject( {} ){|h,x| h[ x ] ||= 0; h[x] +=1; h}
    end

    def sample_no_replace(total, table, nitems)    
      sample = (0..total).to_a.sample( nitems )
      count = {}
      sample.each do |n|
        w = nth_item_from_table(table, n)
        count[w] ||= 0
        count[w] += 1
      end
      count
    end
  
    def nth_item_from_table(table, n)
      sum = 0
      table.each do |wc|
        sum = sum + wc[1]
        return wc[0] if (n < sum) #table is sorted 
      end    
      table.last.first
    end  
  end


  class CDFast
    def initialize table
      @a = table.to_a.inject([[], 0]){|a,kv| a[0] += Array.new( kv.last,a[1]); a[1]+=1 ; a}
    end

    def to_s
      "#{@a}"
    end

    def sample tt
      s = tt.size/[@a.size, tt.size].min
      (1..s).to_a.inject([]){|a,x| a += @a.sample(s) }
    end
  end
end
