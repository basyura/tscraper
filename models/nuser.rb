
class NUser < Sequel::Model
  set_dataset :new_users
  def self.users(date , limit , offset)
    list = []
    filter(:date => date).limit(limit , offset).order(:id.desc).each{|nu|
      list << User.find(:uid => nu.uid)
    }
    list
  end
end
