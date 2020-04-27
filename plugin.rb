# frozen_string_literal: true

# name: discourse-knowledge-explorer
# about: A plugin to make it easy to explore and find knowledge base-type articles in Discourse
# version: 0.1
# author: Justin DiRose

enabled_site_setting :knowledge_explorer_enabled

register_asset 'stylesheets/common/knowledge-explorer.scss'
register_asset 'stylesheets/mobile/knowledge-explorer.scss'

load File.expand_path('lib/knowledge_explorer/engine.rb', __dir__)
load File.expand_path('lib/knowledge_explorer/query.rb', __dir__)

after_initialize do
  require_dependency 'search'

    if Search.respond_to? :advanced_filter
      Search.advanced_filter(/^\-user:(.+)$/) do |posts, match|
	user_id = User.where(staged: false).where('username_lower = ? OR id = ?', match.downcase, match.to_i).pluck_first(:id)
    	if user_id
      		posts.where("posts.user_id <> #{user_id}")
    	else
      		posts.where("1 = 0")
    	end      
     end
   end
end