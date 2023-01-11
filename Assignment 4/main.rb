=begin
Assignment 4. Author:Paloma Tejera Nevado
There are some parameters that can be selected in the blast to get orthologs as reciprocal best hits (RBH).
Here, it has been used an e-value threshold of 10**-6 and a coverage of at least 50%. 
They can result in a high number of orthologs and a minimal error rate [1].
[1] Moreno-Hagalsieb & K. Latimer. 2007. Choosing BLAST options for better detection of orthologs as reciprocal best hits.
Bioinformatics. Vol.24; no.3 (319-324) 
=end

require 'bio'

#Create a database
system "makeblastdb -in pep.fa -dbtype 'prot' -out pep"
system "makeblastdb -in TAIR10_cds_20101214_updated.fa -dbtype 'nucl' -out TAIR10"

#Establish the factories
local_pblast_factory = Bio::Blast.local('blastx', 'pep') #blastx search protein databases using a translated nucleotide query
local_nblast_factory = Bio::Blast.local('tblastn', 'TAIR10') #tblastn search nuclotide databases using a protein query

#Open the files and include one in a hash
pep = File.open('pep.fa', "r")
tair10 = File.open('TAIR10_cds_20101214_updated.fa', "r")
tair10 = Bio::FlatFile.auto(tair10)
pep = Bio::FlatFile.new(Bio::FastaFormat, pep)

#Key=ID; Value=sequence
tair10_hash=Hash.new
tair10.each do |entry|
    tair10_hash[(entry.entry_id).to_s] = (entry.seq).to_s
end

#Create the file to store the orthologs
orthologs=File.open('./orthologue_pairs.txt', 'w')
orthologs.puts "Orthologue pairs: \n"

#Perform the BLAST
pep.each do |peptide|
    protein_id=(peptide.definition.match(/(\w+\.\w+)/)).to_s #Find protein id
    blast1 = local_nblast_factory.query(peptide)
puts "Blast protein #{protein_id}"

    #First BLAST
    #Consider that there are hits with the conditions
        if blast1.hits[0] != nil and blast1.hits[0].evalue <= 10**-6 and blast1.hits[0].overlap.to_i >= 50
            nucleotide_id = (blast1.hits[0].definition.match(/(\w+\.\w+)/)).to_s

            puts "Found hit in #{nucleotide_id} Look for reciprocal hit"
            sequence = tair10_hash[nucleotide_id]

    #Second BLAST
            blast2=local_pblast_factory.query("#{sequence}")
            if blast2.hits[0] != nil and blast2.hits[0].evalue <= 10**-6 and blast2.hits[0].overlap >= 50
                hit=(blast2.hits[0].definition.match(/(\w+\.\w*)/)).to_s
                if protein_id == hit
                    orthologs.puts "#{protein_id}\t#{nucleotide_id}" #Save it in the file
                    puts "#{protein_id} is an ortholog to #{nucleotide_id}"
                end
            end
        end
end
