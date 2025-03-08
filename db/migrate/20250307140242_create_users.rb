class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :google_token
      t.string :google_refresh_token
      t.datetime :google_token_expires_at
      t.string :uid
      t.string :provider

      t.timestamps
    end
  end
end
