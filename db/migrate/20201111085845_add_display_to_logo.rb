class AddDisplayToLogo < ActiveRecord::Migration[5.2]
  def change
    add_column :logos, :display, :boolean, default: true
  end
end
