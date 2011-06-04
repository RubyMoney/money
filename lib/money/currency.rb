# encoding: utf-8

class Money

  # Represents a specific currency unit.
  class Currency
    include Comparable

    # Thrown when an unknown currency is requested.
    class UnknownCurrency < StandardError; end

    # List of known currencies.
    #
    # == monetary unit
    # The standard unit of value of a currency, as the dollar in the United States or the peso in Mexico.
    # http://www.answers.com/topic/monetary-unit
    # == fractional monetary unit, subunit
    # A monetary unit that is valued at a fraction (usually one hundredth) of the basic monetary unit
    # http://www.answers.com/topic/fractional-monetary-unit-subunit
    #
    # See http://en.wikipedia.org/wiki/List_of_circulating_currencies and
    # http://search.cpan.org/~tnguyen/Locale-Currency-Format-1.28/Format.pm

    TABLE = {
      :aed => { :priority => 100, :iso_code => "AED", :name => "United Arab Emirates Dirham",               :symbol => "د.إ",           :subunit => "Fils",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :afn => { :priority => 100, :iso_code => "AFN", :name => "Afghan Afghani",                            :symbol => "؋",             :subunit => "Pul",           :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :all => { :priority => 100, :iso_code => "ALL", :name => "Albanian Lek",                              :symbol => "L",             :subunit => "Qintar",        :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :amd => { :priority => 100, :iso_code => "AMD", :name => "Armenian Dram",                             :symbol => "դր.",           :subunit => "Luma",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :ang => { :priority => 100, :iso_code => "ANG", :name => "Netherlands Antillean Gulden",              :symbol => "ƒ",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x0192;", :decimal_mark => ",", :thousands_separator => "."},
      :aoa => { :priority => 100, :iso_code => "AOA", :name => "Angolan Kwanza",                            :symbol => "Kz",            :subunit => "Cêntimo",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :ars => { :priority => 100, :iso_code => "ARS", :name => "Argentine Peso",                            :symbol => "$",             :subunit => "Centavo",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x20B1;", :decimal_mark => ",", :thousands_separator => "."},
      :aud => { :priority =>   4, :iso_code => "AUD", :name => "Australian Dollar",                         :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "$",        :decimal_mark => ".", :thousands_separator => ","},
      :awg => { :priority => 100, :iso_code => "AWG", :name => "Aruban Florin",                             :symbol => "ƒ",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "&#x0192;", :decimal_mark => ".", :thousands_separator => ","},
      :azn => { :priority => 100, :iso_code => "AZN", :name => "Azerbaijani Manat",                         :symbol => nil,             :subunit => "Qəpik",         :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :bam => { :priority => 100, :iso_code => "BAM", :name => "Bosnia and Herzegovina Convertible Mark",   :symbol => "KM or КМ",      :subunit => "Fening",        :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :bbd => { :priority => 100, :iso_code => "BBD", :name => "Barbadian Dollar",                          :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "$",       :decimal_mark => ".", :thousands_separator => ","},
      :bdt => { :priority => 100, :iso_code => "BDT", :name => "Bangladeshi Taka",                          :symbol => "৳",             :subunit => "Paisa",         :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :bgn => { :priority => 100, :iso_code => "BGN", :name => "Bulgarian Lev",                             :symbol => "лв",            :subunit => "Stotinka",      :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :bhd => { :priority => 100, :iso_code => "BHD", :name => "Bahraini Dinar",                            :symbol => "ب.د",           :subunit => "Fils",         :subunit_to_unit => 1000,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :bif => { :priority => 100, :iso_code => "BIF", :name => "Burundian Franc",                           :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :bmd => { :priority => 100, :iso_code => "BMD", :name => "Bermudian Dollar",                          :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "$",        :decimal_mark => ".", :thousands_separator => ","},
      :bnd => { :priority => 100, :iso_code => "BND", :name => "Brunei Dollar",                             :symbol => "$",             :subunit => "Sen",           :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "$",        :decimal_mark => ".", :thousands_separator => ","},
      :bob => { :priority => 100, :iso_code => "BOB", :name => "Bolivian Boliviano",                        :symbol => "Bs.",           :subunit => "Centavo",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :brl => { :priority => 100, :iso_code => "BRL", :name => "Brazilian Real",                            :symbol => "R$ ",            :subunit => "Centavo",      :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "R\$",      :decimal_mark => ",", :thousands_separator => "."},
      :bsd => { :priority => 100, :iso_code => "BSD", :name => "Bahamian Dollar",                           :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "$",        :decimal_mark => ".", :thousands_separator => ","},
      :btn => { :priority => 100, :iso_code => "BTN", :name => "Bhutanese Ngultrum",                        :symbol => nil,             :subunit => "Chertrum",      :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :bwp => { :priority => 100, :iso_code => "BWP", :name => "Botswana Pula",                             :symbol => "P",             :subunit => "Thebe",         :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :byr => { :priority => 100, :iso_code => "BYR", :name => "Belarusian Ruble",                          :symbol => "Br",            :subunit => "Kapyeyka",      :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :bzd => { :priority => 100, :iso_code => "BZD", :name => "Belize Dollar",                             :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "$",         :decimal_mark => ".", :thousands_separator => ","},
      :cad => { :priority =>   5, :iso_code => "CAD", :name => "Canadian Dollar",                           :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "$",         :decimal_mark => ".", :thousands_separator => ","},
      :cdf => { :priority => 100, :iso_code => "CDF", :name => "Congolese Franc",                           :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :chf => { :priority => 100, :iso_code => "CHF", :name => "Swiss Franc",                               :symbol => "Fr",            :subunit => "Rappen",        :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :clp => { :priority => 100, :iso_code => "CLP", :name => "Chilean Peso",                              :symbol => "$",             :subunit => "Peso",       :subunit_to_unit => 1,       :symbol_first => true, :html_entity => "&#x20B1;", :decimal_mark => ",", :thousands_separator => "."},
      :cny => { :priority => 100, :iso_code => "CNY", :name => "Chinese Renminbi Yuan",                     :symbol => "¥",             :subunit => "Fen",           :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x5713;", :decimal_mark => ".", :thousands_separator => ","},
      :cop => { :priority => 100, :iso_code => "COP", :name => "Colombian Peso",                            :symbol => "$",             :subunit => "Centavo",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x20B1;", :decimal_mark => ",", :thousands_separator => "."},
      :crc => { :priority => 100, :iso_code => "CRC", :name => "Costa Rican Colón",                         :symbol => "₡",             :subunit => "Céntimo",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x20A1;", :decimal_mark => ",", :thousands_separator => "."},
      :cuc => { :priority => 100, :iso_code => "CUC", :name => "Cuban Convertible Peso",                    :symbol => "$",             :subunit => "Centavo",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :cup => { :priority => 100, :iso_code => "CUP", :name => "Cuban Peso",                                :symbol => "$",             :subunit => "Centavo",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x20B1;", :decimal_mark => ".", :thousands_separator => ","},
      :cve => { :priority => 100, :iso_code => "CVE", :name => "Cape Verdean Escudo",                       :symbol => "$ or Esc",      :subunit => "Centavo",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :czk => { :priority => 100, :iso_code => "CZK", :name => "Czech Koruna",                              :symbol => "Kč",            :subunit => "Haléř",         :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ",", :thousands_separator => "."},
      :djf => { :priority => 100, :iso_code => "DJF", :name => "Djiboutian Franc",                          :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :dkk => { :priority => 100, :iso_code => "DKK", :name => "Danish Krone",                              :symbol => "kr",            :subunit => "Øre",           :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ",", :thousands_separator => "."},
      :dop => { :priority => 100, :iso_code => "DOP", :name => "Dominican Peso",                            :symbol => "$",             :subunit => "Centavo",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x20B1;", :decimal_mark => ".", :thousands_separator => ","},
      :dzd => { :priority => 100, :iso_code => "DZD", :name => "Algerian Dinar",                            :symbol => "د.ج",           :subunit => "Centime",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :eek => { :priority => 100, :iso_code => "EEK", :name => "Estonian Kroon",                            :symbol => "KR",            :subunit => "Sent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :egp => { :priority => 100, :iso_code => "EGP", :name => "Egyptian Pound",                            :symbol => "£ or ج.م",      :subunit => "Piastre",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x00A3;", :decimal_mark => ".", :thousands_separator => ","},
      :ern => { :priority => 100, :iso_code => "ERN", :name => "Eritrean Nakfa",                            :symbol => "Nfk",           :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :etb => { :priority => 100, :iso_code => "ETB", :name => "Ethiopian Birr",                            :symbol => nil,             :subunit => "Santim",        :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :eur => { :priority =>   2, :iso_code => "EUR", :name => "Euro",                                      :symbol => "€",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "&#x20AC;", :decimal_mark => ",", :thousands_separator => "."},
      :fjd => { :priority => 100, :iso_code => "FJD", :name => "Fijian Dollar",                             :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "$",        :decimal_mark => ".", :thousands_separator => ","},
      :fkp => { :priority => 100, :iso_code => "FKP", :name => "Falkland Pound",                            :symbol => "£",             :subunit => "Penny",         :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "&#x00A3;", :decimal_mark => ".", :thousands_separator => ","},
      :gbp => { :priority =>   3, :iso_code => "GBP", :name => "British Pound",                             :symbol => "£",             :subunit => "Penny",         :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x00A3;", :decimal_mark => ".", :thousands_separator => ","},
      :gel => { :priority => 100, :iso_code => "GEL", :name => "Georgian Lari",                             :symbol => "ლ",             :subunit => "Tetri",         :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :ghs => { :priority => 100, :iso_code => "GHS", :name => "Ghanaian Cedi",                             :symbol => "₵",             :subunit => "Pesewa",        :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x20B5;", :decimal_mark => ".", :thousands_separator => ","},
      :gip => { :priority => 100, :iso_code => "GIP", :name => "Gibraltar Pound",                           :symbol => "£",             :subunit => "Penny",         :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x00A3;", :decimal_mark => ".", :thousands_separator => ","},
      :gmd => { :priority => 100, :iso_code => "GMD", :name => "Gambian Dalasi",                            :symbol => "D",             :subunit => "Butut",         :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :gnf => { :priority => 100, :iso_code => "GNF", :name => "Guinean Franc",                             :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :gtq => { :priority => 100, :iso_code => "GTQ", :name => "Guatemalan Quetzal",                        :symbol => "Q",             :subunit => "Centavo",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :gyd => { :priority => 100, :iso_code => "GYD", :name => "Guyanese Dollar",                           :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "$",       :decimal_mark => ".", :thousands_separator => ","},
      :hkd => { :priority => 100, :iso_code => "HKD", :name => "Hong Kong Dollar",                          :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "$",       :decimal_mark => ".", :thousands_separator => ","},
      :hnl => { :priority => 100, :iso_code => "HNL", :name => "Honduran Lempira",                          :symbol => "L",             :subunit => "Centavo",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :hrk => { :priority => 100, :iso_code => "HRK", :name => "Croatian Kuna",                             :symbol => "kn",            :subunit => "Lipa",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ",", :thousands_separator => "."},
      :htg => { :priority => 100, :iso_code => "HTG", :name => "Haitian Gourde",                            :symbol => "G",             :subunit => "Centime",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :huf => { :priority => 100, :iso_code => "HUF", :name => "Hungarian Forint",                          :symbol => "Ft",            :subunit => "Fillér",        :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ",", :thousands_separator => "."},
      :idr => { :priority => 100, :iso_code => "IDR", :name => "Indonesian Rupiah",                         :symbol => "Rp",            :subunit => "Sen",           :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ",", :thousands_separator => "."},
      :ils => { :priority => 100, :iso_code => "ILS", :name => "Israeli New Sheqel",                        :symbol => "₪",             :subunit => "Agora",         :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x20AA;", :decimal_mark => ".", :thousands_separator => ","},
      :inr => { :priority => 100, :iso_code => "INR", :name => "Indian Rupee",                              :symbol => "₨",             :subunit => "Paisa",         :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x20A8;", :decimal_mark => ".", :thousands_separator => ","},
      :iqd => { :priority => 100, :iso_code => "IQD", :name => "Iraqi Dinar",                               :symbol => "ع.د",           :subunit => "Fils",          :subunit_to_unit => 1000, :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :irr => { :priority => 100, :iso_code => "IRR", :name => "Iranian Rial",                              :symbol => "﷼",             :subunit => "Dinar",         :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#xFDFC;", :decimal_mark => ".", :thousands_separator => ","},
      :isk => { :priority => 100, :iso_code => "ISK", :name => "Icelandic Króna",                           :symbol => "kr",            :subunit => "Eyrir",         :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ",", :thousands_separator => "."},
      :jmd => { :priority => 100, :iso_code => "JMD", :name => "Jamaican Dollar",                           :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "$",        :decimal_mark => ".", :thousands_separator => ","},
      :jod => { :priority => 100, :iso_code => "JOD", :name => "Jordanian Dinar",                           :symbol => "د.ا",           :subunit => "Piastre",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :jpy => { :priority =>   6, :iso_code => "JPY", :name => "Japanese Yen",                              :symbol => "¥",             :subunit => "Sen",           :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x00A5;", :decimal_mark => ".", :thousands_separator => ","},
      :kes => { :priority => 100, :iso_code => "KES", :name => "Kenyan Shilling",                           :symbol => "Sh",            :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :kgs => { :priority => 100, :iso_code => "KGS", :name => "Kyrgyzstani Som",                           :symbol => nil,             :subunit => "Tyiyn",         :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :khr => { :priority => 100, :iso_code => "KHR", :name => "Cambodian Riel",                            :symbol => "៛",             :subunit => "Sen",           :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "&#x17DB;", :decimal_mark => ".", :thousands_separator => ","},
      :kmf => { :priority => 100, :iso_code => "KMF", :name => "Comorian Franc",                            :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :kpw => { :priority => 100, :iso_code => "KPW", :name => "North Korean Won",                          :symbol => "₩",             :subunit => "Chŏn",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "&#x20A9;", :decimal_mark => ".", :thousands_separator => ","},
      :krw => { :priority => 100, :iso_code => "KRW", :name => "South Korean Won",                          :symbol => "₩",             :subunit => "Jeon",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x20A9;", :decimal_mark => ".", :thousands_separator => ","},
      :kwd => { :priority => 100, :iso_code => "KWD", :name => "Kuwaiti Dinar",                             :symbol => "د.ك",           :subunit => "Fils",         :subunit_to_unit => 1000,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :kyd => { :priority => 100, :iso_code => "KYD", :name => "Cayman Islands Dollar",                     :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "$",         :decimal_mark => ".", :thousands_separator => ","},
      :kzt => { :priority => 100, :iso_code => "KZT", :name => "Kazakhstani Tenge",                         :symbol => "〒",             :subunit => "Tiyn",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :lak => { :priority => 100, :iso_code => "LAK", :name => "Lao Kip",                                   :symbol => "₭",             :subunit => "Att",           :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "&#x20AD;", :decimal_mark => ".", :thousands_separator => ","},
      :lbp => { :priority => 100, :iso_code => "LBP", :name => "Lebanese Lira",                             :symbol => "ل.ل",           :subunit => "Piastre",      :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x00A3;", :decimal_mark => ".", :thousands_separator => ","},
      :lkr => { :priority => 100, :iso_code => "LKR", :name => "Sri Lankan Rupee",                          :symbol => "₨",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "&#x0BF9;", :decimal_mark => ".", :thousands_separator => ","},
      :lrd => { :priority => 100, :iso_code => "LRD", :name => "Liberian Dollar",                           :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "$",        :decimal_mark => ".", :thousands_separator => ","},
      :lsl => { :priority => 100, :iso_code => "LSL", :name => "Lesotho Loti",                              :symbol => "L",             :subunit => "Sente",         :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :ltl => { :priority => 100, :iso_code => "LTL", :name => "Lithuanian Litas",                          :symbol => "Lt",            :subunit => "Centas",        :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :lvl => { :priority => 100, :iso_code => "LVL", :name => "Latvian Lats",                              :symbol => "Ls",            :subunit => "Santīms",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :lyd => { :priority => 100, :iso_code => "LYD", :name => "Libyan Dinar",                              :symbol => "ل.د",           :subunit => "Dirham",       :subunit_to_unit => 1000,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :mad => { :priority => 100, :iso_code => "MAD", :name => "Moroccan Dirham",                           :symbol => "د.م.",          :subunit => "Centime",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :mdl => { :priority => 100, :iso_code => "MDL", :name => "Moldovan Leu",                              :symbol => "L",             :subunit => "Ban",           :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :mga => { :priority => 100, :iso_code => "MGA", :name => "Malagasy Ariary",                           :symbol => nil,             :subunit => "Iraimbilanja",  :subunit_to_unit => 5,    :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :mkd => { :priority => 100, :iso_code => "MKD", :name => "Macedonian Denar",                          :symbol => "ден",           :subunit => "Deni",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :mmk => { :priority => 100, :iso_code => "MMK", :name => "Myanmar Kyat",                              :symbol => "K",             :subunit => "Pya",           :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :mnt => { :priority => 100, :iso_code => "MNT", :name => "Mongolian Tögrög",                          :symbol => "₮",             :subunit => "Möngö",         :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "&#x20AE;", :decimal_mark => ".", :thousands_separator => ","},
      :mop => { :priority => 100, :iso_code => "MOP", :name => "Macanese Pataca",                           :symbol => "P",             :subunit => "Avo",           :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :mro => { :priority => 100, :iso_code => "MRO", :name => "Mauritanian Ouguiya",                       :symbol => "UM",            :subunit => "Khoums",        :subunit_to_unit => 5,    :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :mur => { :priority => 100, :iso_code => "MUR", :name => "Mauritian Rupee",                           :symbol => "₨",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x20A8;", :decimal_mark => ".", :thousands_separator => ","},
      :mvr => { :priority => 100, :iso_code => "MVR", :name => "Maldivian Rufiyaa",                         :symbol => "ރ.",            :subunit => "Laari",         :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :mwk => { :priority => 100, :iso_code => "MWK", :name => "Malawian Kwacha",                           :symbol => "MK",            :subunit => "Tambala",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :mxn => { :priority => 100, :iso_code => "MXN", :name => "Mexican Peso",                              :symbol => "$",             :subunit => "Centavo",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "$",        :decimal_mark => ".", :thousands_separator => ","},
      :myr => { :priority => 100, :iso_code => "MYR", :name => "Malaysian Ringgit",                         :symbol => "RM",            :subunit => "Sen",           :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :mzn => { :priority => 100, :iso_code => "MZN", :name => "Mozambican Metical",                        :symbol => "MTn",           :subunit => "Centavo",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ",", :thousands_separator => "."},
      :nad => { :priority => 100, :iso_code => "NAD", :name => "Namibian Dollar",                           :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "$",       :decimal_mark => ".", :thousands_separator => ","},
      :ngn => { :priority => 100, :iso_code => "NGN", :name => "Nigerian Naira",                            :symbol => "₦",             :subunit => "Kobo",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "&#x20A6;", :decimal_mark => ".", :thousands_separator => ","},
      :nio => { :priority => 100, :iso_code => "NIO", :name => "Nicaraguan Córdoba",                        :symbol => "C$",            :subunit => "Centavo",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :nok => { :priority => 100, :iso_code => "NOK", :name => "Norwegian Krone",                           :symbol => "kr",            :subunit => "Øre",           :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "kr",       :decimal_mark => ",", :thousands_separator => "."},
      :npr => { :priority => 100, :iso_code => "NPR", :name => "Nepalese Rupee",                            :symbol => "₨",             :subunit => "Paisa",         :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x20A8;", :decimal_mark => ".", :thousands_separator => ","},
      :nzd => { :priority => 100, :iso_code => "NZD", :name => "New Zealand Dollar",                        :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "$",        :decimal_mark => ".", :thousands_separator => ","},
      :omr => { :priority => 100, :iso_code => "OMR", :name => "Omani Rial",                                :symbol => "ر.ع.",          :subunit => "Baisa",        :subunit_to_unit => 1000,  :symbol_first => true, :html_entity => "&#xFDFC;", :decimal_mark => ".", :thousands_separator => ","},
      :pab => { :priority => 100, :iso_code => "PAB", :name => "Panamanian Balboa",                         :symbol => "B/.",           :subunit => "Centésimo",     :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :pen => { :priority => 100, :iso_code => "PEN", :name => "Peruvian Nuevo Sol",                        :symbol => "S/.",           :subunit => "Céntimo",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "S/.",      :decimal_mark => ".", :thousands_separator => ","},
      :pgk => { :priority => 100, :iso_code => "PGK", :name => "Papua New Guinean Kina",                    :symbol => "K",             :subunit => "Toea",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :php => { :priority => 100, :iso_code => "PHP", :name => "Philippine Peso",                           :symbol => "₱",             :subunit => "Centavo",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "&#x20B1;", :decimal_mark => ".", :thousands_separator => ","},
      :pkr => { :priority => 100, :iso_code => "PKR", :name => "Pakistani Rupee",                           :symbol => "₨",             :subunit => "Paisa",         :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x20A8;", :decimal_mark => ".", :thousands_separator => ","},
      :pln => { :priority => 100, :iso_code => "PLN", :name => "Polish Złoty",                              :symbol => "zł",            :subunit => "Grosz",         :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :pyg => { :priority => 100, :iso_code => "PYG", :name => "Paraguayan Guaraní",                        :symbol => "₲",             :subunit => "Céntimo",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x20B2;", :decimal_mark => ".", :thousands_separator => ","},
      :qar => { :priority => 100, :iso_code => "QAR", :name => "Qatari Riyal",                              :symbol => "ر.ق",           :subunit => "Dirham",        :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "&#xFDFC;", :decimal_mark => ".", :thousands_separator => ","},
      :ron => { :priority => 100, :iso_code => "RON", :name => "Romanian Leu",                              :symbol => "L",             :subunit => "Ban",           :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ",", :thousands_separator => "."},
      :rsd => { :priority => 100, :iso_code => "RSD", :name => "Serbian Dinar",                             :symbol => "din. or дин.",  :subunit => "Para",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :rub => { :priority => 100, :iso_code => "RUB", :name => "Russian Ruble",                             :symbol => "р.",            :subunit => "Kopek",         :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "&#x0440;&#x0443;&#x0431;", :decimal_mark => ",", :thousands_separator => "."},
      :rwf => { :priority => 100, :iso_code => "RWF", :name => "Rwandan Franc",                             :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :sar => { :priority => 100, :iso_code => "SAR", :name => "Saudi Riyal",                               :symbol => "ر.س",           :subunit => "Hallallah",    :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#xFDFC;", :decimal_mark => ".", :thousands_separator => ","},
      :sbd => { :priority => 100, :iso_code => "SBD", :name => "Solomon Islands Dollar",                    :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "$",        :decimal_mark => ".", :thousands_separator => ","},
      :scr => { :priority => 100, :iso_code => "SCR", :name => "Seychellois Rupee",                         :symbol => "₨",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "&#x20A8;", :decimal_mark => ".", :thousands_separator => ","},
      :sdg => { :priority => 100, :iso_code => "SDG", :name => "Sudanese Pound",                            :symbol => "£",             :subunit => "Piastre",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :sek => { :priority => 100, :iso_code => "SEK", :name => "Swedish Krona",                             :symbol => "kr",            :subunit => "Öre",           :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :sgd => { :priority => 100, :iso_code => "SGD", :name => "Singapore Dollar",                          :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "$",        :decimal_mark => ".", :thousands_separator => ","},
      :shp => { :priority => 100, :iso_code => "SHP", :name => "Saint Helenian Pound",                      :symbol => "£",             :subunit => "Penny",         :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "&#x00A3;", :decimal_mark => ".", :thousands_separator => ","},
      :skk => { :priority => 100, :iso_code => "SKK", :name => "Slovak Koruna",                             :symbol => "Sk",            :subunit => "Halier",        :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :sll => { :priority => 100, :iso_code => "SLL", :name => "Sierra Leonean Leone",                      :symbol => "Le",            :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :sos => { :priority => 100, :iso_code => "SOS", :name => "Somali Shilling",                           :symbol => "Sh",            :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :srd => { :priority => 100, :iso_code => "SRD", :name => "Surinamese Dollar",                         :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :std => { :priority => 100, :iso_code => "STD", :name => "São Tomé and Príncipe Dobra",               :symbol => "Db",            :subunit => "Cêntimo",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :svc => { :priority => 100, :iso_code => "SVC", :name => "Salvadoran Colón",                          :symbol => "₡",             :subunit => "Centavo",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x20A1;", :decimal_mark => ".", :thousands_separator => ","},
      :syp => { :priority => 100, :iso_code => "SYP", :name => "Syrian Pound",                              :symbol => "£ or ل.س",     :subunit => "Piastre",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "&#x00A3;", :decimal_mark => ".", :thousands_separator => ","},
      :szl => { :priority => 100, :iso_code => "SZL", :name => "Swazi Lilangeni",                           :symbol => "L",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :thb => { :priority => 100, :iso_code => "THB", :name => "Thai Baht",                                 :symbol => "฿",             :subunit => "Satang",        :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x0E3F;", :decimal_mark => ".", :thousands_separator => ","},
      :tjs => { :priority => 100, :iso_code => "TJS", :name => "Tajikistani Somoni",                        :symbol => "ЅМ",            :subunit => "Diram",         :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :tmm => { :priority => 100, :iso_code => "TMM", :name => "Turkmenistani Manat",                       :symbol => "m",             :subunit => "Tennesi",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :tnd => { :priority => 100, :iso_code => "TND", :name => "Tunisian Dinar",                            :symbol => "د.ت",           :subunit => "Millime",       :subunit_to_unit => 1000, :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :top => { :priority => 100, :iso_code => "TOP", :name => "Tongan Paʻanga",                            :symbol => "T$",            :subunit => "Seniti",        :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :try => { :priority => 100, :iso_code => "TRY", :name => "Turkish Lira",                              :symbol => "TL",            :subunit => "kuruş",         :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :ttd => { :priority => 100, :iso_code => "TTD", :name => "Trinidad and Tobago Dollar",                :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "$",        :decimal_mark => ".", :thousands_separator => ","},
      :twd => { :priority => 100, :iso_code => "TWD", :name => "New Taiwan Dollar",                         :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "$",        :decimal_mark => ".", :thousands_separator => ","},
      :tzs => { :priority => 100, :iso_code => "TZS", :name => "Tanzanian Shilling",                        :symbol => "Sh",            :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :uah => { :priority => 100, :iso_code => "UAH", :name => "Ukrainian Hryvnia",                         :symbol => "₴",             :subunit => "Kopiyka",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "&#x20B4", :decimal_mark => ".", :thousands_separator => ","},
      :ugx => { :priority => 100, :iso_code => "UGX", :name => "Ugandan Shilling",                          :symbol => "Sh",            :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :usd => { :priority =>   1, :iso_code => "USD", :name => "United States Dollar",                      :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "$",        :decimal_mark => ".", :thousands_separator => ","},
      :uyu => { :priority => 100, :iso_code => "UYU", :name => "Uruguayan Peso",                            :symbol => "$",             :subunit => "Centésimo",     :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x20B1;", :decimal_mark => ",", :thousands_separator => "."},
      :uzs => { :priority => 100, :iso_code => "UZS", :name => "Uzbekistani Som",                           :symbol => nil,             :subunit => "Tiyin",         :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :vef => { :priority => 100, :iso_code => "VEF", :name => "Venezuelan Bolívar",                        :symbol => "Bs F",          :subunit => "Céntimo",       :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "",         :decimal_mark => ",", :thousands_separator => "."},
      :vnd => { :priority => 100, :iso_code => "VND", :name => "Vietnamese Đồng",                           :symbol => "₫",             :subunit => "Hào",           :subunit_to_unit => 10,   :symbol_first => true, :html_entity => "&#x20AB;", :decimal_mark => ",", :thousands_separator => "."},
      :vuv => { :priority => 100, :iso_code => "VUV", :name => "Vanuatu Vatu",                              :symbol => "Vt",            :subunit => nil,             :subunit_to_unit => 1,    :symbol_first => true, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :wst => { :priority => 100, :iso_code => "WST", :name => "Samoan Tala",                               :symbol => "T",             :subunit => "Sene",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :xaf => { :priority => 100, :iso_code => "XAF", :name => "Central African Cfa Franc",                 :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :xcd => { :priority => 100, :iso_code => "XCD", :name => "East Caribbean Dollar",                     :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "$",        :decimal_mark => ".", :thousands_separator => ","},
      :xof => { :priority => 100, :iso_code => "XOF", :name => "West African Cfa Franc",                    :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :xpf => { :priority => 100, :iso_code => "XPF", :name => "Cfp Franc",                                 :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :yer => { :priority => 100, :iso_code => "YER", :name => "Yemeni Rial",                               :symbol => "﷼",             :subunit => "Fils",          :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "&#xFDFC;", :decimal_mark => ".", :thousands_separator => ","},
      :zar => { :priority => 100, :iso_code => "ZAR", :name => "South African Rand",                        :symbol => "R",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x0052;", :decimal_mark => ".", :thousands_separator => ","},
      :zmk => { :priority => 100, :iso_code => "ZMK", :name => "Zambian Kwacha",                            :symbol => "ZK",            :subunit => "Ngwee",         :subunit_to_unit => 100,  :symbol_first => false, :html_entity => "",         :decimal_mark => ".", :thousands_separator => ","},
      :zwd => { :priority => 100, :iso_code => "ZWD", :name => "Zimbabwean Dollar",                         :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "$",        :decimal_mark => ".", :thousands_separator => ","},

      # aliases for BC with documentation before Currency
      :yen => { :priority => 100, :iso_code => "JPY", :name => "Japanese Yen",                              :symbol => "¥",             :subunit => "Sen",           :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x00A5;", :decimal_mark => ".", :thousands_separator => ","},

      # kept for backwards compatibility, real entry is :ghs
      :ghc => { :priority => 100, :iso_code => "GHS", :name => "Ghanaian Cedi",                             :symbol => "₵",             :subunit => "Pesewa",        :subunit_to_unit => 100,  :symbol_first => true, :html_entity => "&#x20B5;", :decimal_mark => ".", :thousands_separator => ","  }
    }


    # The symbol used to identify the currency, usually the lowercase
    # +iso_code+ attribute.
    #
    # @return [Symbol]
    attr_reader :id

    # A numerical value you can use to sort/group the currency list.
    #
    # @return [Integer]
    attr_reader :priority

    # The international 3-letter code as defined by the ISO 4217 standard.
    #
    # @return [String]
    attr_reader :iso_code

    # The currency name.
    #
    # @return [String]
    attr_reader :name

    # The currency symbol (UTF-8 encoded).
    #
    # @return [String]
    attr_reader :symbol

    # The html entity for the currency symbol
    #
    # @return [String]
    attr_reader :html_entity

    # The name of the fractional monetary unit.
    #
    # @return [String]
    attr_reader :subunit

    # The proportion between the unit and the subunit
    #
    # @return [Integer]
    attr_reader :subunit_to_unit

    # The decimal mark, or character used to separate the whole unit from the subunit.
    #
    # @return [String]
    attr_reader :decimal_mark
    alias :separator :decimal_mark

    # The character used to separate thousands grouping of the whole unit.
    #
    # @return [String]
    attr_reader :thousands_separator
    alias :delimiter :thousands_separator 

    # Should the currency symbol precede the amount, or should it come after?
    #
    # @return [boolean]
    attr_reader :symbol_first

    def symbol_first?
      !!@symbol_first
    end

    # The number of decimal places needed.
    #
    # @return [Integer]
    def decimal_places
      if subunit_to_unit == 1
        0
      elsif subunit_to_unit % 10 == 0
        Math.log10(subunit_to_unit).to_s.to_i
      else
        Math.log10(subunit_to_unit).to_s.to_i+1
      end
    end

    # Create a new +Currency+ object.
    #
    # @param [String, Symbol, #to_s] id Used to look into +TABLE+ and retrieve
    #  the applicable attributes.
    #
    # @return [Money::Currency]
    #
    # @example
    #   Money::Currency.new(:usd) #=> #<Money::Currency id: usd ...>
    def initialize(id)
      @id  = id.to_s.downcase.to_sym
      data = TABLE[@id] || raise(UnknownCurrency, "Unknown currency `#{id}'")
      data.each_pair do |key, value|
        instance_variable_set(:"@#{key}", value)
      end
    end

    # Compares +self+ with +other_currency+ against the value of +priority+
    # attribute.
    #
    # @param [Money::Currency] other_currency The currency to compare to.
    #
    # @return [-1,0,1] -1 if less than, 0 is equal to, 1 if greater than
    #
    # @example
    #   c1 = Money::Currency.new(:usd)
    #   c2 = Money::Currency.new(:jpy)
    #   c1 <=> c2 #=> 1
    #   c2 <=> c1 #=> -1
    #   c1 <=> c1 #=> 0
    def <=>(other_currency)
      self.priority <=> other_currency.priority
    end

    # Compares +self+ with +other_currency+ and returns +true+ if the are the
    # same or if their +id+ attributes match.
    #
    # @param [Money::Currency] other_currency The currency to compare to.
    #
    # @return [Boolean]
    #
    # @example
    #   c1 = Money::Currency.new(:usd)
    #   c2 = Money::Currency.new(:jpy)
    #   c1 == c1 #=> true
    #   c1 == c2 #=> false
    def ==(other_currency)
      self.equal?(other_currency) ||
      self.id == other_currency.id
    end

    # Compares +self+ with +other_currency+ and returns +true+ if the are the
    # same or if their +id+ attributes match.
    #
    # @param [Money::Currency] other_currency The currency to compare to.
    #
    # @return [Boolean]
    #
    # @example
    #   c1 = Money::Currency.new(:usd)
    #   c2 = Money::Currency.new(:jpy)
    #   c1.eql? c1 #=> true
    #   c1.eql? c2 #=> false
    def eql?(other_currency)
      self == other_currency
    end

    # Returns a Fixnum hash value based on the +id+ attribute in order to use
    # functions like & (intersection), group_by, etc.
    #
    # @return [Fixnum]
    #
    # @example
    #   Money::Currency.new(:usd).hash #=> 428936
    def hash
      id.hash
    end

    # Returns a string representation corresponding to the upcase +id+
    # attribute.
    #
    # -–
    # DEV: id.to_s.upcase corresponds to iso_code but don't use ISO_CODE for consistency.
    #
    # @return [String]
    #
    # @example
    #   Money::Currency.new(:usd).to_s #=> "USD"
    #   Money::Currency.new(:eur).to_s #=> "EUR"
    def to_s
      id.to_s.upcase
    end

    # Conversation to +self+.
    #
    # @return [self]
    def to_currency
      self
    end

    # Returns a human readable representation.
    #
    # @return [String]
    #
    # @example
    #   Money::Currency.new(:usd) #=> #<Currency id: usd ...>
    def inspect
      "#<#{self.class.name} id: #{id}, priority: #{priority}, symbol_first: #{symbol_first}, thousands_separator: #{thousands_separator}, html_entity: #{html_entity}, decimal_mark: #{decimal_mark}, name: #{name}, symbol: #{symbol}, subunit_to_unit: #{subunit_to_unit}, iso_code: #{iso_code}, subunit: #{subunit}>"
    end

    # Class Methods
    class << self

      # Lookup a currency with given +id+ an returns a +Currency+ instance on
      # success, +nil+ otherwise.
      #
      # @param [String, Symbol, #to_s] id Used to look into +TABLE+ and
      # retrieve the applicable attributes.
      #
      # @return [Money::Currency]
      #
      # @example
      #   Money::Currency.find(:eur) #=> #<Money::Currency id: eur ...>
      #   Money::Currency.find(:foo) #=> nil
      def find(id)
        id = id.to_s.downcase.to_sym
        new(id) if self::TABLE[id]
      end

      # Wraps the object in a +Currency+ unless it's already a +Currency+
      # object.
      #
      # @param [Object] object The object to attempt and wrap as a +Currency+
      # object.
      #
      # @return [Money::Currency]
      #
      # @example
      #   c1 = Money::Currency.new(:usd)
      #   Money::Currency.wrap(nil)   #=> nil
      #   Money::Currency.wrap(c1)    #=> #<Money::Currency id: usd ...>
      #   Money::Currency.wrap("usd") #=> #<Money::Currency id: usd ...>
      def wrap(object)
        if object.nil?
          nil
        elsif object.is_a?(Currency)
          object
        else
          Currency.new(object)
        end
      end
    end
  end
end
