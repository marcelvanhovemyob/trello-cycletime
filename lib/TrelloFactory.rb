require 'trello'

class TrelloFactory 
	include Trello
	include Trello::Authorization
	
	def create(trello_credentials)
		Trello::Authorization.const_set :AuthPolicy, OAuthPolicy
		OAuthPolicy.consumer_credential = OAuthCredential.new trello_credentials.public_key, 'SECRET'
		OAuthPolicy.token = OAuthCredential.new trello_credentials.access_token, nil
	end
end