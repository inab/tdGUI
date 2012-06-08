require 'net/http'

class InnerProxy
	private
# Suppossed endpoints for coreApi
	CORE_API_URL_83 = "http://ops.few.vu.nl:9183/opsapi"
	CORE_API_URL_84 = "http://ops.few.vu.nl:9184/opsapi"
	CORE_API_URL_85 = "http://ops.few.vu.nl:9185/opsapi"
	CORE_API_URL_86 = "http://ops.few.vu.nl:9186/opsapi"
	CORE_API_URL_87 = "http://ops.few.vu.nl:9187/opsapi"

# URL for conceptwiki
	CONCEPT_WIKI_API_SEARCH_URL = "http://staging.conceptwiki.org/web-ws/concept/search/"

	TIMEOUT = 1.5 # arbitrary timeout to ping endpoints

	UNIPROT_PROTEIN_LOOKUP = 'http://www.uniprot.org/uniprot/?query=organism:9606+AND+xxxx&format=tab&columns=id,protein%20names,citation,comments,genes&sort=score'
	UNIPROT_PROTEIN_LOOKUP_SHORT = 'http://www.uniprot.org/uniprot/?format=tab&columns=id,protein%20names,citation,comments,genes&sort=score'
	UNIPROT_PROTEIN_INFO ='http://www.uniprot.org/uniprot/?query=xxxx&format=tab&columns=id,protein%20names,citation,comments,genes&sort=score'

	URL_FETCH_ENTRY = 'http://www.uniprot.org/uniprot/'


	public
	def initialize ()
		@coreApiEndpoints = [CORE_API_URL_83, CORE_API_URL_84, CORE_API_URL_85,
												 CORE_API_URL_86, CORE_API_URL_87]
		@coreApi_method = 'proteinInfo'
		@coreApi_uri = 'http://chem2bio2rdf.org/chembl/resource/chembl_targets/12261'
		@endpoint_ready = nil
		@coreEndpointsChecked = 0

		@requestErrMsg = ''

		@urlMap = {
			CONCEPT_WIKI_API_SEARCH_URL => UNIPROT_PROTEIN_LOOKUP_SHORT
		}

		@coreApiEndpoints.each { |endpoint|
			@urlMap[endpoint] = UNIPROT_PROTEIN_INFO
		}
	end


	def coreEndpointReady
		@endpoint_ready
#		UNIPROT_PROTEIN_LOOKUP_SHORT
	end


	def coreEndpointsChecked
		@coreEndpointsChecked
	end


# conceptWikiEP
# Returns the concept wiki search URI
	def conceptWikiEP
		CONCEPT_WIKI_API_SEARCH_URL
	end


# coreApiEP
# Returns one of the five supposed coreAPI endpoints. All of them are similar except for the port
	def coreApiEP
		CORE_API_URL_83
	end


# Checks the conceptWiki endpoint, which is different of the coreApi endpoint
	def checkConceptWiki ()
		# check to see if endpoint is responding
		#		api_method = 'proteinInfo'
		#		prot_uri = 'http://chem2bio2rdf.org/chembl/resource/chembl_targets/12261'
		prot_uri = CONCEPT_WIKI_API_SEARCH_URL
		options = Hash.new
		options[:limit] = 1
		options[:offset] = 0
		options[:q] = 'tp53' # default test

		url = URI.parse(prot_uri)
												 #		 url = checkEndpoints()
		result = nil
		Timeout::timeout (1.5) do
			result = request(url, options)
		end

		if result == nil || result < 0
			@endpoint_ready = @urlMap[CONCEPT_WIKI_API_SEARCH_URL]
			false
		else
			@endpoint_ready = CONCEPT_WIKI_API_SEARCH_URL
			true
		end
	end

# EO checkConcept...



	def checkCoreAPI ()
		options = Hash.new
		options[:uri] = '<' + @coreApi_uri + '>'
		options[:limit] = 1
		options[:offset] = 0
		options[:method] = @coreApi_method

		alive = 0
		@coreEndpointsChecked = 0
		@coreApiEndpoints.each do |endpoint|
			Timeout::timeout (1.5) do
				alive = request(endpoint, options)
				@coreEndpointsChecked += 1
			end

			if alive > 0 then
				@endpoint_ready = endpoint # any of them from 83 to 87
				break
			end
#  break alive if alive != -1 && alive != -2 && alive != -3
		end # EO loop on endopoints

		if alive == 0
			@endpoint_ready = @urlMap[CORE_API_URL_83]
		end
		alive > 0 ? true : false
	end

# EO checkCoreApi



# uniprot2json
# Converst the tabular response from uniprot into a json similar to OPS json
# [{match:..., concept_uuid:...,concept_url:...,define_url:...,concept_label:...,
#   concept_alt_labels:...,tag_uuid:...,tag_label:}, ..., {...}]
# @param uniprot_res, the tabular uniprot response
# @param query, the query which was input
# @return a json string ready to use with default OPS combo-protein-lookup comp
	def uniprot2json (uniprot_res, query)

#		lines = uniprot_res.body.split("\n")
		lines = uniprot_res.split("\n")
		json_str = '[{"source":"uniprot"},'
		if lines.length > 0
#			json_str = '{"items":['
			cont_lines = 0
			for line in lines
				#  tabs = line.split("\t")

				if cont_lines > 0
					json_str += row2json(line, query)
				end
				cont_lines += 1
				# print "jsonStr: #{jsonStr.slice(0, jsonStr.length-1)}"
			end
			json_str = json_str.slice(0, json_str.length-1) # remove last comma
		end # EO if

		json_str += "]"
	end



	private
# request (addrs, opts)
# Make a simple http request and returns the response code
	def request (addrs, opts)
=begin
			uri = URI.parse (addrs)
			myHttp = Net::HTTP.new(uri.host, uri.port)
			request = Net::HTTP::Post.new(uri.request_uri)
			request["Content-Type"] = "application/json"

			request.set_form_data(opts)
			response = Net::HTTP::post_form(uri, opts)
=end

		uri = URI.parse (addrs) rescue addrs
		response = Net::HTTP.post_form(uri == nil ? addrs : uri, opts)
		@requestErrMsg = "Request success"
		rescue Timeout::Error => exc
			@requestErrMsg = "ERROR: #{exc.message}"
			-1
		rescue Errno::ETIMEDOUT => exc
			@requestErrMsg = "ERROR: #{exc.message}"
			-2

		rescue Errno::ECONNREFUSED => exc
			@requestErrMsg = "ERROR: #{exc.message}"
			-3

		else
			#    puts "Response is..."
			#    puts response.code.to_i
			response.code.to_i
	end

# EO checkEndpoint


# Returns a json object from a line
# @param row, a row from a tab request from Uniprot, with the fields
# uniprotId, protein names, pumed ids, comments, genes
# @param query, the input query
# @return, a json object as string, comma-ended
	def row2json (row, query)
		str_json = '{"concept_uuid":"","concept_url":"","tag_uuid":"","tag_label":"",'
		counter = 0
		tabs = row.strip.split("\t")
		match = false # to have only ONE match

		for elem in tabs

#			match = elem.include? query
			new_elem = elem
			new_elem = new_elem.gsub(/(#{query})/i, '<b>\1</b>')
			if match == false && new_elem != elem
				str_json += '"match":"' + new_elem + '",'
				match = true
			end

			if counter == 0 # this is the entry
				str_json += '"define_url":"'+URL_FETCH_ENTRY + elem.strip()+'",'

			elsif counter == 1 # set of protein names, only the first one is got
				prot_names = elem.split ("(")
				str_json += '"concept_label":"'+prot_names[0]+'",'

			elsif counter == 4 # gene names
				genes = elem.split(" ")
				gene_str = ''
				genes.each { |gene|
					gene_str += gene +"; "
				}
				gene_str = gene_str.slice(0, gene_str.length-1)

				str_json += '"concept_alt_labels":"'+gene_str+'",'
			end
			counter += 1

		end # EO for ... in
		str_json = str_json.slice(0, str_json.length-1)+'},'
	end


end # EO class InnerProxy