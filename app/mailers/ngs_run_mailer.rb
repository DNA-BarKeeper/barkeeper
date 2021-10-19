class NgsRunMailer < ApplicationMailer
  default from: "notifications@#{ENV['PROJECT_DOMAIN']}"

  def request_submitted
    @user = params[:user]
    @ngs_run = params[:ngs_run]

    User.where(role: 'admin').each do |admin_user|
      mail(to: admin_user.email, subject: "NGS raw data analysis request by #{@user.name}") do |format|
        format.html
        format.text
      end
    end
  end
end
