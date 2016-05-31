namespace :data do
  desc "create users"

  task :create_users => :environment do


    @user = User.new(:name => 'Tim Boehnert', :email => 'tim.boehnert@uni-bonn.de', :password => 'HMeWE98qRp3f', :password_confirmation => 'HMeWE98qRp3f')
    @user.save

    @user2 = User.new(:name => 'Saskia Schlesak', :email => 'saskia.schlesak@googlemail.com', :password => 'tJ6knF6q3DZX', :password_confirmation => 'tJ6knF6q3DZX')
    @user2.save

    @user3 = User.new(:name => 'Gabriele Droege', :email => 'G.Droege@bgbm.org', :password => 'T3HqXUd4zVA2', :password_confirmation => 'T3HqXUd4zVA2')
    @user3.save

    puts "Done."

  end

end