require 'bcrypt'

module Cyclid
  module Client
    # User related methods
    module User
      # Retrieve the list of users from a server
      def user_list
        uri = server_uri('/users')
        req = sign_request(Net::HTTP::Get.new(uri), uri)

        http = Net::HTTP.new(uri.hostname, uri.port)
        res = http.request(req)

        res_data = parse_response(res)
        @logger.debug res_data

        users = []
        res_data.each do |item|
          users << item['username']
        end

        return users
      end

      # Create a new user
      def user_add(username, email, password = nil, secret = nil)
        # Create the user object
        user = { 'username' => username, 'email' => email }

        # Add the HMAC secret if one was supplied
        user['secret'] = secret unless secret.nil?

        # Encrypt & add the password if one was supplied
        user['password'] = BCrypt::Password.create(password).to_s unless password.nil?

        @logger.debug user

        # Sign & send the request
        uri = server_uri('/users')

        unsigned = Net::HTTP::Post.new(uri)
        unsigned.content_type = 'application/json'
        unsigned.body = Oj.dump(user)

        req = sign_request(unsigned, uri)

        http = Net::HTTP.new(uri.hostname, uri.port)
        res = http.request(req)

        res_data = parse_response(res)
        @logger.debug res_data

        raise "Failed to create new user: #{res_data.message}" unless res.code == '200'
      end
    end
  end
end
