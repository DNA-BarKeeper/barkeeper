namespace :data do
  desc "create users"

  task :create_users => :environment do


    @user = User.new(:name => '', :email => '', :password => '', :password_confirmation => '')
    @user.save

    puts "Done."

  end

end