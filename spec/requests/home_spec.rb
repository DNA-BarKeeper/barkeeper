require 'spec_helper'

describe "Home Pages" do

subject { page }

  describe "About Page" do

    before { visit root_path }

    it {should have_content('GBOL5')}

    it {should have_title(full_title(''))}

    it {should_not have_title("| About")}

  end

  describe 'Search Page' do

    before { visit search_path }

    it {should have_content('Overview')}

    it {should have_title('GBOL5 web app | Overview')}

  end


  describe "Help page" do

    before { visit help_path }

    it {should have_text('me')}


    it {should have_title("GBOL5 web app | Help")}

  end

  describe "Contact page" do

    before { visit contact_path }

    it { should have_content('Contact')}


    it {should have_title("GBOL5 web app | Contact")}

  end

end
