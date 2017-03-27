require 'optparse'
require 'ostruct'
require 'open-uri'
require 'nokogiri'
require 'openSSL'

#Parse parameters
param = OpenStruct.new
OptionParser.new do |opt|
        opt.banner = "Usage: search.rb [options]\n\n"
        opt.on('-g', '--gen  Nombre Gen [String]', 'The name of the gen that you want to search Ex: FBN1') { |o| param.gen = o }
        opt.on('-s', '--show', 'Shows all available information at console output') { |o| param.show = o }
        opt.on('-w', '--web Path to file [String]', 'A path where the script is going to create an html file with the output of the result ("www" directory maybe)') { |o| param.web = o }
        opt.on_tail('-v', '--version', 'Shows version') { puts "genSearch v0.9"; exit }
        opt.on_tail('-h', '--help', 'This script is used to get the information from a gen from a data base on the internet (so you need a conection) then it gets the basic information from that gen and stores it in a local database (mysql), see options for futher details') { puts "\n\n\n\n"; puts opt; puts "\n\n"; exit }
end.parse!

## variables globales (declaracion)
@idGen = ""
@summary = ""
@ng = ""
@publicationsIds

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
idSite = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=gene&amp;term=#{param.gen}%5bGene%20Name%5d+AND+\"Homo%20sapiens\"%5bOrganism"

## Regresa el XML
# se debe poner en los parametros de la URL el termino 'term'= con una variable de entrada
doc = Nokogiri::XML(open( idSite , {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}))

## Debe regresar el Id del gen
#  si no encontro nada terminar el programa

if doc.xpath("//Count/node()")[0] == "0" #consulta xpath para regresar el primer valor de la etiqueta count (por eso el [0])
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
#  Aun no estan confirmadas cuales son pero summary es una de ellas
@summary = doc.xpath("//Summary/node()")[0]

## Tercera string para obtener valor NG_XXXXXXXX
ngGen = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=gene&amp;id=#{@idGen}&amp;report=sgml&amp;retmode=xml"
## vamos por los datos del xml
doc = Nokogiri::XML(open( ngGen , {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}))

## Aqui devuelve un arreglo con varios valores, ocupamos extraer solo el que sea NG_XXXXXX
@ng = doc.xpath("//Gene-commentary_accession[contains(.,'NG_')]/node()")[0]
publicationsIds1 = doc.xpath("//PubMedId/node()")

## Cuarta string para obtener la cadena de ADN (dentro de las etiquetas: GBSeq_secuence)
cadena = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&amp;id=#{@ng}&amp;rettype=gb&amp;retmode=xml"

## vamos por los datos del xml
doc = Nokogiri::XML(open( cadena , {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}))

## super texto de la cadena de adn, tl;dr
@cadena = doc.xpath("//GBSeq_sequence/node()")
publicationsIds2 = doc.xpath("//PubMedId/node()")

##comparar los id's de publicationsIds1 y 2 para tener una lista unica
@publicationsIds = publicationsIds1 | publicationsIds2
## conseguir los datos de la referencias del ultimo link, pueden ser articulos o libros

##se debe leer esta cadena por cada publicación (parametro numero de publicaciones que quieres, por default 5?)
##Quinta cadena
#referencias = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&amp;retmode=xml&amp;id=#{idDePublicaciones}"
## hacer un ciclo aqui por cada elemento de publicationIds y sacar su información aunque no se si poner esa info en un map o guardarla directo en la base de datos, si es el segundo caso entonces primero seria mejor guardar lo demas antes.

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







































