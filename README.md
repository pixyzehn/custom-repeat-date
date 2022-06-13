# custom-repeat-date

A simple date extension that easily allows you to provide custom repeat date options for the Gregorian calendar.

## Converting Documentation

```shell
swift package --allow-writing-to-directory ./docs \
    generate-documentation --target CustomRepeatDate --output-path ./docs \
    --transform-for-static-hosting --hosting-base-path custom-repeat-date
```

## Previewing Documentation

```shell
swift package --disable-sandbox preview-documentation --product CustomRepeatDate
```

See also [apple/swift-docc-plugin](https://github.com/apple/swift-docc-plugin) for more information.
