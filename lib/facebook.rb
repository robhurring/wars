require 'oauth2'
require 'httparty'

module Facebook
  GraphURI = 'https://graph.facebook.com'
  AuthFile = File.expand_path('../../config/facebook.yml', __FILE__)

  def self.auth_from_file
    return nil unless File.exist?(AuthFile)
    YAML.load_file AuthFile
  end

  def self.auth_from_env
    if ENV['WARS_FB_APP_ID'] && ENV['WARS_FB_SECRET']
      {:app_id => ENV['WARS_FB_APP_ID'], :secret => ENV['WARS_FB_SECRET']}
    end
  end
  
  def self.auth
    @auth ||= (auth_from_file || auth_from_env || nil)
  end
  
  def self.connectable?
    !auth.nil?
  end
  
  def self.client
    @client ||= OAuth2::Client.new(auth[:app_id], auth[:secret], :site => GraphURI)
  end
  
  class Graph
    include HTTParty
    base_uri GraphURI
    
    def self.post_to_wall(message, token)
      self.post '/me/feed', :body => {:message => message, :access_token => token}
    end    
  end
end