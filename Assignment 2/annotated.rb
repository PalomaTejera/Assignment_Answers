
require './interactionnetwork.rb'

class Annotated < InteractionNetwork
  @@known_genes = []
  attr_accessor :interaction
  attr_accessor :enrichment
  attr_accessor :kegg_path

  def initialize(interaction:, enrichment:, kegg_path:, **args) 
    super(**args)
    @interaction = interaction 
    @enrichment = enrichment
    @kegg_path = kegg_path
    @@known_genes.append self
  end

  def self.known_genes
    return @@known_genes
  end

  def known_genes
    return @@known_genes
  end
  
end
