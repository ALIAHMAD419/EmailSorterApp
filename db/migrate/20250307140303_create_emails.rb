class CreateEmails < ActiveRecord::Migration[7.2]
  def change
    create_table :emails do |t|
      t.string :subject
      t.text :body
      t.text :summary
      t.references :category, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :gmail_message_id

      t.timestamps
    end
  end
end
