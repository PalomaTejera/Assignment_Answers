
class Gene
    @@genelist = Array.new  
    attr_accessor :id
      
    def initialize(id: nil) 
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