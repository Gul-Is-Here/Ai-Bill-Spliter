# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**
# Firebase / Play services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
# Crashlytics: keep line numbers for readable stack traces
-keepattributes SourceFile,LineNumberTable,*Annotation*,Signature,Exceptions
-keep public class * extends java.lang.Exception
# Play Core (deferred components referenced by Flutter)
-dontwarn com.google.android.play.core.**
