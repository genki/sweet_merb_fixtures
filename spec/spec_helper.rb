$:.push File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'merb-core'
require 'merb-core/plugins'
require "spec" # Satisfies Autotest and anyone else not using the Rake tasks

dependency "dm-core"
dependency "dm-aggregates"
dependency "dm-validations"

use_orm :datamapper
use_test :rspec
use_template_engine :erb

require "sweet_merb_fixtures"

Merb.disable(:initfile)
Merb.start_environment(
  :testing      => true,
  :adapter      => 'runner',
  :environment  => ENV['MERB_ENV'] || 'test',
  :merb_root    => File.dirname(__FILE__) / 'fixture',
  :log_file     => File.dirname(__FILE__) / '..' / "merb_test.log"
)
DataMapper.setup(:default, "sqlite3::memory:")

