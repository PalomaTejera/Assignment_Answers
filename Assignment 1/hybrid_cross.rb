#!/usr/bin/env ruby

#This is the class HybridCross
class HybridCross
    attr_accessor :parent1
    attr_accessor :parent2
    attr_accessor :f2_wild
    attr_accessor :f2_p1
    attr_accessor :f2_p2
    attr_accessor :f2_p1p2

    @@hybridcrosslist = {}

    def initialize(parent1:, parent2:, f2_wild:, f2_p1:, f2_p2:, f2_p1p2:)
        @parent1 = SeedStock.get_seedstock(parent1).gene
        @parent2 = SeedStock.get_seedstock(parent2).gene
        @f2_wild = f2_wild.to_f #to_f converts value to float
        @f2_p1 = f2_p1.to_f
        @f2_p2 = f2_p2.to_f
        @f2_p1p2 = f2_p1p2.to_f
    end

    def self.load_from_file(cross_data)
        #Load cross_data file
        c = CSV.read(cross_data, headers: true, col_sep: "\t")
        c.each.with_index() do |line|
            @@hybridcrosslist[line["Parent1"]+"_"+line["Parent2"]] =  HybridCross.new(:parent1 => line["Parent1"], :parent2 => line["Parent2"],
                                                                          :f2_wild => line["F2_Wild"], :f2_p1 => line["F2_P1"],
                                                                          :f2_p2 => line["F2_P2"], :f2_p1p2 => line["F2_P1P2"])
        end
        return @@hybridcrosslist
    end

    def self.analyze_linkage(hybridcross)
        #The chi-squared test:
        sumlines = hybridcross.f2_wild + hybridcross.f2_p1 + hybridcross.f2_p2 + hybridcross.f2_p1p2
        expected_wild = sumlines * 9/16
        expected_f2_p1 = sumlines * 3/16
        expected_f2_p2 = sumlines * 3/16
        expected_f2_p1p2 = sumlines * 1/16

        #Chi_squared: Summatory((observed-expected)^2/expected)
        chi_squared = ( (hybridcross.f2_wild - expected_wild)**2/expected_wild  +
                        (hybridcross.f2_p1 - expected_f2_p1)**2/expected_f2_p1 +
                        (hybridcross.f2_p2 - expected_f2_p2)**2/expected_f2_p2 +
                        (hybridcross.f2_p1p2 - expected_f2_p1p2)**2/expected_f2_p1p2 )

        #Correlation:
        #Chi-Square probability for a 0.05 is 7.815
        if chi_squared > 7.815
            puts "Recording: #{hybridcross.parent1.gene_name} is genetically linked to #{hybridcross.parent2.gene_name} with chisquare score #{chi_squared.round(13)}"
            hybridcross.parent1.add_linked_gene(hybridcross.parent2.gene_name, chi_squared)
            hybridcross.parent2.add_linked_gene(hybridcross.parent1.gene_name, chi_squared)
        end
    end
end