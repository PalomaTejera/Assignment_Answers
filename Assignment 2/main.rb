###################################################
#To start: ruby main.rb                           #
#Author: Paloma Tejera Nevado                     #
###################################################

require 'rest-client'  
require './annotated.rb'
require './fetch.rb'
require 'json'
require 'csv'

# To write console output into Text file
f = File.open('report.txt', 'w')
old_out = $stdout
$stdout = f

# Create a function called "fetch" that we can re-use everywhere in our code

#puts "Gene List"
genelist = Array.new

#Open the file
File.open('ArabidopsisSubNetwork_GeneList.txt', "r") do |f|
    f.readlines.each do |line|
        next unless line.match(/at\dg/i)
        line.strip!  # remove all spaces and newline characters
        g = InteractionNetwork.new(id: line)
        #puts "created Gene #{g.id}"
        #puts "#{g.id}"

    end
end
    #puts genelist

    InteractionNetwork.get_genes.each do |gene|
    #puts "I have retrieved gene #{gene.id}"

        res = fetch(url: "http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&style=raw&id=#{gene.id}");
        if res  # res is either the response object (RestClient::Response), or false, so you can test it with 'if'
            record = res.body  # get the "body" of the response
            #headers = res.headers  # get other details about the HTTP message itself
        #    puts record
        else
            puts "the Web call failed - see STDERR for details..."
        end
    
        #Get UniProt ID
        match = record.match(/db_xref="Uniprot\/SWISSPROT:(\w+)/)
        proteinid =  match[1] if match

        #Create arrays to store the data
        puts "Gene ID: #{gene.id} " "Protein ID: #{proteinid}"
        geneA = []
        geneB = []
        protA = []
        protB = []

        #Get the protein A and interaction with protein B.
        prot = fetch(url: "https://string-db.org/api/tsv/interaction_partners?identifiers=#{proteinid}");
        if prot
            prot.each_line do |line|
                temp = line.chop.split("\t")
                geneA << temp[0]
                geneB << temp[1]
                protA << temp[2]
                protB << temp[3]
            end
            
            #Combine the arrays protA with protB.
            interaction = protA.zip(protB)

            #Print as a list, two columns.
            interaction.each do |arr|
                arr.each do |interaction|
                    print "#{interaction} "
                end
                print "\n"
            end
        end

        #Get the GO
        resp1 = fetch(url: "http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=uniprotkb;id=#{gene.id};format=default");
        if resp1  # res is either the response object (RestClient::Response), or false, so you can test it with 'if'
            record1 = resp1.body  # get the "body" of the response
            match = record1.match(/GO:(\w+)/)
            go_data =  match[1] if match
                puts "GO: #{go_data}"
        end

        #Get the Kegg pathways
        resp2 = fetch(url: "https://rest.kegg.jp/get/ath:#{gene.id}")
        if resp2
            kegg_path = resp2.body
            kegg_path = kegg_path.match(/ath\d+\s+\w+\s\w+/) 
            puts "KEGG pathways: #{kegg_path}"
        end     

        #Create arrays to store the data
        category = []
        term = []
        columnC = []
        columnD = []
        columnE = []
        columnF = []
        columnG = []
        columnH = []
        columnI = []
        description = []

        #Get enrichment
        functional = fetch(url: "https://string-db.org/api/tsv/enrichment?identifiers=#{gene.id}");    
        if functional
            functional.each_line do |line|
                temp1 = line.chop.split("\t")
                    
                category << temp1[0]
                term << temp1[1]
                columnC << temp1[2]
                columnD << temp1[3]
                columnE << temp1[4]
                columnF << temp1[5]
                columnG << temp1[6]
                columnH << temp1[7]
                columnI << temp1[8]
                description << temp1[9]
                end
 
            #Put together the arrays term and description
            enrichment = term.zip(description)
            #Output as two columns
            enrichment.each do |arr|
                arr.each do |enrichment|
                    print "#{enrichment}"
                end
                print "\n"
            end   
        end

        #Store the data in a new file called "output.csv"
        CSV.open('output.csv', "w") do |csv|
            csv << ["#{interaction}}"]
            csv << ["#{enrichment}"]
            csv << ["#{kegg_path}"]
        end
    end

#Close console output
f.close


