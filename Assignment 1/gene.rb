#################################################
#!/usr/bin/env ruby                             #
#version:2.0 05/11/2022                         #
#This script has been developed with            #
#resources of Pablo Ignacio Marcos López        #      
#(former Master student)                        #
#################################################

#Modules used
require 'csv'

#This is the class Gene
class Gene
    attr_accessor :gene_id
    attr_accessor :gene_name
    attr_accessor :mutant
    attr_accessor :linked_genes

    @@genelist = {}

    def initialize(gene_id:, gene_name:, mutant:)
        @gene_id = gene_id
        @gene_name = gene_name
        @mutant = mutant

        @linked_genes = {}

        #Regular expression for the Arabidopsis gene identifiers
        arabidopsisgene_identifier = /A[Tt]\d[Gg]\d\d\d\d\d/ 
        unless arabidopsisgene_identifier.match(@gene_id)
            abort("The gene identifier is not correct")
        end
    end

    #Find a gene with the id
    def self.find_gene_id(id)
            @@genelist.each do |gene|
            return gene[1] if gene[1].gene_id == id
        end
    end

    def self.load_from_file(gene_information)
        #Load gene_information file
        g = CSV.read(gene_information, headers: true, col_sep: "\t") 
        g.each() do |line|
            @@genelist[line["Gene_ID"]] =  Gene.new(:gene_id => line["Gene_ID"], :gene_name => line["Gene_name"], :mutant => line["mutant_phenotype"])
        end
        return @@genelist
    end

    def add_linked_gene(gene, chi_squared)
        @linked_genes[gene] = chi_squared
    end

end
