namespace :data do
  desc "create users"

  task :create_users => :environment do




    @user = User.new(:name => 'Michelle Thönnes', :email => 'michelle.thoennes@uni-muenster.de', :password => '8TZPzm7MvhviCE', :password_confirmation => '8TZPzm7MvhviCE')
    @user.save

    puts "Done."

  end

end