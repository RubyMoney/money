begin
  require 'sixarm_ruby_unaccent'
rescue LoadError
  raise 'Money gem doesnt install sixarm_ruby_unaccent by default. ' \
    'Add it to your gemfile if you use Currency.analyze'
end

# Overwrites unaccent method of sixarm_ruby_unaccent.
class String
  def unaccent
    accentmap = ACCENTMAP
    accentmap.delete("\u{0142}") # Delete ł symbol from ACCENTMAP used in PLN currency
    accentmap.delete("\u{010D}") # Delete č symbol from ACCENTMAP used in CZK currency
    accentmap.delete("\u{FDFC}") # Delete ﷼ symbol from ACCENTMAP used in IRR, SAR and YER currencies
    accentmap.delete("\u{20A8}") # Delete ₨ symbol from ACCENTMAP used in INR, LKR, MUR, NPR, PKR and SCR currencies
    split(//u).map {|c| accentmap[c] || c }.join("")
  end
end
