require "coveralls"
Coveralls.wear!

$LOAD_PATH.unshift File.dirname(__FILE__)
require "rspec"
require "money"

require "r18n-core"

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

I18n.enforce_available_locales = false

RSpec.configure do |c|
  c.order = :random
  c.filter_run :focus
  c.run_all_when_everything_filtered = true
end

RSpec.shared_context 'with i18n locale backend', :i18n do
  around do |example|
    Money.locale_backend = :i18n

    example.run

    Money.locale_backend = :legacy
    I18n.backend = I18n::Backend::Simple.new
    I18n.locale = :en
  end
end

RSpec.shared_context 'with infinite precision', :infinite_precision do
  before { Money.infinite_precision = true }
  after { Money.infinite_precision = false }
end
