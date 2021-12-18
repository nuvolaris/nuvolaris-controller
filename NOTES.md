# How to compile

```
cd openwhisk
./gradlew :core:standalone:build
```

Compilation does not work on Apple M1 because a missing protocolbuffer binary for apple.
