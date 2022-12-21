#This program reads the file '/ArabidopsisSubNetwork_GeneList.txt' and put the gene id into objets.
#It creates a Bio::EMBL object and then a Bio::Feature object.
#One file is generated as .gff3 with the gene id and the positions with the repeated sequence in the exons.
#A second file is generated with the genes that do not contain the repeated sequence.

require './fetch.rb' #Error handling
require 'bio'
require 'net/http' 
require './gene.rb'  #Gene class

sequence ="cttctt" #Sequence "CTTCTT" that we want to look at in the exons.
contains_sequence = File.new("contains_repeat_sequence.gff", "w") #File that will store the gene_id and positions. 
contains_sequence.puts("##gff-version 3") #To create the header
genes_no_sequence = [] #Genes without "CTTCTT" sequence in exons
no_contains_sequence = File.new("genes_no_repeat.txt", "w") #File that will store the gene_id that do not have repeat in exons.

File.open('./ArabidopsisSubNetwork_GeneList.txt', "r") do |f|
    f.readlines.each do |l|
        l.strip!
        next unless l.match(/at\dg/i)
        g = Gene.new(id: l)
        puts "created Gene #{g.id}"
        #gene=line.strip().upcase()
        #genelist.append(gene)
    end

Gene.get_genes.each do |gene|
  #Get the information for each gene
  address = URI("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{gene.id}")
  response = fetch(address)
  record = response.body
  entry = Bio::EMBL.new(record)
  bioseq = entry.to_biosequence
  
  sequence_position_plus = [] #Sequence position in the plus strand
  sequence_position_minus = [] #Sequence position in the minus strand
 
  #Get the positions for the exons
  entry.features.each do |feature|
    if feature.feature == "exon"
      association = feature.assoc.to_s #Returns a Hash construct
      #puts association
      position = feature.position.to_s
      #puts position
      #Take the exons
      if /exon_id/.match(association)
          unless /[A-Z]/.match(position)
            next unless feature.feature =="exon"
            #Find the start and finish position
            range = feature.position.match(/(\d+)\.\.(\d+)/)
            #puts range
            range = position.tr('complement()','')
            range = range.split("..")
            start = range[0].to_i #Start position of the exon
            finish = range[1].to_i #End position of the exon
            
            #If the strand is minus, obtain the reverse_complement
            if /complement/.match(position)  
              bioseq_rev = bioseq.reverse_complement
              exon = bioseq_rev.subseq(start,finish)
              strand = "minus"
            else 
              exon = bioseq.subseq(start,finish)
              strand = "plus"
            end
            
            #Look for the sequence
            sequence_position_exon = (0 ... exon.length).find_all { |i| exon[i,sequence.length].match sequence }
            sequence_position_gene = []

            sequence_position_exon.each do |start_position|
              aux = []
              start_position = start_position + start + 1 
              finish_position = start_position + sequence.length - 1 
              aux.push start_position
              aux.push finish_position 
              sequence_position_gene.push aux
            end

            if strand == "plus"
                sequence_position_gene.each do |coor|
                sequence_position_plus.push coor
              end
            else
                sequence_position_gene.each do |coor|
                sequence_position_minus.push coor
              end
            end
            
            sequence_position_plus = sequence_position_plus.uniq  
            sequence_position_minus = sequence_position_minus.uniq 
          end 
      end
    end
  end
  
  if sequence_position_plus.any? or sequence_position_minus.any?
    #From Lesson 6 - BioRuby and Biogems
    sequence_position_plus.each do |start_end|
      f1 = Bio::Feature.new('myrepeat',start_end)
      f1.append(Bio::Feature::Qualifier.new('repeat_motif', 'CTTCTT'))
      f1.append(Bio::Feature::Qualifier.new('strand', '+'))
      bioseq.features << f1 
    end

    sequence_position_minus.each do |start_end|
      f2 = Bio::Feature.new('myrepeat',start_end)
      f2.append(Bio::Feature::Qualifier.new('repeat_motif', 'CTTCTT'))
      f2.append(Bio::Feature::Qualifier.new('strand', '-'))
      bioseq.features << f2 
    end

    #Write the GFF3 file
    entry.features.each do |feature|
      association = feature.assoc
      #puts association
      position = feature.position
      #puts position

      if /repeat_motif/.match(association.to_s)
        #puts association
        start = position[0].to_i #Initial position
        finish =position[1].to_i #Final position 
        if /"-"/.match(association.to_s) #To store the information in the file from the minus strand
          contains_sequence.puts"#{gene.id}\t.\t#{sequence}\t#{start}\t#{finish}\t.\t-\t.\n"
        else 
          #To store the information in the file from the plus strand
          contains_sequence.puts "#{gene.id}\t.\t#{sequence}\t#{start}\t#{finish}\t.\t+\t.\n"
        end
      end

    end
  end

  #Get the genes that do not have the sequence repeat
  if sequence_position_plus.empty? and sequence_position_minus.empty?
    genes_no_sequence.push "#{gene.id}"
  end
end

  #Output file with the genes that do not have the sequence repeat
  no_contains_sequence.print genes_no_sequence.to_s
end
