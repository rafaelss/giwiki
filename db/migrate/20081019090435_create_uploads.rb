class CreateUploads < ActiveRecord::Migration
  def self.up
    create_table :uploads do |t|
      t.string :title
      t.string :upload_file_name
      t.string :upload_content_type
      t.integer :upload_file_size
      t.string :tags
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :uploads
  end
end
