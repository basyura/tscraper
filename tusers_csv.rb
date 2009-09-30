
class TusersCSV
  def self.foreach(path)
    File.open(path).each{|f|
      yield f.split(",").map{|item| item.gsub('"' , "")}
    }
  end
end
