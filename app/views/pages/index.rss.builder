xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Giwiki - Páginas Recentes"
    xml.description "Novas páginas adicionada ao wiki"
    xml.link root_url()

                @pages.each do |page|
                        f = File.new(REPOS_ROOT + '/' + page.title, "r")
                        xml.item do
                                xml.title page.title
                                xml.description page.html_body
                                xml.pubData f.stat.mtime.to_s(:rfc822)
                                xml.link page_url(page)
        xml.guid page_url(page)
                        end
                end
  end
end
