require "json"
require "set"

module Classify

  class NB

    def initialize
      @labels = {}
      @features = Set.new
      @nF = 0.0
      @nL = 0.0
      @c = 0.5
    end

    def update! fvect, label
      @labels[ label ] ||= { "xs" => {}, "N"=>0 }
      fvect.each{|k,v|  @features<<k; @labels[label]["nX"]||=@c ;@labels[ label ]["xs"][k] ||= @c; @labels[ label ]["xs"][k] += v;@labels[label]["nX"]+=v}
      @labels[ label ]["N"]+=1
      wrapup
    end

    def classify fvect
      @labels.keys.inject({}) do |aux,y|
        sx = fvect.keys.inject(0.0){|z, fi| z += fvect[fi] * Math.log( (@labels[y]["xs"][fi]||@c) / (@labels[y]["nX"]+@c*@nF))}
        sy = Math.log( @labels[y]["N"] / @nL ) # here no smoothing
        aux[ y ] = sx + sy 
        aux
      end
    end


    def to_json
      { "id" => "#{rand(10000)}#{Time.now.to_i}", "labels"=>@labels, "F"=>@features.to_a, "nf"=>@nF, "nl"=>@nL,"c"=>@c  }.to_json
    end

    def self.from_json json
      parsed = JSON.parse json
      c = self.new
      c.instance_variable_set("@labels", parsed["labels"])
      c.instance_variable_set("@features", Set.new( parsed["F"] ) )
      c.instance_variable_set("@nF", parsed["nf"])
      c.instance_variable_set("@nL",  parsed["nl"])
      c
    end

    :private
    def wrapup
      @nF = @features.size
      @nL = @labels.keys.inject(0.0){|s,k| s += @labels[k]["N"]}
      @labels.keys.each{|k| @labels[k]["sF"] = @labels[k]["N"]+@c*@nF}
    end
  end
end
