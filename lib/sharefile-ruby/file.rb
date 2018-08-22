module SharefileRuby
  class File
    attr_accessor :id, :authid, :subdomain,
                  :type,
                  :filename,
                  :displayname,
                  :size,
                  :creationdate,
                  :creatorfname,
                  :creatorlname,
                  :description,
                  :descriptionhtml,
                  :expirationdate,
                  :parentid,
                  :parentname,
                  :parent,
                  :grandparent,
                  :url,
                  :previewstatus,
                  :virusstatus,
                  :md5,
                  :thumb75,
                  :thumb600,
                  :creatorid,
                  :streamid,
                  :zoneid

    def initialize(id, authid, subdomain, item=nil)
      @id = id
      @authid = authid
      @subdomain = subdomain

      return unless id.present?

      if item == nil
        item = getex  #get attributes from item to avoid an extra API call
      end
      @type             = item["type"]
      @filename         = item["filename"]
      @displayname      = item["displayname"]
      @size             = item["size"]
      @creationdate     = item["creationdate"]
      @creatorfname     = item["creatorfname"]
      @creatorlname     = item["creatorlname"]
      @description      = item["description"]
      @descriptionhtml  = item["descriptionhtml"]
      @expirationdate   = item["expirationdate"]
      @parentid         = item["parentid"]
      @parentname       = item["parentname"]
      @url              = item["url"]
      @previewstatus    = item["previewstatus"]
      @virusstatus      = item["virusstatus"]
      @md5              = item["md5"]
      @thumb75          = item["thumb75"]
      @thumb600         = item["thumb600"]
      @creatorid        = item["creatorid"]
      @streamid         = item["streamid"]
      @zoneid           = item["zoneid"]

      @parent = Folder.new(@parentid, @authid, @subdomain)
      @parent.fetch_parent
      @grandparent = @parent.parent
    end

    # (not implemented) Generates a public link for download.
    def getlink(requireuserinfo=false,expirationdays=30,notifyondownload=false, maxdownloads=-1)
    end

    # Removes a file from the system. Files can be recovered within 7 days, but not currently through the API.
    def delete
      url = prefix + "delete"
      return response(url)
    end

    # Passing the required "name" parameter will change a files name to what is passed.
    def rename(name)
      url = prefix + "rename&name=#{name}"
      return response(url)
    end

    # Passing the required parameters will create the file in the specified folder AFTER the upload has completed.
    # Since a file cannot exist without a physical file uploaded, if the upload fails or is cancelled before all
    # data has been transferred to ShareFile, this file will not exist. "filename" must include the extension.
    def upload(file, folderid=nil, name=nil, unzip=true, overwrite=false, details=nil)
      url = (prefix + "upload&folderid=#{folderid}&filename=#{name}&unzip=#{unzip}&overwrite=#{overwrite}")
      upload_uri = response(url)

      multipart_upload(file, upload_uri, name)
    end

    def multipart_upload(tmpfile, url, name = nil)
      newline = "\r\n"
      filename = name || ::File.basename(tmpfile.path)
      boundary = "ClientTouchReceive----------#{Time.now.usec}"

      uri = URI.parse(url)

      post_body = []
      post_body << "--#{boundary}#{newline}"
      post_body << "Content-Disposition: form-data; name=\"File1\"; filename=\"#{filename}\"#{newline}"
      post_body << "Content-Type: application/octet-stream#{newline}"
      post_body << "#{newline}"
      post_body << ::File.read(tmpfile.path)
      post_body << "#{newline}--#{boundary}--#{newline}"

      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = post_body.join
      request["Content-Type"] = "multipart/form-data, boundary=#{boundary}"
      request['Content-Length'] = request.body().length

      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      http.request request
    end

    # Returns a direct link to download the file.
    def download(save_path="")
      url = prefix + "download"
      r = response(url)
      if r.class == String #success
        open(::File.join(save_path,@filename), "wb").write(open(r).read)
        return r
      else #failed
        return r
      end
    end

  protected

    # Returns all metadata of the requested file id.
    def get
      url = prefix + "get"
      return response(url)
    end

    # Returns additional data for the requested file.
    def getex
      url = prefix + "getex"
      return response(url)
    end

    def prefix
      "https://#{@subdomain}.sharefile.com/rest/file.aspx?fmt=json&authid=#{@authid}&id=#{@id}&op="
    end

    def response(url)
      r = JSON.parse(open(url).read)
      if r["error"] == false
        return r["value"]
      else
        return r
      end
    end

  end
end
