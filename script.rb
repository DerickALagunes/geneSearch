require 'optparse'
require 'ostruct'
require 'open-uri'
require 'nokogiri'
require 'openssl'
require 'mysql'

#Parse parameters
param = OpenStruct.new
OptionParser.new do |opt|
        opt.banner = "Usage: search.rb [options]\n\n"
        opt.on('-g', '--gen  Nombre Gen [String]', 'El nombre del gen que quieres buscar Ejemplo: FBN1') { |o| param.gen = o }
        opt.on('-l', '--limit  publicaciones [String]', 'Limita el numero de publicaciones de referencia sobre el gen en la base de datos') { |o| param.gen = o }
        opt.on('-s', '--show', 'Shows all available information at console output') { |o| param.show = o }
        opt.on('-w', '--web', 'An html will be created with the output of the result') { |o| param.web = o }
        opt.on_tail('-v', '--version', 'Shows version') { puts "genSearch v0.9"; exit }
        opt.on_tail('-h', '--help', 'This script is used to get the information from a gen from a data base on the internet (so you need a conection) then it gets the basic information from that gen and stores it in a local database (mysql), see options for futher details') { puts "\n\n\n\n"; puts opt; puts "\n\n"; exit }
end.parse!

## Conector a bd
#my = Mysql.new(hostname, username, password, databasename)
con = Mysql.new('localhost', 'derick', 'tuchito1', 'mydb')  
# rs = con.query('select * from student')  
# rs.each_hash { |h| puts h['name']}  

## variables por petición:
#petición 1
#pwtición 2
	@idGen = ""
	@official_name = ""
	@summary = ""
	@chromosome = ""
	@locus = ""
#petición 3
	@start_position = ""
	@end_position = ""
	@strand = ""
	@ng = ""
	@idAllele = ""
#peticion 4
	@publicationsIds
#peticion 5
	@title = ""
	@authors = ""
	@abstract = ""
	@publication = ""
	


##programa principal
#  si pasaron un gen en el parametro -g comienza, si no, aborta
if param.gen
	puts ""
	puts "Searching for #{param.gen}..."
	puts ""
else
	abort("Para comenzar el programa se necesita un parametro -g, usa -h para ver la ayuda")
end

## Define la primera string donde se buscara el id del gen que se quiera buscar
idSite = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=gene&amp;term='+param.gen+'%5bGene%20Name%5d+AND+"Homo%20sapiens"%5bOrganism'

## Regresa el XML
# se debe poner en los parametros de la URL el termino 'term'= con una variable de entrada
doc = Nokogiri::XML(open( idSite , {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}))

## Debe regresar el Id del gen
#  si no encontro nada terminar el programa
numero = doc.xpath("//Count/node()")[0].to_s

if numero=="0"
	puts "No existe gen"
	abort("Fin del programa, por favor ingrese un gen valido")
else
	@idGen = doc.xpath("//Id/node()")[0]
end

## Segunda String de consulta, ocupa el id, con esta queremos scar la información general del gen
infoGen = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=gene&amp;id=#{@idGen}&amp;retmode=xml"
## vamos por los datos del xml
doc = Nokogiri::XML(open( infoGen , {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}))

## Conseguir todos las variables de información
@official_name = doc.xpath("//NomenclatureName/node()")[0]
@summary =       doc.xpath("//eSummaryResult/DocumentSummarySet/DocumentSummary/Summary/node()")[0]
@chromosome =    doc.xpath("//eSummaryResult/DocumentSummarySet/DocumentSummary/Chromosome/node()")[0]
@locus =         doc.xpath("//eSummaryResult/DocumentSummarySet/DocumentSummary/MapLocation/node()")[0]

#checar si ya esta registrado
rs = con.query("SELECT idSymbol from Gene WHERE idSymbol=#{@idGen};")
if rs.num_rows > 0
	abort("Ese gen ya esta registrado, fin del programa")
else
	#insertar gen
	con.query("
	INSERT INTO Gene(idSymbol,officialName,summary,chromosome,locus) VALUES (
		'#{@idGen}',
		'#{@official_name}',
		'#{@summary}',
		'#{@chromosome}',
		'#{@locus}');
	")
	#insertar relacion con DataBank
	con.query("
	INSERT INTO Gene_has_DataBank(idGene,idDataBank) VALUES (
		'#{@idGen}',
		'1');
	")
end  

## Tercera string para obtener valor NG_XXXXXXXX
ngGen = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=gene&amp;id=#{@idGen}&amp;report=sgml&amp;retmode=xml"
doc = Nokogiri::XML(open( ngGen , {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}))

## Aqui devuelve un arreglo con varios valores, ocupamos extraer solo el que sea NG_XXXXXX
@ng = doc.xpath("//Gene-commentary_accession[contains(.,'NG_')]/node()")[0]
publicationsIds1 = doc.xpath("//PubMedId/node()")

##Contraints

@start_position = doc.xpath("//Entrezgene-Set/Entrezgene/Entrezgene_locus/Gene-commentary/Gene-commentary_type[@value='genomic']/../Gene-commentary_seqs/Seq-loc/Seq-loc_int/Seq-interval/Seq-interval_from/node()")[0]
@end_position =   doc.xpath("//Entrezgene-Set/Entrezgene/Entrezgene_locus/Gene-commentary/Gene-commentary_type[@value='genomic']/../Gene-commentary_seqs/Seq-loc/Seq-loc_int/Seq-interval/Seq-interval_to/node()"  )[0]
@strand = doc.xpath("//Entrezgene-Set/Entrezgene/Entrezgene_locus/Gene-commentary/Gene-commentary_type[@value='genomic']/../Gene-commentary_seqs/Seq-loc/Seq-loc_int/Seq-interval/Seq-interval_strand/Na-strand/@value")[0]
if @strand =~ "minus"
	@strand = "M"
else
	@strand = "P"
end

	#insertar a Allele
	con.query("
	INSERT INTO allele(start_position,end_position,strand,Gene_idSymbol) VALUES (
		'#{@start_position}',
		'#{@end_position}',
		'#{@strand}',
		'#{@idGen}');
	")
	#insertar relacion con DataBank
	aidee = con.query("SELECT MAX(ordnum) from allele;")
	@idAllele = aidee.fetch_row[0]
		con.query("
		INSERT INTO AlleleDataBankIndentificacion(DataBank_idDataBank, allele_ordnum) VALUES (
			'1',
			#{@idAllele});
		")


## Cuarta string para obtener la cadena de ADN (dentro de las etiquetas: GBSeq_secuence)
cadena = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&amp;id=#{@ng}&amp;rettype=gb&amp;retmode=xml"
doc = Nokogiri::XML(open( cadena , {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}))

## super texto de la cadena de adn, tl;dr
@cadena = doc.xpath("//GBSeq_sequence/node()")
	con.query("
	INSERT INTO AllelicReferenceType(sequense,allele_ordnum) VALUES (
		'#{@cadena}',
		'#{@idAllele}');
	")

publicationsIds2 = doc.xpath("//PubMedId/node()")
##comparar los id's de publicationsIds1 y 2 para tener una lista unica
@publicationsIds = publicationsIds1 | publicationsIds2

limite = 5

if param.limit
	limite = param.limit
end

for i in 0..limite
	referencias = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&amp;retmode=xml&amp;id=#{@publicationsIds[i]}"
	doc = Nokogiri::XML(open( referencias , {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}))

	if doc.xpath("//PubmedArticle")[0] != nil
		@publication = doc.xpath("//PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal/Title/node()")[0].to_s().gsub(/'/,"")
		last = doc.xpath("//PubmedArticleSet/PubmedArticle/MedlineCitation/Article/AuthorList/Author/LastName/node()")[0]
		fore = doc.xpath("//PubmedArticleSet/PubmedArticle/MedlineCitation/Article/AuthorList/Author/ForeName/node()")[0]
		@authors = "#{last} #{fore}"
		@abstract = doc.xpath("//PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Abstract/AbstractText/node()")[0].to_s().gsub(/'/,"")
		@title = doc.xpath("//PubmedArticleSet/PubmedArticle/MedlineCitation//Article/ArticleTitle/node()")[0].to_s().gsub(/'/,"")
	elsif
		@publication = doc.xpath("//PubmedArticleSet/PubmedBookArticle/BookDocument/Book/ArticleTitle/node()")[0].to_s().gsub(/'/,"")	
		last = doc.xpath("//PubmedArticleSet/PubmedBookArticle/BookDocument/Book/AuthorList/Author/LastName/node()")[0]
		fore = doc.xpath("//PubmedArticleSet/PubmedBookArticle/BookDocument/Book/AuthorList/Author/ForeName/node()")[0]
		@authors =  "#{last} #{fore}"
		@abstract = doc.xpath("//PubmedArticleSet/PubmedBookArticle/BookDocument/Abstract/AbstractText/node()")[0].to_s().gsub(/'/,"")
		@title = doc.xpath("//PubmedArticleSet/PubmedBookArticle/BookDocument/Book/BookTitle/node()")[0].to_s().gsub(/'/,"")	
	end

	##insert a BibliographyReference
	con.query("
	INSERT INTO BibliographyReference(title,authors,abstract,publication) VALUES (
		'#{@title}',
		'#{@authors}',
		'#{@abstract}',
		'#{@publication}');
	")	
	biblio = con.query("SELECT MAX(id) from BibliographyReference;")
	biblio = biblio.fetch_row[0]
	## insert a Allele_has_Bibliography_reference
	con.query("
	INSERT INTO allele_has_BibliographyReference(allele_ordnum, BibliographyReference_id) VALUES (
		'#{@idAllele}',
		'#{biblio}');
	")
	con.query("
	INSERT INTO BiblliographyDB(URL,BibliographyReference_id) VALUES (
		'https://www.ncbi.nlm.nih.gov',
		'#{biblio}');
	")
	con.query("
	INSERT INTO BibliographyReference_has_Gene(BibliographyReference_id,Gene_idSymbol) VALUES (
		'#{biblio}',
                '#{@idGen}');
	")	
end

puts "Gen insertado!"


## imprimir toda la información en consola
if param.show
	puts "--------------------------GeneSearch---------------------------"
	puts " We have searched for Gene: #{param.gen}, general information: "
	puts ""
	puts @summary
	puts ""
	puts ""
	puts ""
	puts ""
	puts ""
end


## crear un archivo HTML con el output
if param.web
	archivo = File.new("result_#{param.gen}.html", "w+")
	
	archivo.puts '<!doctype html>'
	archivo.puts '<html lang="en">'
	archivo.puts '<head>'
	archivo.puts '<meta charset="utf-8">'
	archivo.puts '<title>GeneSearchResult</title>'
	archivo.puts '</head>'
	archivo.puts '<body>'
	archivo.puts '<p><b>--------------------------GeneSearch---------------------------</b></p>'
	archivo.puts '<p>We have searched for Gene: #{param.gen}, general information:</p>'
	archivo.puts '<br />'
	archivo.puts '<p>'+@summary+'</p>'
	archivo.puts '<br />'
	archivo.puts '</body>'
	archivo.puts '</html>'

end






































con.close
