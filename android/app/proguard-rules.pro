# ProGuard rules for Canvas release builds (R8 minify + shrinkResources).
# Defaults from `proguard-android-optimize.txt` handle most of AndroidX.
# Additions below cover the plugins/SDKs this app uses that rely on
# reflection or generated code.

# ----- Flutter -----
# Flutter's Gradle plugin injects its own rules for io.flutter.*; nothing
# needed here for the engine itself.

# ----- Firebase (core + auth + firestore) -----
# Firebase keeps quite a bit via its own consumer rules, but stricter R8
# passes still need help on model classes used via Gson-style reflection.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firestore uses Protobuf; keep generated message classes.
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**

# ----- Google Sign-In -----
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.api.client.** { *; }
-dontwarn com.google.api.client.**

# ----- googleapis / googleapis_auth (pure Dart; JNI-side empty) -----
# Nothing to keep — Dart code is untouched by R8.

# ----- drift / sqlite3_flutter_libs -----
-keep class io.flutter.plugins.** { *; }

# ----- Generic safety -----
# Keep line numbers for release crash reports (source files stripped).
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep any class annotated @Keep (androidx.annotation.Keep).
-keep @androidx.annotation.Keep class * { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}
