# frozen_string_literal: true

class CreateAdminService
  def call(projects)
    user = User.find_or_create_by!(email: Rails.application.secrets.admin_email) do |user|
      user.password = Rails.application.secrets.admin_password
      user.password_confirmation = Rails.application.secrets.admin_password
      user.name = Rails.application.secrets.admin_name
      user.role = 'admin'
      user.projects = projects
    end
  end
end
