
class CreateUsers < Sequel::Migration
  def up
    create_table :users do
      primary_key :id
      String  :screen_name
      String  :uid ,:unique => true
      String  :name
      varchar :description , :length => 500
      varchar :profile_image_url , :length => 500
      varchar :url , :length => 500
      integer :utc_offset
      String  :time_zone
      String  :location
      String  :location_conv
      integer :followers_count
      integer :friends_count
      integer :statuses_count
    end
    add_index :users, :screen_name
    add_index :users, :uid
    add_index :users, :location_conv
  end
end
class CreateCrawlStatuses < Sequel::Migration
  def up
    create_table :crawl_statuses do
      primary_key :id
      String  :status, :unique => true
      integer :uid
      integer :page
      integer :count
    end
    add_index :crawl_statuses, :status
  end
end
class CreateNewUsers < Sequel::Migration
  def up
    create_table :new_users do
      primary_key :id
      String :uid  ,:unique => true
      String :date
    end
    add_index :new_users, :date
    end
end
