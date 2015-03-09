namespace :data do
  desc "create users"

  task :create_users => :environment do



    @user = User.new(:name => 'Samantha Seabrook-Sturgis', :email => 'sseabrooksturgis@gmail.com', :password => 'wAQDvdjGF2UuL4', :password_confirmation => 'wAQDvdjGF2UuL4')
    @user.save

    @user = User.new(:name => 'Claudia Schütte', :email => 'claudia.schuette@uni-bonn.de', :password => 'fh2oaqsPJQznG3', :password_confirmation => 'fh2oaqsPJQznG3')
    @user.save

    @user = User.new(:name => 'Martin Nebel', :email => 'martin.nebel@smns-bw.de', :password => 'ZufE7b2XyQXdmv', :password_confirmation => 'ZufE7b2XyQXdmv')
    @user.save

    @user = User.new(:name => 'Marcus Lehnert', :email => 'mlehnert@uni-bonn.de', :password => '9VeaxL3uwXQkKc', :password_confirmation => '9VeaxL3uwXQkKc')
    @user.save

    @user = User.new(:name => 'Bernadette Große-Veldmann', :email => 'b.grosse-veldmann@uni-bonn.de', :password => 'wMPBRA2KaudvG3', :password_confirmation => 'wMPBRA2KaudvG3')
    @user.save

    @user = User.new(:name => 'Sofia Paraskevopoulou', :email => 'sofiapara@uni-bonn.de', :password => 'xKKK62bthDAxtW', :password_confirmation => 'xKKK62bthDAxtW')
    @user.save

    puts "Done."

  end

end