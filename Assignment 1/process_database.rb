#!/usr/bin/env ruby

#To run this script we need the following files
require './gene.rb'
require './seed_stock.rb'
require './hybrid_cross.rb'

#The user execute the program
ARGV[0]= './gene_information.tsv'
ARGV[1]= './seed_stock_data.tsv'
ARGV[2]= './cross_data.tsv'
ARGV[3]= './new_stock_file.tsv'

#Load Gene.rb file
genelist = Gene.load_from_file(ARGV[0])

#Load SeedStock.rb file
seedstocklist = SeedStock.load_from_file(ARGV[1])

#Load the cross_data.tsv file
hybridcrosslist = HybridCross.load_from_file(ARGV[2])

#Plant 7 seeds
seedstocklist.each do |seed|
    seed[1].plant(7)
end

#Update database
SeedStock.write_database(ARGV[3])

#Analise the linkage for each hybridcross
hybridcrosslist.each do |thiscross|
    HybridCross.analyze_linkage(thiscross[1])
end

#Print in the screen
puts
puts
puts "Final Report:"
puts

#Print the linked genes
genelist.each do |thisgene|
    thisgene[1].linked_genes.each do |linked| 
        linked_gene , chi_squared = linked
        puts "#{thisgene[1].gene_name} is linked to #{linked_gene}"
    end
end
