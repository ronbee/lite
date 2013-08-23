require "#{File.dirname(__FILE__)}/lite/ngrams.rb"
require "#{File.dirname(__FILE__)}/lite/cluster.rb"
require "#{File.dirname(__FILE__)}/lite/classifier.rb"
require "#{File.dirname(__FILE__)}/lite/sparsevect.rb"
require "#{File.dirname(__FILE__)}/lite/vmm.rb"


module Lite
  include Cluster
  include Classify
  include VMM
end
