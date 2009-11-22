require 'pstore'
class Cache
  PATH = "tmp/cache.store"
  def self.put(key , value)
    cache.transaction {|store| store[key] = value }
  end
  def self.get(key)
    cache.transaction(true) {|store| store[key] }
  end
  private
  def self.cache
    @cache = PStore.new(PATH) unless @cache
    if Time.now - File.stat(PATH).mtime > 60 * 60
      @cache.transaction {|store|
        store.roots.each{|key| @cache[key] = nil}
      }
    end
    @cache
  end
end
