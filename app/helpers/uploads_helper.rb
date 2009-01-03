module UploadsHelper
  def icon_path(upload)
    return "" if upload.upload_content_type.blank?

    if upload.upload_content_type.include?("image/")
      upload.upload.url(:thumb)
    else
      mimetypes = {
        :audio => [ "audio/" ],
        :doc   => [ "msword" ],
        :pdf   => [ "pdf" ],
        :video => [ "video/", "application/ogg" ],
        :zip   => [ "zip", "gzip", "x-compress", "x-gtar" ],
      }
      mimetypes.each do |image, content_type|
        content_type.each do |type|
          if upload.upload_content_type.include?(type)
            return "/images/icons/#{image}.png"
          end
        end
      end
      "/images/icons/default.png"
    end
  end

  def uploads_markdown_link(upload)
    return "" if upload.upload_content_type.blank?

    if upload.upload_content_type.include?("image/")
      "![#{upload.title}](#{upload.upload.url} \"#{upload.title}\")"
    else
      "[#{upload.title}](#{upload.upload.url} \"#{upload.title}\")"
    end
  end

end
