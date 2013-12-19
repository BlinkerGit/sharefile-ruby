# using local certs to make SSL work
module Net
  class HTTP
    alias_method :original_use_ssl=, :use_ssl=

    def use_ssl=(flag)
      open('ca-bundle.crt', 'w') do |file|
        file << open("http://certifie.com/ca-bundle/ca-bundle.crt.txt").read
      end
      self.ca_file = 'ca-bundle.crt'
      self.verify_mode = OpenSSL::SSL::VERIFY_PEER
      self.original_use_ssl = flag
    end
  end
end
