xml.instruct!

xml.feed(:xmlns => "http://www.w3.org/2005/Atom", "xml:base" => @host) do
  xml.title("Chaos Computer Club Updates")
  xml.link(:href => "http://www.ccc.de/")
  xml.link(:rel => "self", :href => "#{@host}/rss/updates")
  xml.updated(@items.first.published_at.xmlschema)
  xml.author do
    xml.name("Chaos Computer Club e.V.")
  end
  xml.id("#{@host}/rss/updates")
  
  @items.each do |item|
    xml.entry do
      xml.title(item.title)
      xml.link(
        :href => "#{@host}/de/#{item.node.unique_name}",
        :rel  => "alternate",
        :type => "text/html"
      )
      xml.id("#{@host}/de/#{item.node.unique_name}")
      xml.updated(item.published_at.xmlschema)
      xml.content(:type => "xhtml") do
        xml.div(item.body, :xmlns => "http://www.w3.org/1999/xhtml")
      end
    end
    
  end
  
end