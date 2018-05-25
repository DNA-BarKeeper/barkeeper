module ProjectConcern
  extend ActiveSupport::Concern

  def current_project_id
    user_signed_in? ? current_user.default_project_id : Project.where('name like ?', "All%").first.id
  end
end