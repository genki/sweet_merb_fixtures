# make sure we're running inside Merb
if defined?(Merb::Plugins)

  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:sweet_merb_fixtures] = {
    :auto_migrate => true
  }
  
  Merb::BootLoader.before_app_loads do
    # require code that must be loaded before the application
    Merb::Test.add_helpers do
      def sweet_fixtures(*names)
        Merb::Fixtures.load_fixture(*names)
      end
    end
  end
  
  Merb::BootLoader.after_app_loads do
    # code that can be required after the application loads
    require( :sweet_merb_fixtures / :merb_fixtures )
  end
  
  Merb::Plugins.add_rakefiles "sweet_merb_fixtures/merbtasks"

end
