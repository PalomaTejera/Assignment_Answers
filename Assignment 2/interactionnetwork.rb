
class InteractionNetwork
  @@genelist = Array.new  
  attr_accessor :id  

    def initialize(id:) # get a name from the "new" call, or set a default
        @id = id  
        @@genelist.append(self)
    end

  def get_genes
      return @@genelist
  end

  def self.get_genes
      return @@genelist
  end
  
end