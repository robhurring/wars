module Sinatra; module Helpers

  def h(text)
    Sanitize.clean(text)
  end

  def partial(name, locals = {})
    erb :"partials/_#{name}", :layout => false, :locals => locals
  end
  
  def format_number(num)
    num.to_s.gsub(/(\d)(?=\d{3}+(\.\d*)?$)/, '\1,')
  end  

  def debug(object)
    begin
      Marshal::dump(object)
      "<pre class='debug_dump'>#{object.to_yaml.gsub("  ", "&nbsp; ")}</pre>"
    rescue Exception => e
      "<code class='debug_dump'>#{object.inspect}</code>"
    end
  end
  
  def link_to(title, path, *args)
    options = args.extract_options!
    html_options = options.delete(:html) || {}

    "<a href='%s' %s>%s</a>" % [url_for(path, options), html_options.to_attributes, title]
  end

  def image_tag(path, *args)
    options = args.extract_options!
    path_options = options.delete(:path) || {}
    path = '/images/' + path

    "<img src='%s' %s/>" % [url_for(path, path_options), options.to_attributes]
  end

  def url_for(url_fragment, *args)
    options = args.extract_options!
    mode = options.delete(:mode) || :path_only

    unless url_fragment =~ /^http/
      case mode
      when :path_only
        base = request.script_name
      when :full
        scheme = request.scheme
        if (scheme == 'http' && request.port == 80 ||
            scheme == 'https' && request.port == 443)
          port = ""
        else
          port = ":#{request.port}"
        end
        base = "#{scheme}://#{request.host}#{port}#{request.script_name}"
      else
        raise TypeError, "Unknown url_for mode #{mode}"
      end
      url = "#{base}#{url_fragment}"
    else
      url = url_fragment
    end

    params = options.to_params
    params = '?' + params unless params.empty?
    "#{url}#{params}"
  end
    
end; end

# Core Extensions

class Array
  # from rails
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
  end
end

class Hash
  # from rails
  def stringify_keys
   inject({}) do |options, (key, value)|
     options[key.to_s] = value
     options
    end
  end
  
  def to_attributes
    stringify_keys.inject([]) do |m, pair|
      m << "%s='%s'" % pair
    end.join(' ')
  end
  
  # from merb
  def to_params
    params = ''
    stack = []

    each do |k, v|
      if v.is_a?(Hash)
        stack << [k,v]
      else
        params << "#{k}=#{v}&"
      end
    end

    stack.each do |parent, hash|
      hash.each do |k, v|
        if v.is_a?(Hash)
          stack << ["#{parent}[#{k}]", v]
        else
          params << "#{parent}[#{k}]=#{v}&"
        end
      end
    end

    params.chop! # trailing &
    params
  end
end