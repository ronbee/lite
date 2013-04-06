require File.dirname(__FILE__)+'/sparsevect.rb'

module Cluster
  class AddC
    def initialize( upperBoundOnNumClusters )
      @k_max = upperBoundOnNumClusters
      @centroids = []      
    end

    def observe!( instance )
      if @centroids.size == 0
        @centroids << Centroid.new( instance )
        return self
      end

      @centroids.sort! {|c1, c2|   instance.dist(c1.x) <=> instance.dist(c2.x) }
      closest_centroid = @centroids.first
      closest_centroid.update!( instance )

      if( @centroids.size >= @k_max ) 
        pairs = [] 
        @centroids.each_index do |i|
          min_d = 10**20
          min_c = 0          
          @centroids.each_index do |j|
            next if i==j
            d = @centroids[i].x.dist( @centroids[j].x )
            min_c = j if d < min_d
            min_d = d if d < min_d
          end
          pairs[i] = [ min_d, i, min_c]
        end
        pairs.sort! {|x,y| x[0]<=>y[0]}
        merge_info = pairs.first
        @centroids[merge_info[1]].merge!( @centroids[merge_info[2]] )
        @centroids = @centroids - [ @centroids[merge_info[2]] ]
      end
      @centroids << Centroid.new( instance )
      
      []
    end

    def getCentroids( min_num_instances_in_cluster = 2 )      
      @centroids.each do |c|        
        next if c.n >= min_num_instances_in_cluster
        p c
        @centroids = @centroids - [ c ]      
        next if c.n == 0
        aux = @centroids.inject( {:min_c => @centroids.first, :d => @centroids.first.x.dist( c.x )} ) {|a,cc| cc.nil? || cc.x.dist(c.x) > a[:d] ? a : { :min_c=>cc, :d=>cc.x.dist(c.x)} }        
        aux[:min_c].merge! c        
      end
      @centroids
    end
  end

  class Centroid < SparseVector
    attr_accessor :x,:n
    def initialize( x )
      @x = x
      @n = 0
    end

    def update!( newX )
      @x += ( @x - newX ).mult_scalar( 1.0/(@n+1) )
      @n +=  1
      self 
    end

    def merge!( centroid )
      @x = ( @x.mult_scalar(@n)+centroid.x.mult_scalar(centroid.n) ).mult_scalar( 1.0 / (@n + centroid.n) )
      @n += centroid.n
      self
    end
  end
 
end 
