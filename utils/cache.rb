require 'pstore'
class Cache
  def self.put(key , value)
    cache.transaction {|store| store[key] = value }
  end
  def self.get(key)
    cache.transaction(true) {|store| store[key] }
  end
  private
  def self.cache
    return @cache if @cache
    path = Config["cache"]
    @cache = PStore.new(path) unless @cache
    if File.exist?(path) && Time.now - File.stat(path).mtime > 60 * 60
      @cache.transaction {|store|
        store.roots.each{|key| @cache[key] = nil}
      }
    end
    @cache
  end
end
