module RelationshipsHelper
  def relationship_to_unfollow
    current_user.active_relationships.find_by followed_id: @user.id
  end
end
