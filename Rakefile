
task :default do
  puts "please confirm by rake -T"
end

desc "migrate db"
task "db:migrate" do
  require 'sequel'
  require 'sequel/extensions/migration'
  require 'yaml'
  puts "db migrate start"
  puts "load config.yaml"
  RConfig = YAML.load(open("config.yaml").read)
  puts "connect to " + RConfig["db"]
  DB = Sequel.sqlite(RConfig["db"])
  puts "migrate start"
  Sequel::Migrator.apply(DB, './db/migrate')
end
