class AddMainLogoIdToHomes < ActiveRecord::Migration[5.2]
  def change
    add_reference :homes, :main_logo, references: :logos, index: true
    add_foreign_key :homes, :logos, column: :main_logo_id
  end
end
