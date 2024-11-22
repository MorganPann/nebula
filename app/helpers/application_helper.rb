module ApplicationHelper

  # Returns the Github callback URL based on the environment
  def github_url
    "https://github.com/login/oauth/authorize?client_id=#{Rails.application.credentials.CLIENT_ID}&redirect_uri=#{request.base_url}/github/callback"
  end

  def display_warning(message)
    "<i style='color: red'>#{message}</i>".html_safe
  end

  def humanize_url(url)
    url.split("/").last.split(".").first.humanize
  end

  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    str = "Artsdata"
    str += " DEV" if Rails.env.development?
    if page_title.present?
      str = "#{page_title} | #{str}"
    end
    str.html_safe
  end

  def og_meta_properties(og_title,og_image)
    og_properties = ''
    if og_title.present?
      og_properties += "<meta property='og:title' content='#{og_title}' />"
    end
    if og_image.present?
      og_properties += "<meta property='og:image' content='#{og_image}' />"
    end
    og_properties.html_safe
  end


  def use_prefix(uri)
    return if uri.blank?

    uri = uri.value if uri.class != String
    uri_compact = uri.gsub("http://schema.org/","schema:")
      .gsub("https://schema.org/","schemas:")
      .gsub("http://kg.artsdata.ca/resource/","ad:")
      .gsub("http://kg.footlight.io/resource/","footlight-console:")
      .gsub("http://lod.footlight.io/resource/","footlight-cms:")
      .gsub("http://www.w3.org/1999/02/22-rdf-syntax-ns#","rdf:")
      .gsub("http://www.w3.org/2000/01/rdf-schema#","rdfs:")
      .gsub("http://www.w3.org/2002/07/owl#","owl:")
      .gsub("http://www.w3.org/2004/02/skos/core#","skos:")
      .gsub("http://www.w3.org/ns/prov#","prov:")
      .gsub("http://kg.artsdata.ca/databus/","databus:")
      .gsub("http://www.w3.org/ns/shacl#","shacl:")
      .gsub("http://www.wikidata.org/entity/","wd:")
      .gsub("http://www.w3.org/2001/XMLSchema#", "xsd:")
      .gsub("http://scenepro.ca#","sp:")

    if uri_compact.present?
      return uri_compact
    else
      return uri
    end
  end

  def sparql_endpoint
    "#{Rails.application.credentials.graph_api_endpoint}/repositories/#{Rails.application.credentials.graph_repository}"
  end

  def artsdata_sparql_client
    SPARQL::Client.new(sparql_endpoint)
  end

  # sets a limit on the number of dereferences per table.
  # Note that derived statements are a separate table.
  # The offset is used to ensure that multiple tables have different frame_ids
  def auto_dereference(string)
    @max ||= 8
    if @frame_id
      @frame_id += 1 
      return false if @frame_id >  @offset +  @max
      return false if string.include?("wikidata.org")
    else
      @offset = rand(1000..9999)
      @frame_id = @offset
    end
    return true
  end

  # For UI portion of schema:Action
  def setup_action(s, p)
    @httpMethod = s.to_s if p.to_s == "http://schema.org/httpMethod"
    @httpBody = s.to_s if  p.to_s == "http://schema.org/httpBody"
    @url = s.to_s if  p.to_s == "http://schema.org/urlTemplate"
  end

  def generate_action_div
    if @url
      user_id = "https://github.com/#{session[:handle]}#this"
      <<-HTML.html_safe
        <div
          data-controller="githubapi"
          data-githubapi-token-value="#{session[:token]}"
          data-githubapi-url-value="#{@url}"
          data-githubapi-method-value="#{@httpMethod}"
          data-githubapi-httpbody-value="#{@httpBody.gsub('{{PublisherWebID}}',user_id)}"
        >
          <button
            data-githubapi-target="button"
            class="btn btn-danger m-3"
            data-action="githubapi#runAction"
          >Run Action</button>

          <p class="m-3" data-githubapi-target="result">
          </p>
        </div>
      HTML
    end
  end
        
    
end
