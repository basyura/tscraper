
class NUser < Sequel::Model
  set_dataset :new_users
  def self.users(date)
    list = []
    filter(:date => date).order(:id.desc).each{|nu|
      list << User.find(:uid => nu.uid)
    }
    list
  end
end
