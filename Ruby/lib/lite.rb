require "#{File.dirname(__FILE__)}/lite/ngrams.rb"
require "#{File.dirname(__FILE__)}/lite/cluster.rb"
require "#{File.dirname(__FILE__)}/lite/classifier.rb"
require "#{File.dirname(__FILE__)}/lite/sparsevect.rb"


module Lite
  include Cluster
  include Classify
end
