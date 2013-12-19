module SharefileRuby
  class User
    attr_accessor :authid, :subdomain, :id,
                  :firstname,
                  :lastname,
                  :name,
                  :shortname,
                  :accountid,
                  :virtualroot,
                  :primaryemail,
                  :company,
                  :accountemployee,
                  :accountadmin,
                  :canresetpassword,
                  :dateformat,
                  :requiredownloadlogin,
                  :canviewmysettings,
                  :zoneid,
                  :cancreaterootfolders,
                  :timezoneoffset,
                  :timeformat,
                  :longtimeformat,
                  :enableclientsend,
                  :canusefilebox,
                  :requirecompanyinfo,
                  :adminsso,
                  :lastanylogindt,
                  :lastweblogindt,
                  :canselectfolderzone,
                  :poisonpillinterval,
                  :canopenexternal,
                  :cancachefiles,
                  :cancachecredentials,
                  :isdisabled




    def initialize(id, authid, subdomain, item=nil)
      @id = id
      @authid = authid
      @subdomain = subdomain

      item = getex if item == nil # get attributes from item to avoid extra API call

      @firstname = item["firstname"]
      @lastname = item["lastname"]
      @name = item["name"]
      @shortname = item["shortname"]
      @accountid = item["accountid"]
      @virtualroot = item["virtualroot"]
      @primaryemail = item["primaryemail"]
      @company = item["company"]
      @accountemployee = item["accountemployee"]
      @accountadmin = item["accountadmin"]
      @canresetpassword = item["canresetpassword"]
      @dateformat = item["dateformat"]
      @requiredownloadlogin = item["requiredownloadlogin"]
      @canviewmysettings = item["canviewmysettings"]
      @zoneid = item["zoneid"]
      @cancreaterootfolders = item["cancreaterootfolders"]
      @timezoneoffset = item["timezoneoffset"]
      @timeformat = item["timeformat"]
      @longtimeformat = item["longtimeformat"]
      @enableclientsend = item["enableclientsend"]
      @canusefilebox = item["canusefilebox"]
      @requirecompanyinfo = item["requirecompanyinfo"]
      @adminsso = item["adminsso"]
      @lastanylogindt = item["lastanylogindt"]
      @lastweblogindt = item["lastweblogindt"]
      @canselectfolderzone = item["canselectfolderzone"]
      @poisonpillinterval = item["poisonpillinterval"]
      @canopenexternal = item["canopenexternal"]
      @cancachefiles = item["cancachefiles"]
      @cancachecredentials = item["cancachecredentials"]
      @isdisabled = item["isdisabled"]
    end

    # Calling this will delete the user completely from the system. Note: This operation may take several minutes depending on the number of associated folders the user is assigned to.
    def delete
      url = prefix + "delete" + id_param
      return response(url)
    end

    # Calling this will delete the user from all folders ONLY but not the system. Note: This operation may take several minutes depending on the number of associated folders the user is assigned to.
    def deletef
      url = prefix + "deletef" + id_param
      return response(url)
    end

    # Passing in the required parameters, a user is created in the system as either a client or an employee of the account.
    def User.create(subdomain, authid, firstname, lastname, email, isemployee=false, options={"company"=>nil, "createfolders"=>false, "usefilebox"=>false, "manageusers"=>false, "isadmin"=>false, "password"=>nil})
      prefix = "https://#{subdomain}.sharefile.com/rest/users.aspx?fmt=json&authid=#{authid}&op="

      option_params = ""
      options.each do |k,v|
        option_params += "&#{k}=#{v}"
      end
      url = prefix + "create&firstname=#{firstname}&lastname=#{lastname}&email=#{email}&isemployee=#{isemployee}" + option_params
      r = JSON.parse(open(url).read)
      if r["error"] == false
        return User.new(r["value"]["id"], authid, subdomain, r["value"])
      else
        print "create failed: #{r}"
        return r
      end
    end

    # (not implemented) Passing in the required parameters, a user is updated in the system. Other specific updates must be made to separate operators.
    def update(firstname, lastname, email=nil)
    end

    # (not implemented) Calling this will reset the specified users password.
    def resetp(oldp,newp,notify=false)
    end


    # Returns the user metadata.
    def get
      url = prefix + "get" + id_param
      return response(url)
    end

    # Returns additional information about the user.
    def getex
      url = prefix + "getex" + id_param
      return response(url)
    end

    def response(url)
      r = JSON.parse(open(url).read)
      if r["error"] == false
        return r["value"]
      else
        return r
      end
    end

    def prefix
      "https://#{@subdomain}.sharefile.com/rest/users.aspx?fmt=json&authid=#{@authid}&op="
    end

    def User.prefix
      "https://#{@subdomain}.sharefile.com/rest/users.aspx?fmt=json&authid=#{@authid}&op="
    end

    def id_param
      "&id=#{@id}"
    end

  end
end