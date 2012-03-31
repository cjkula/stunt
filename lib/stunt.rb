#% cat lib/stunt.rb
module Stunt
  module JavaScript
    def self.map!(*classes)
      classes.flatten.each do |klass|
        puts "Not yet implemented. Will map #{klass} to enable Ruby-style addressing of corresponding JavaScript class."
      end
    end
  end
end