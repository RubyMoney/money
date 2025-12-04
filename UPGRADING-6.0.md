# Upgrading to Money 6.0

## Version 6.0.0

- The `Money#dollars` and `Money#amount` methods now return instances of
  `BigDecimal` rather than `Float`. We should avoid representing monetary
  values with floating point types so to avoid a whole class of errors relating
  to lack of precision. There are two migration options for this change:
  * The first is to test your application and where applicable update the
    application to accept a `BigDecimal` return value. This is the recommended
    path.
  * The second is to migrate from the `#amount` and `#dollars` methods to use
    the `#to_f` method instead. This option should only be used where `Float`
    is the desired type and nothing else will do for your application's
    requirements.
