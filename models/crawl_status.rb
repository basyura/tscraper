
class CrawlStatus < Sequel::Model
  set_dataset :crawl_statuses
  def save_next_user(next_uid)
      self.uid   = next_uid
      self.page  = 1
      self.count = 0
      self.save
  end
  def save_next_page
    self.page += 1
    self.count = 0
    self.save
  end
  def save_next_count
    self.count += 1
    self.save
  end
end
