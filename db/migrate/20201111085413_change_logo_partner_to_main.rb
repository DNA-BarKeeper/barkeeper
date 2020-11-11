class ChangeLogoPartnerToMain < ActiveRecord::Migration[5.2]
  def change
    rename_column :logos, :partner, :main
  end
end
