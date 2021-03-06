# name: discourse_user_negative_search
# about: Add negative user search to advanced search
# version: 0.2
# authors: Maxym Khaykin
# url: https://github.com/realmrmax/discourse_user_negative_search

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

  Search.advanced_filter(/^\-category:(.+)$/) do |posts, match|
    exact = false

    if match[0] == "="
      exact = true
      match = match[1..-1]
    end

    category_ids = Category.where('slug ilike ? OR name ilike ? OR id = ?',
                                  match, match, match.to_i).pluck(:id)
    if category_ids.present?

      unless exact
        category_ids +=
          Category.where('parent_category_id = ?', category_ids.first).pluck(:id)
      end

      @category_filter_matched ||= true
      posts.where("topics.category_id NOT IN (?)", category_ids)
    else
      posts.where("1 = 0")
    end
  end

   end
end