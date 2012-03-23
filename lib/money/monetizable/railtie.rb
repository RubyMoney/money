module Monetizable
  class Railtie < Rails::Railtie
    ActiveRecord::Base.send :include, Monetizable
  end
end
