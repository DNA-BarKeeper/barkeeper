class AddCommentToIsolate < ActiveRecord::Migration
  def change
    add_column :isolates, :comment_orig, :text
    add_column :isolates, :comment_copy, :text
  end
end
