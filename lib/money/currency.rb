# encoding: utf-8

class Money

  # Represents a specific currency unit.
  class Currency
    include Comparable

    class UnknownCurrency < StandardError; end

    # List of attributes applicable to a currency object.
    #  * priority: a numerical value you can use to sort/group the currency list
    #  * iso_code: the international 3-letter code as defined by the ISO 4217 standard
    #  * name: the currency name
    #  * symbol: the currency symbol (UTF-8 encoded)
    #  * subunit: the name of the fractional monetary unit
    #  * subunit_to_unit: the proportion between the unit and the subunit
    ATTRIBUTES = [ :priority, :iso_code, :name, :symbol, :subunit, :subunit_to_unit, :separator ]

    TABLE = {
      # monetary unit
      #   The standard unit of value of a currency, as the dollar in the United States or the peso in Mexico.
      #   http://www.answers.com/topic/monetary-unit
      # fractional monetary unit, subunit
      #   A monetary unit that is valued at a fraction (usually one hundredth) of the basic monetary unit
      #   http://www.answers.com/topic/fractional-monetary-unit-subunit
      #
      # See http://en.wikipedia.org/wiki/List_of_circulating_currencies
      :aed => { :priority => 100, :iso_code => "AED", :name => "United Arab Emirates Dirham",               :symbol => "د.إ",           :subunit => "Fils",          :subunit_to_unit => 100, :separator => "."   },
      :afn => { :priority => 100, :iso_code => "AFN", :name => "Afghan Afghani",                            :symbol => "؋",             :subunit => "Pul",           :subunit_to_unit => 100, :separator => "."   },
      :all => { :priority => 100, :iso_code => "ALL", :name => "Albanian Lek",                              :symbol => "L",             :subunit => "Qintar",        :subunit_to_unit => 100, :separator => "."   },
      :amd => { :priority => 100, :iso_code => "AMD", :name => "Armenian Dram",                             :symbol => "դր.",           :subunit => "Luma",          :subunit_to_unit => 100, :separator => "."   },
      :ang => { :priority => 100, :iso_code => "ANG", :name => "Netherlands Antillean Gulden",              :symbol => "ƒ",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :aoa => { :priority => 100, :iso_code => "AOA", :name => "Angolan Kwanza",                            :symbol => "Kz",            :subunit => "Cêntimo",       :subunit_to_unit => 100, :separator => "."   },
      :ars => { :priority => 100, :iso_code => "ARS", :name => "Argentine Peso",                            :symbol => "$",             :subunit => "Centavo",       :subunit_to_unit => 100, :separator => "."   },
      :aud => { :priority =>   4, :iso_code => "AUD", :name => "Australian Dollar",                         :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :awg => { :priority => 100, :iso_code => "AWG", :name => "Aruban Florin",                             :symbol => "ƒ",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :azn => { :priority => 100, :iso_code => "AZN", :name => "Azerbaijani Manat",                         :symbol => nil,             :subunit => "Qəpik",         :subunit_to_unit => 100, :separator => "."   },
      :bam => { :priority => 100, :iso_code => "BAM", :name => "Bosnia and Herzegovina Convertible Mark",   :symbol => "KM or КМ",      :subunit => "Fening",        :subunit_to_unit => 100, :separator => "."   },
      :bbd => { :priority => 100, :iso_code => "BBD", :name => "Barbadian Dollar",                          :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :bdt => { :priority => 100, :iso_code => "BDT", :name => "Bangladeshi Taka",                          :symbol => "৳",             :subunit => "Paisa",         :subunit_to_unit => 100, :separator => "."   },
      :bgn => { :priority => 100, :iso_code => "BGN", :name => "Bulgarian Lev",                             :symbol => "лв",            :subunit => "Stotinka",      :subunit_to_unit => 100, :separator => "."   },
      :bhd => { :priority => 100, :iso_code => "BHD", :name => "Bahraini Dinar",                            :symbol => "ب.د",           :subunit => "Fils",          :subunit_to_unit => 1000, :separator => "." },
      :bif => { :priority => 100, :iso_code => "BIF", :name => "Burundian Franc",                           :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100, :separator => "."   },
      :bmd => { :priority => 100, :iso_code => "BMD", :name => "Bermudian Dollar",                          :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :bnd => { :priority => 100, :iso_code => "BND", :name => "Brunei Dollar",                             :symbol => "$",             :subunit => "Sen",           :subunit_to_unit => 100, :separator => "."   },
      :bob => { :priority => 100, :iso_code => "BOB", :name => "Bolivian Boliviano",                        :symbol => "Bs.",           :subunit => "Centavo",       :subunit_to_unit => 100, :separator => "."   },
      :brl => { :priority => 100, :iso_code => "BRL", :name => "Brazilian Real",                            :symbol => "R$ ",            :subunit => "Centavo",       :subunit_to_unit => 100, :separator => ","   },
      :bsd => { :priority => 100, :iso_code => "BSD", :name => "Bahamian Dollar",                           :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :btn => { :priority => 100, :iso_code => "BTN", :name => "Bhutanese Ngultrum",                        :symbol => nil,             :subunit => "Chertrum",      :subunit_to_unit => 100, :separator => "."   },
      :bwp => { :priority => 100, :iso_code => "BWP", :name => "Botswana Pula",                             :symbol => "P",             :subunit => "Thebe",         :subunit_to_unit => 100, :separator => "."   },
      :byr => { :priority => 100, :iso_code => "BYR", :name => "Belarusian Ruble",                          :symbol => "Br",            :subunit => "Kapyeyka",      :subunit_to_unit => 100, :separator => "."   },
      :bzd => { :priority => 100, :iso_code => "BZD", :name => "Belize Dollar",                             :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :cad => { :priority =>   5, :iso_code => "CAD", :name => "Canadian Dollar",                           :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :cdf => { :priority => 100, :iso_code => "CDF", :name => "Congolese Franc",                           :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100, :separator => "."   },
      :chf => { :priority => 100, :iso_code => "CHF", :name => "Swiss Franc",                               :symbol => "Fr",            :subunit => "Rappen",        :subunit_to_unit => 100, :separator => "."   },
      :chf => { :priority => 100, :iso_code => "CHF", :name => "Swiss Franc",                               :symbol => "Fr",            :subunit => "Rappen",        :subunit_to_unit => 100, :separator => "."   },
      :clp => { :priority => 100, :iso_code => "CLP", :name => "Chilean Peso",                              :symbol => "$",             :subunit => "Centavo",       :subunit_to_unit => 100, :separator => "."   },
      :cny => { :priority => 100, :iso_code => "CNY", :name => "Chinese Renminbi Yuan",                     :symbol => "¥",             :subunit => "Jiao",          :subunit_to_unit => 10, :separator => "."    },
      :cop => { :priority => 100, :iso_code => "COP", :name => "Colombian Peso",                            :symbol => "$",             :subunit => "Centavo",       :subunit_to_unit => 100, :separator => "."   },
      :crc => { :priority => 100, :iso_code => "CRC", :name => "Costa Rican Colón",                         :symbol => "₡",             :subunit => "Céntimo",       :subunit_to_unit => 100, :separator => "."   },
      :cuc => { :priority => 100, :iso_code => "CUC", :name => "Cuban Convertible Peso",                    :symbol => "$",             :subunit => "Centavo",       :subunit_to_unit => 100, :separator => "."   },
      :cup => { :priority => 100, :iso_code => "CUP", :name => "Cuban Peso",                                :symbol => "$",             :subunit => "Centavo",       :subunit_to_unit => 100, :separator => "."   },
      :cve => { :priority => 100, :iso_code => "CVE", :name => "Cape Verdean Escudo",                       :symbol => "$ or Esc",      :subunit => "Centavo",       :subunit_to_unit => 100, :separator => "."   },
      :czk => { :priority => 100, :iso_code => "CZK", :name => "Czech Koruna",                              :symbol => "Kč",            :subunit => "Haléř",         :subunit_to_unit => 100, :separator => "."   },
      :djf => { :priority => 100, :iso_code => "DJF", :name => "Djiboutian Franc",                          :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100, :separator => "."   },
      :dkk => { :priority => 100, :iso_code => "DKK", :name => "Danish Krone",                              :symbol => "kr",            :subunit => "Øre",           :subunit_to_unit => 100, :separator => "."   },
      :dop => { :priority => 100, :iso_code => "DOP", :name => "Dominican Peso",                            :symbol => "$",             :subunit => "Centavo",       :subunit_to_unit => 100, :separator => "."   },
      :dzd => { :priority => 100, :iso_code => "DZD", :name => "Algerian Dinar",                            :symbol => "د.ج",           :subunit => "Centime",       :subunit_to_unit => 100, :separator => "."   },
      :eek => { :priority => 100, :iso_code => "EEK", :name => "Estonian Kroon",                            :symbol => "KR",            :subunit => "Sent",          :subunit_to_unit => 100, :separator => "."   },
      :egp => { :priority => 100, :iso_code => "EGP", :name => "Egyptian Pound",                            :symbol => "£ or ج.م",      :subunit => "Piastre",       :subunit_to_unit => 100, :separator => "."   },
      :ern => { :priority => 100, :iso_code => "ERN", :name => "Eritrean Nakfa",                            :symbol => "Nfk",           :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :etb => { :priority => 100, :iso_code => "ETB", :name => "Ethiopian Birr",                            :symbol => nil,             :subunit => "Santim",        :subunit_to_unit => 100, :separator => "."   },
      :eur => { :priority =>   2, :iso_code => "EUR", :name => "Euro",                                      :symbol => "€",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :fjd => { :priority => 100, :iso_code => "FJD", :name => "Fijian Dollar",                             :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :fkp => { :priority => 100, :iso_code => "FKP", :name => "Falkland Pound",                            :symbol => "£",             :subunit => "Penny",         :subunit_to_unit => 100, :separator => "."   },
      :gbp => { :priority =>   3, :iso_code => "GBP", :name => "British Pound",                             :symbol => "£",             :subunit => "Penny",         :subunit_to_unit => 100, :separator => "."   },
      :gel => { :priority => 100, :iso_code => "GEL", :name => "Georgian Lari",                             :symbol => "ლ",             :subunit => "Tetri",         :subunit_to_unit => 100, :separator => "."   },
      :ghc => { :priority => 100, :iso_code => "GHC", :name => "Ghanaian Cedi",                             :symbol => "₵",             :subunit => "Pesewa",        :subunit_to_unit => 100, :separator => "."   },
      :gip => { :priority => 100, :iso_code => "GIP", :name => "Gibraltar Pound",                           :symbol => "£",             :subunit => "Penny",         :subunit_to_unit => 100, :separator => "."   },
      :gmd => { :priority => 100, :iso_code => "GMD", :name => "Gambian Dalasi",                            :symbol => "D",             :subunit => "Butut",         :subunit_to_unit => 100, :separator => "."   },
      :gnf => { :priority => 100, :iso_code => "GNF", :name => "Guinean Franc",                             :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100, :separator => "."   },
      :gtq => { :priority => 100, :iso_code => "GTQ", :name => "Guatemalan Quetzal",                        :symbol => "Q",             :subunit => "Centavo",       :subunit_to_unit => 100, :separator => "."   },
      :gyd => { :priority => 100, :iso_code => "GYD", :name => "Guyanese Dollar",                           :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :hkd => { :priority => 100, :iso_code => "HKD", :name => "Hong Kong Dollar",                          :symbol => "$",             :subunit => "Ho",            :subunit_to_unit => 10, :separator => "."    },
      :hnl => { :priority => 100, :iso_code => "HNL", :name => "Honduran Lempira",                          :symbol => "L",             :subunit => "Centavo",       :subunit_to_unit => 100, :separator => "."   },
      :hrk => { :priority => 100, :iso_code => "HRK", :name => "Croatian Kuna",                             :symbol => "kn",            :subunit => "Lipa",          :subunit_to_unit => 100, :separator => "."   },
      :htg => { :priority => 100, :iso_code => "HTG", :name => "Haitian Gourde",                            :symbol => "G",             :subunit => "Centime",       :subunit_to_unit => 100, :separator => "."   },
      :huf => { :priority => 100, :iso_code => "HUF", :name => "Hungarian Forint",                          :symbol => "Ft",            :subunit => "Fillér",        :subunit_to_unit => 100, :separator => "."   },
      :idr => { :priority => 100, :iso_code => "IDR", :name => "Indonesian Rupiah",                         :symbol => "Rp",            :subunit => "Sen",           :subunit_to_unit => 100, :separator => "."   },
      :ils => { :priority => 100, :iso_code => "ILS", :name => "Israeli New Sheqel",                        :symbol => "₪",             :subunit => "Agora",         :subunit_to_unit => 100, :separator => "."   },
      :inr => { :priority => 100, :iso_code => "INR", :name => "Indian Rupee",                              :symbol => "₨",             :subunit => "Paisa",         :subunit_to_unit => 100, :separator => "."   },
      :iqd => { :priority => 100, :iso_code => "IQD", :name => "Iraqi Dinar",                               :symbol => "ع.د",           :subunit => "Fils",          :subunit_to_unit => 1000, :separator => "." },
      :irr => { :priority => 100, :iso_code => "IRR", :name => "Iranian Rial",                              :symbol => "﷼",             :subunit => "Dinar",         :subunit_to_unit => 100, :separator => "."   },
      :isk => { :priority => 100, :iso_code => "ISK", :name => "Icelandic Króna",                           :symbol => "kr",            :subunit => "Eyrir",         :subunit_to_unit => 100, :separator => "."   },
      :jmd => { :priority => 100, :iso_code => "JMD", :name => "Jamaican Dollar",                           :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :jod => { :priority => 100, :iso_code => "JOD", :name => "Jordanian Dinar",                           :symbol => "د.ا",           :subunit => "Piastre",       :subunit_to_unit => 100, :separator => "."   },
      :jpy => { :priority =>   6, :iso_code => "JPY", :name => "Japanese Yen",                              :symbol => "¥",             :subunit => "Sen",           :subunit_to_unit => 100, :separator => "."   },
      :kes => { :priority => 100, :iso_code => "KES", :name => "Kenyan Shilling",                           :symbol => "Sh",            :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :kgs => { :priority => 100, :iso_code => "KGS", :name => "Kyrgyzstani Som",                           :symbol => nil,             :subunit => "Tyiyn",         :subunit_to_unit => 100, :separator => "."   },
      :khr => { :priority => 100, :iso_code => "KHR", :name => "Cambodian Riel",                            :symbol => "៛",             :subunit => "Sen",           :subunit_to_unit => 100, :separator => "."   },
      :kmf => { :priority => 100, :iso_code => "KMF", :name => "Comorian Franc",                            :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100, :separator => "."   },
      :kpw => { :priority => 100, :iso_code => "KPW", :name => "North Korean Won",                          :symbol => "₩",             :subunit => "Chŏn",          :subunit_to_unit => 100, :separator => "."   },
      :krw => { :priority => 100, :iso_code => "KRW", :name => "South Korean Won",                          :symbol => "₩",             :subunit => "Jeon",          :subunit_to_unit => 100, :separator => "."   },
      :kwd => { :priority => 100, :iso_code => "KWD", :name => "Kuwaiti Dinar",                             :symbol => "د.ك",           :subunit => "Fils",          :subunit_to_unit => 1000, :separator => "." },
      :kyd => { :priority => 100, :iso_code => "KYD", :name => "Cayman Islands Dollar",                     :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :kzt => { :priority => 100, :iso_code => "KZT", :name => "Kazakhstani Tenge",                         :symbol => "〒",             :subunit => "Tiyn",          :subunit_to_unit => 100, :separator => "."   },
      :lak => { :priority => 100, :iso_code => "LAK", :name => "Lao Kip",                                   :symbol => "₭",             :subunit => "Att",           :subunit_to_unit => 100, :separator => "."   },
      :lbp => { :priority => 100, :iso_code => "LBP", :name => "Lebanese Lira",                             :symbol => "ل.ل",           :subunit => "Piastre",       :subunit_to_unit => 100, :separator => "."   },
      :lkr => { :priority => 100, :iso_code => "LKR", :name => "Sri Lankan Rupee",                          :symbol => "₨",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :lrd => { :priority => 100, :iso_code => "LRD", :name => "Liberian Dollar",                           :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :lsl => { :priority => 100, :iso_code => "LSL", :name => "Lesotho Loti",                              :symbol => "L",             :subunit => "Sente",         :subunit_to_unit => 100, :separator => "."   },
      :ltl => { :priority => 100, :iso_code => "LTL", :name => "Lithuanian Litas",                          :symbol => "Lt",            :subunit => "Centas",        :subunit_to_unit => 100, :separator => "."   },
      :lvl => { :priority => 100, :iso_code => "LVL", :name => "Latvian Lats",                              :symbol => "Ls",            :subunit => "Santīms",       :subunit_to_unit => 100, :separator => "."   },
      :lyd => { :priority => 100, :iso_code => "LYD", :name => "Libyan Dinar",                              :symbol => "ل.د",           :subunit => "Dirham",        :subunit_to_unit => 1000, :separator => "." },
      :mad => { :priority => 100, :iso_code => "MAD", :name => "Moroccan Dirham",                           :symbol => "د.م.",          :subunit => "Centime",       :subunit_to_unit => 100, :separator => "."   },
      :mdl => { :priority => 100, :iso_code => "MDL", :name => "Moldovan Leu",                              :symbol => "L",             :subunit => "Ban",           :subunit_to_unit => 100, :separator => "."   },
      :mga => { :priority => 100, :iso_code => "MGA", :name => "Malagasy Ariary",                           :symbol => nil,             :subunit => "Iraimbilanja",  :subunit_to_unit => 5, :separator => "."     },
      :mkd => { :priority => 100, :iso_code => "MKD", :name => "Macedonian Denar",                          :symbol => "ден",           :subunit => "Deni",          :subunit_to_unit => 100, :separator => "."   },
      :mmk => { :priority => 100, :iso_code => "MMK", :name => "Myanmar Kyat",                              :symbol => "K",             :subunit => "Pya",           :subunit_to_unit => 100, :separator => "."   },
      :mnt => { :priority => 100, :iso_code => "MNT", :name => "Mongolian Tögrög",                          :symbol => "₮",             :subunit => "Möngö",         :subunit_to_unit => 100, :separator => "."   },
      :mop => { :priority => 100, :iso_code => "MOP", :name => "Macanese Pataca",                           :symbol => "P",             :subunit => "Avo",           :subunit_to_unit => 100, :separator => "."   },
      :mro => { :priority => 100, :iso_code => "MRO", :name => "Mauritanian Ouguiya",                       :symbol => "UM",            :subunit => "Khoums",        :subunit_to_unit => 5, :separator => "."     },
      :mur => { :priority => 100, :iso_code => "MUR", :name => "Mauritian Rupee",                           :symbol => "₨",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :mvr => { :priority => 100, :iso_code => "MVR", :name => "Maldivian Rufiyaa",                         :symbol => "ރ.",            :subunit => "Laari",         :subunit_to_unit => 100, :separator => "."   },
      :mwk => { :priority => 100, :iso_code => "MWK", :name => "Malawian Kwacha",                           :symbol => "MK",            :subunit => "Tambala",       :subunit_to_unit => 100, :separator => "."   },
      :mxn => { :priority => 100, :iso_code => "MXN", :name => "Mexican Peso",                              :symbol => "$",             :subunit => "Centavo",       :subunit_to_unit => 100, :separator => "."   },
      :myr => { :priority => 100, :iso_code => "MYR", :name => "Malaysian Ringgit",                         :symbol => "RM",            :subunit => "Sen",           :subunit_to_unit => 100, :separator => "."   },
      :mzn => { :priority => 100, :iso_code => "MZN", :name => "Mozambican Metical",                        :symbol => "MTn",           :subunit => "Centavo",       :subunit_to_unit => 100, :separator => "."   },
      :nad => { :priority => 100, :iso_code => "NAD", :name => "Namibian Dollar",                           :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :ngn => { :priority => 100, :iso_code => "NGN", :name => "Nigerian Naira",                            :symbol => "₦",             :subunit => "Kobo",          :subunit_to_unit => 100, :separator => "."   },
      :nio => { :priority => 100, :iso_code => "NIO", :name => "Nicaraguan Córdoba",                        :symbol => "C$",            :subunit => "Centavo",       :subunit_to_unit => 100, :separator => "."   },
      :nok => { :priority => 100, :iso_code => "NOK", :name => "Norwegian Krone",                           :symbol => "kr",            :subunit => "Øre",           :subunit_to_unit => 100, :separator => "."   },
      :npr => { :priority => 100, :iso_code => "NPR", :name => "Nepalese Rupee",                            :symbol => "₨",             :subunit => "Paisa",         :subunit_to_unit => 100, :separator => "."   },
      :nzd => { :priority => 100, :iso_code => "NZD", :name => "New Zealand Dollar",                        :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :omr => { :priority => 100, :iso_code => "OMR", :name => "Omani Rial",                                :symbol => "ر.ع.",          :subunit => "Baisa",         :subunit_to_unit => 1000, :separator => "." },
      :pab => { :priority => 100, :iso_code => "PAB", :name => "Panamanian Balboa",                         :symbol => "B/.",           :subunit => "Centésimo",     :subunit_to_unit => 100, :separator => "."   },
      :pen => { :priority => 100, :iso_code => "PEN", :name => "Peruvian Nuevo Sol",                        :symbol => "S/.",           :subunit => "Céntimo",       :subunit_to_unit => 100, :separator => "."   },
      :pgk => { :priority => 100, :iso_code => "PGK", :name => "Papua New Guinean Kina",                    :symbol => "K",             :subunit => "Toea",          :subunit_to_unit => 100, :separator => "."   },
      :php => { :priority => 100, :iso_code => "PHP", :name => "Philippine Peso",                           :symbol => "₱",             :subunit => "Centavo",       :subunit_to_unit => 100, :separator => "."   },
      :pkr => { :priority => 100, :iso_code => "PKR", :name => "Pakistani Rupee",                           :symbol => "₨",             :subunit => "Paisa",         :subunit_to_unit => 100, :separator => "."   },
      :pln => { :priority => 100, :iso_code => "PLN", :name => "Polish Złoty",                              :symbol => "zł",            :subunit => "Grosz",         :subunit_to_unit => 100, :separator => "."   },
      :pyg => { :priority => 100, :iso_code => "PYG", :name => "Paraguayan Guaraní",                        :symbol => "₲",             :subunit => "Céntimo",       :subunit_to_unit => 100, :separator => "."   },
      :qar => { :priority => 100, :iso_code => "QAR", :name => "Qatari Riyal",                              :symbol => "ر.ق",           :subunit => "Dirham",        :subunit_to_unit => 100, :separator => "."   },
      :ron => { :priority => 100, :iso_code => "RON", :name => "Romanian Leu",                              :symbol => "L",             :subunit => "Ban",           :subunit_to_unit => 100, :separator => "."   },
      :rsd => { :priority => 100, :iso_code => "RSD", :name => "Serbian Dinar",                             :symbol => "din. or дин.",  :subunit => "Para",          :subunit_to_unit => 100, :separator => "."   },
      :rub => { :priority => 100, :iso_code => "RUB", :name => "Russian Ruble",                             :symbol => "р.",            :subunit => "Kopek",         :subunit_to_unit => 100, :separator => "."   },
      :rub => { :priority => 100, :iso_code => "RUB", :name => "Russian Ruble",                             :symbol => "руб.",          :subunit => "Kopek",         :subunit_to_unit => 100, :separator => "."   },
      :rwf => { :priority => 100, :iso_code => "RWF", :name => "Rwandan Franc",                             :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100, :separator => "."   },
      :sar => { :priority => 100, :iso_code => "SAR", :name => "Saudi Riyal",                               :symbol => "ر.س",           :subunit => "Hallallah",     :subunit_to_unit => 100, :separator => "."   },
      :sbd => { :priority => 100, :iso_code => "SBD", :name => "Solomon Islands Dollar",                    :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :scr => { :priority => 100, :iso_code => "SCR", :name => "Seychellois Rupee",                         :symbol => "₨",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :sdg => { :priority => 100, :iso_code => "SDG", :name => "Sudanese Pound",                            :symbol => "£",             :subunit => "Piastre",       :subunit_to_unit => 100, :separator => "."   },
      :sek => { :priority => 100, :iso_code => "SEK", :name => "Swedish Krona",                             :symbol => "kr",            :subunit => "Öre",           :subunit_to_unit => 100, :separator => "."   },
      :sgd => { :priority => 100, :iso_code => "SGD", :name => "Singapore Dollar",                          :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :shp => { :priority => 100, :iso_code => "SHP", :name => "Saint Helenian Pound",                      :symbol => "£",             :subunit => "Penny",         :subunit_to_unit => 100, :separator => "."   },
      :skk => { :priority => 100, :iso_code => "SKK", :name => "Slovak Koruna",                             :symbol => "Sk",            :subunit => "Halier",        :subunit_to_unit => 100, :separator => "."   },
      :sll => { :priority => 100, :iso_code => "SLL", :name => "Sierra Leonean Leone",                      :symbol => "Le",            :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :sos => { :priority => 100, :iso_code => "SOS", :name => "Somali Shilling",                           :symbol => "Sh",            :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :srd => { :priority => 100, :iso_code => "SRD", :name => "Surinamese Dollar",                         :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :std => { :priority => 100, :iso_code => "STD", :name => "São Tomé and Príncipe Dobra",               :symbol => "Db",            :subunit => "Cêntimo",       :subunit_to_unit => 100, :separator => "."   },
      :svc => { :priority => 100, :iso_code => "SVC", :name => "Salvadoran Colón",                          :symbol => "₡",             :subunit => "Centavo",       :subunit_to_unit => 100, :separator => "."   },
      :syp => { :priority => 100, :iso_code => "SYP", :name => "Syrian Pound",                              :symbol => "£ or ل.س",      :subunit => "Piastre",       :subunit_to_unit => 100, :separator => "."   },
      :szl => { :priority => 100, :iso_code => "SZL", :name => "Swazi Lilangeni",                           :symbol => "L",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :thb => { :priority => 100, :iso_code => "THB", :name => "Thai Baht",                                 :symbol => "฿",             :subunit => "Satang",        :subunit_to_unit => 100, :separator => "."   },
      :tjs => { :priority => 100, :iso_code => "TJS", :name => "Tajikistani Somoni",                        :symbol => "ЅМ",            :subunit => "Diram",         :subunit_to_unit => 100, :separator => "."   },
      :tmm => { :priority => 100, :iso_code => "TMM", :name => "Turkmenistani Manat",                       :symbol => "m",             :subunit => "Tennesi",       :subunit_to_unit => 100, :separator => "."   },
      :tnd => { :priority => 100, :iso_code => "TND", :name => "Tunisian Dinar",                            :symbol => "د.ت",           :subunit => "Millime",       :subunit_to_unit => 1000, :separator => "." },
      :top => { :priority => 100, :iso_code => "TOP", :name => "Tongan Paʻanga",                            :symbol => "T$",            :subunit => "Seniti",        :subunit_to_unit => 100, :separator => "."   },
      :try => { :priority => 100, :iso_code => "TRY", :name => "Turkish New Lira",                          :symbol => "YTL",           :subunit => "New kuruş",     :subunit_to_unit => 100, :separator => "."   },
      :try => { :priority => 100, :iso_code => "TRY", :name => "Turkish New Lira",                          :symbol => "₤",             :subunit => "New kuruş",     :subunit_to_unit => 100, :separator => "."   },
      :ttd => { :priority => 100, :iso_code => "TTD", :name => "Trinidad and Tobago Dollar",                :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :twd => { :priority => 100, :iso_code => "TWD", :name => "New Taiwan Dollar",                         :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :tzs => { :priority => 100, :iso_code => "TZS", :name => "Tanzanian Shilling",                        :symbol => "Sh",            :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :uah => { :priority => 100, :iso_code => "UAH", :name => "Ukrainian Hryvnia",                         :symbol => "₴",             :subunit => "Kopiyka",       :subunit_to_unit => 100, :separator => "."   },
      :ugx => { :priority => 100, :iso_code => "UGX", :name => "Ugandan Shilling",                          :symbol => "Sh",            :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :usd => { :priority =>   1, :iso_code => "USD", :name => "United States Dollar",                      :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :uyu => { :priority => 100, :iso_code => "UYU", :name => "Uruguayan Peso",                            :symbol => "$",             :subunit => "Centésimo",     :subunit_to_unit => 100, :separator => "."   },
      :uzs => { :priority => 100, :iso_code => "UZS", :name => "Uzbekistani Som",                           :symbol => nil,             :subunit => "Tiyin",         :subunit_to_unit => 100, :separator => "."   },
      :vef => { :priority => 100, :iso_code => "VEF", :name => "Venezuelan Bolívar",                        :symbol => "Bs F",          :subunit => "Céntimo",       :subunit_to_unit => 100, :separator => "."   },
      :vnd => { :priority => 100, :iso_code => "VND", :name => "Vietnamese Đồng",                           :symbol => "₫",             :subunit => "Hào",           :subunit_to_unit => 10, :separator => "."    },
      :vuv => { :priority => 100, :iso_code => "VUV", :name => "Vanuatu Vatu",                              :symbol => "Vt",            :subunit => nil,             :subunit_to_unit => 1, :separator => "."     },
      :wst => { :priority => 100, :iso_code => "WST", :name => "Samoan Tala",                               :symbol => "T",             :subunit => "Sene",          :subunit_to_unit => 100, :separator => "."   },
      :xaf => { :priority => 100, :iso_code => "XAF", :name => "Central African Cfa Franc",                 :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100, :separator => "."   },
      :xcd => { :priority => 100, :iso_code => "XCD", :name => "East Caribbean Dollar",                     :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :xof => { :priority => 100, :iso_code => "XOF", :name => "West African Cfa Franc",                    :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100, :separator => "."   },
      :xpf => { :priority => 100, :iso_code => "XPF", :name => "Cfp Franc",                                 :symbol => "Fr",            :subunit => "Centime",       :subunit_to_unit => 100, :separator => "."   },
      :yer => { :priority => 100, :iso_code => "YER", :name => "Yemeni Rial",                               :symbol => "﷼",             :subunit => "Fils",          :subunit_to_unit => 100, :separator => "."   },
      :zar => { :priority => 100, :iso_code => "ZAR", :name => "South African Rand",                        :symbol => "R",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },
      :zmk => { :priority => 100, :iso_code => "ZMK", :name => "Zambian Kwacha",                            :symbol => "ZK",            :subunit => "Ngwee",         :subunit_to_unit => 100, :separator => "."   },
      :zwd => { :priority => 100, :iso_code => "ZWD", :name => "Zimbabwean Dollar",                         :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :separator => "."   },

      # aliases for BC with documentation before Currency
      :yen => { :priority => 100, :iso_code => "JPY", :name => "Japanese Yen",                              :symbol => "¥",             :subunit => "Sen",           :subunit_to_unit => 100, :separator => "."   },
    }

    attr_reader :id, *ATTRIBUTES

    def initialize(id)
      @id  = id.to_s.downcase.to_sym
      data = TABLE[@id] || raise(UnknownCurrency, "Unknown currency `#{id}'")
      ATTRIBUTES.each do |attribute|
        instance_variable_set(:"@#{attribute}", data[attribute])
      end
    end

    # Compares <tt>self</tt> with <tt>other_currency</tt>
    # against the value of <tt>priority</tt> attribute.
    def <=>(other_currency)
      self.priority <=> other_currency.priority
    end

    # Returns <tt>true</tt> if <tt>self.iso_code</tt>
    # is equal to <tt>other_currency.iso_code</tt>
    def ==(other_currency)
      self.equal?(other_currency) ||
      self.id == other_currency.id
    end

    # Returns a string representation
    # corresponding to the upcase <tt>id</tt> attribute.
    #
    #   Currency.new(:usd).to_s
    #   # => "USD"
    #   Currency.new(:eur).to_s
    #   # => "EUR"
    #
    # -–
    # DEV: id.to_s.upcase corresponds to iso_code
    # but don't use ISO_CODE for consistency.
    def to_s
      id.to_s.upcase
    end

    # Returns a human readable representation.
    #
    #   #<Currency id:usd>
    #
    def inspect
      "#<#{self.class.name} id: #{id} #{ATTRIBUTES.map { |a| "#{a}: #{send(a)}" }.join(", ")}>"
    end


    def method_missing(method, *args, &block)
      warn "DEPRECATION MESSAGE: `currency' is now a Currency instance. Call `currency.to_s.#{method}' instead."
      iso_code.send(method, *args, &block)
    end

    class << self

      # Lookup a Currency with given <tt>id</tt>
      # an returns a <tt>Currency</tt> instance on success,
      # <tt>nil</tt> otherwise.
      #
      #   Currency.find(:eur)
      #   # => <#Currency id: eur ...>
      #   Currency.find(:foo)
      #   # => nil
      #
      def find(id)
        id = id.to_s.downcase.to_sym
        if data = self::TABLE[id]
          new(id)
        end
      end

      # Wraps the object in a Currency unless it's a Currency.
      #
      #   Currency.wrap(nil)
      #   # => nil
      #   Currency.wrap(Currency.new(:usd))
      #   # => <#Currency id: usd ...>
      #   Currency.wrap("usd")
      #   # => <#Currency id: usd ...>
      #
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
