require 'dump_conv_def'
require 'pstore'
class LocationConverter
  def initialize(path)
    @conv_cache_path = path 
    PStore.new(@conv_cache_path).transaction(true){|store|
      @cache = store[:cache]
      @del_cache = store[:del_cache]
    }
    @cache ||= {}
    @del_cache ||= {}
  end
  def convert(location)
    ret = @cache[location]
    return ret if ret
    REG_CONV_MAP.each{|m|
      if location =~ m[0]
        @cache[location] = m[1]
        puts "cache #{location} → #{m[1]}"
        return m[1]
      end
    }
    @cache[location] = ""
    puts "cache #{location} → "
    return ""
  end
  def need_delete?(location)
    return false
    del = @del_cache[location]
    return true if del
    DEL_CONV_MAP.each{|m|
      if location =~ m
        @del_cache[location] = true
        break
      end
      return true
    }
    false
  end
  def save
    PStore.new(@conv_cache_path).transaction{|store|
      store[:cache] = @cache
      store[:del_cache] = @del_cache
    }
  end
end
