# Flutter-specific ProGuard rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Hive
-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }

# Keep the entry point
-keep class com.yairmassury.track_builder.MainActivity { *; }
