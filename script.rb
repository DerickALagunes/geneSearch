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
        opt.on('-w', '--web Path to file [String]', 'A path where the script is going to create an html file with the output of the result (www directory maybe)') { |o| param.web = o }
        opt.on_tail('-v', '--version', 'Shows version') { puts "genSearch v0.9"; exit }
        opt.on_tail('-h', '--help', 'This script (with comments mainly in spanish) is used to get the information from a gen from a data base on the internet (so you need a conection) then it gets the basic information from that gen and stores it in a local database (mysql), see options for futher details') { puts "\n\n\n\n"; puts opt; puts "\n\n"; exit }
end.parse!


## variables globales (declaracion)
@idGen = ""

##programa principal
#  si pasaron un gen en el parametro -g comienza, si no, aborta
if param.gen
	puts "Buscando #{param.gen}..."
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

if doc.xpath("//Count").map(&:text)[0] == "0"
	puts "No existe gen"
	abort("Fin del programa, por favor ingrese un gen valido")
else
	@idGen = doc.xpath("//Id").map(&:text)[0]
	puts "Id del gen: #{@idGen}"
	puts "se va a buscar la informacion general sobre el gen..."
end

## Segunda String de consulta, ocupa el id, con esta queremos scar la información general del gen
infoGen = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=gene&amp;id=#{@idGen}&amp;retmode=xml"
## vamos por los datos del xml
doc = Nokogiri::XML(open( infoGen , {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}))

## Conseguir todos las variables de información
#  Aun no estan confirmadas cuales son pero summary es una de ellas

summary = doc.xpath("//Summary").map(&:text)[0]
puts "resumen:"
puts summary
puts "---------------"

## Tercera string para obtener valor NG_XXXXXXXX
ngGen = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=gene&amp;id=#{@idGen}&amp;report=sgml&amp;retmode=xml"
## vamos por los datos del xml
doc = Nokogiri::XML(open( ngGen , {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}))

## Aqui devuelve un arreglo con varios valores, ocupamos extraer solo el que sea NG_XXXXXX
ng = doc.xpath("//Gene-commentary_accession").map(&:text)

ng.each do |dato|
	if dato =~ /NG_/ #expresión regular que ve si el dato es lo que estamos buscando
end









































