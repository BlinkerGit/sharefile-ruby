module SharefileRuby
  class Folder
    attr_accessor :id, :authid, :subdomain,
                  :children,
                  :parent,
                  :grandparent,
                  :parentid,
                  :parentname,
                  :grandparentid,
                  :type,
                  :displayname,
                  :size,
                  :creatorname,
                  :zoneid,
                  :canupload,
                  :candownload,
                  :candelete,
                  :creationdate,
                  :filename,
                  :details,
                  :creatorid,
                  :creatorfname,
                  :creatorlname,
                  :description,
                  :expirationdate,
                  :filecount,
                  :progenyeditdate,
                  :streamid,
                  :commentcount,
                  :isfavorite,
                  :ispinned,
                  :ispersonal


    def initialize(id, authid, subdomain, include_children=false, item=nil)
      @id = id
      @authid = authid
      @subdomain = subdomain
      @children = []

      item = getex if item == nil #get attributes from item to avoid an extra API call

      @parentid        = item["parentid"]
      @parentname      = item["parentname"]
      @grandparentid   = item["grandparentid"]
      @type            = item["type"]
      @displayname     = item["displayname"]
      @size            = item["size"]
      @creatorname     = item["creatorname"]
      @zoneid          = item["zoneid"]
      @canupload       = item["canupload"]
      @candownload     = item["candownload"]
      @candelete       = item["candelete"]
      @creationdate    = item["creationdate"]
      @filename        = item["filename"]
      @details         = item["details"]
      @creatorid       = item["creatorid"]
      @creatorfname    = item["creatorfname"]
      @creatorlname    = item["creatorlname"]
      @description     = item["description"]
      @expirationdate  = item["expirationdate"]
      @filecount       = item["filecount"]
      @progenyeditdate = item["progenyeditdate"]
      @streamid        = item["streamid"]
      @commentcount    = item["commentcount"]
      @isfavorite      = item["isfavorite"]
      @ispinned        = item["ispinned"]
      @ispersonal      = item["ispersonal"]

      fetch_children if include_children
    end

    # Passing the required "name" parameter creates a folder with this name. Optionally, passing an "overwrite" parameter as true/false, will overwrite an existing folder if true.
    def create(name)
      url = prefix + "create" + "&name=#{name}"
      return response(url)
    end

    # Deletes a folder given the passed in "id" parameter and all children of this folder.
    def delete
      url = prefix + "delete"
      return response(url)
    end

    # Passing the required "name" parameter will change a folders name to what is passed.
    def rename(name)
      url = prefix + "rename&name=#{name}"
      return response(url)
    end

    def upload(file, name=nil, unzip=true, overwrite=false, details=nil)
      f = File.new(nil, authid, subdomain)

      f.upload(file, id, name, unzip, overwrite, details)
    end

    # (not implemented) Calling this function will return a link directly to a specified folder given the "id" parameter of a folder.
    def request_url(requirelogin=false, requireuserinfo=false, expirationdays=30, notifyonupload=false)
    end

    # (not implemented) Grants folder privileges to the given user.
    def grant(userid=nil, email=nil, download=true, upload=false, view=true, admin=false, delete=false, notifyupload=false, notifydownload=false) #(userid OR email) required
    end

    # (not implemented) Revokes folder privileges from the given user
    def revoke(userid=nil, email=nil) #(userid OR email) required
    end

    # Returns a permission list for the given folder.
    def getacl
      url = prefix + "getacl"
      return response(url)
    end

    # populates Folder.children list. Can be done at initialize using include_children=true
    def fetch_children
      @children = []
      for item in self.listex
        if item["type"] == "folder" and item["id"]!=@id #sharefile API includes self in list
          @children << Folder.new(item["id"], @authid, @subdomain, false, item)
        elsif item["type"] == "file"
          @children << File.new(item["id"], @authid, @subdomain, item)
        end
      end
    end

    def fetch_parent
        @parent = Folder.new(@parentid, @authid, @subdomain)
    end

    def fetch_grandparent
        @grandparent = Folder.new(@grandparentid, @authid, @subdomain)
    end

  protected

    def prefix
      "https://#{@subdomain}.sharefile.com/rest/folder.aspx?fmt=json&authid=#{@authid}&id=#{@id}&op="
    end

    def response(url)
      r = JSON.parse(open(url).read)
      if r["error"] == false
        return r["value"]
      else
        return r
      end
    end

    # Returns a list of all sub-folders and files in the current folder with additional information.
    def listex
      url = prefix + "listex"
      return response(url)
    end

      # Returns a list of all sub-folders and files in the current folder
    def list
      url = prefix + "list"
      return response(url)
    end

    # Returns id of the current folder verifying it exists
    def get
      url = prefix + "get"
      return response(url)
    end

    # Returns all metadata of the requested folder id
    def getex
      url = prefix + "getex"
      return response(url)
    end

  end
end
