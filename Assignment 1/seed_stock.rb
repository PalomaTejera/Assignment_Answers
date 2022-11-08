#!/usr/bin/env ruby

#Modules used
require 'date'

#This is the class SeedStock
class SeedStock
    attr_accessor :seed_stock
    attr_accessor :gene_id
    attr_accessor :gene
    attr_accessor :last_planted
    attr_accessor :storage
    attr_accessor :grams_remaining
    @gene_id=0

    @@seedstocklist = {}

    def initialize(seed_stock:, gene_id:, last_planted:, storage:, grams_remaining:) 
        @gene_id = gene_id
        @gene = Gene.find_gene_id(@gene_id)
        @storage = storage
        @seed_stock = seed_stock
        @last_planted = last_planted
        @grams_remaining = grams_remaining.to_i #Cast to integer

    end

    def self.load_from_file(seed_stock_data)
        #Read seed_stock_data file
        s = CSV.read(seed_stock_data, headers: true, col_sep: "\t")
        #We will keep the headers
        @stock_header = s.headers
        s.each.with_index() do |line|
            @@seedstocklist[line["Seed_Stock"]] =  SeedStock.new(:seed_stock => line["Seed_Stock"], :gene_id => line["Mutant_Gene_ID"],  :last_planted => line["Last_Planted"],
                :storage => line["Storage"], :grams_remaining => line["Grams_Remaining"])
        end
        return @@seedstocklist
    end

    #Find a seedstock 
    def self.get_seedstock(stock_id)
        @@seedstocklist.each do |seedstock|
            return seedstock[1] if seedstock[1].seed_stock == stock_id
        end
    end

    #Method that plants 7 g of seeds
    def plant(grams)
        #Take 7 grams
        if @grams_remaining < grams || @grams_remaining == grams
        puts "Warning: we have run out of Seed Stock #{@seed_stock} "
        @grams_remaining = 0
        else @grams_remaining = @grams_remaining - 7
        end
        @last_planted = DateTime.now.strftime('%-d/%-m/%Y') #Update the date
    end

    #Method that creates the new_stock_file
    def self.write_database(new_stock_file)
        #Create a new file
        new = File.open(new_stock_file, 'w')
        #Keep header (tab separated)
        new.puts(@stock_header.join("\t"))
        @@seedstocklist.each do |seedstock|
            new.puts([seedstock[1].seed_stock, seedstock[1].gene_id, seedstock[1].last_planted, seedstock[1].storage, seedstock[1].grams_remaining].join("\t"))
        end
    end
end
