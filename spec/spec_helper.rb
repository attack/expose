require 'rubygems'
require 'bundler'
Bundler.setup(:default, :development, :test)

require 'rails'
require 'active_record'
require 'expose'
require 'rspec'

root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3", 
  :database => "#{root}/spec/db/expose.db"
)

RSpec.configure do |config|
end

# create the table for the test in the database
ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'users'")
ActiveRecord::Base.connection.create_table(:users) do |t|
  t.string :name, :default => 'name'
  t.string :important, :default => 'important'
  t.string :sometimes_important, :default => 'sometimes_important'
  t.string :not_important, :default => 'not_important'
  t.string :state, :default => 'new'
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

