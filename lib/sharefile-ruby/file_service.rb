module SharefileRuby
  class FileService

    attr_accessor :root_folder, :subdomain, :email, :password, :authid, :current_folder_id, :root_id

    def initialize(subdomain,email,password)
      @subdomain = subdomain
      @email = email
      @password = password
      auth_url = "https://#{@subdomain}.sharefile.com/rest/getAuthID.aspx?username=#{@email}&password=#{@password}&fmt=json"
      response = JSON.parse(open(auth_url).read)
      if response["error"] == false
        @authid = response["value"]
      else
        print "auth error: #{response}"
        return
      end
      root_id_url = "https://#{@subdomain}.sharefile.com/rest/folder.aspx?op=get&authid=#{@authid}&path=/&fmt=json"
      @root_id = JSON.parse(open(root_id_url).read)["value"]
      @root_folder = Folder.new(@root_id, @authid, @subdomain)
    end

    # Returns a list of Folder and File objects.
    def search(q)
      results = []
      url = "https://#{@subdomain}.sharefile.com/rest/search.aspx?op=search&query=#{q}&authid=#{@authid}&fmt=json"
      response = JSON.parse(open(url).read)
      if response["error"] == false #success
        response["value"].each do |item|
          if item["type"] == "folder"
            results << Folder.new(item["id"], @authid, @subdomain, false, item)
          elsif item["type"] == "file"
            results << File.new(item["id"], @authid, @subdomain, item)
          end
        end
        return results
      else #error
        return response
      end
    end

    # Returns a list of all the account employees.
    def employees
      emps = []
      url = prefix + "liste"
      users = response(url)
      if users.class == Array #success
        users.each do |u|
          emps << User.new(u["id"], @authid, @subdomain)
        end
        return emps
      else #failed
        return users
      end
    end

    # Returns a list of all the account clients.
    def clients
      clis = []
      url = prefix + "listc"
      users = response(url)
      if users.class == Array #success
        users.each do |u|
          clis << User.new(u["id"], @authid, @subdomain, u)
        end
        return clis
      else #failed
        return users
      end
    end

    def prefix
      "https://#{@subdomain}.sharefile.com/rest/users.aspx?fmt=json&authid=#{@authid}&op="
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
