class CreateLogos < ActiveRecord::Migration[5.2]
  def change
    create_table :logos do |t|
      t.string :title
      t.string :url
      t.boolean :partner, default: true
      t.belongs_to :home
    end
  end
end
