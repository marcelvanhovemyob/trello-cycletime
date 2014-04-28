class TrelloCredentials 
	attr_reader :public_key, :access_token

	def initialize(public_key, access_token)
		@public_key = public_key
		@access_token = access_token
	end
end