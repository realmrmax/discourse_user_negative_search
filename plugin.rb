# frozen_string_literal: true


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