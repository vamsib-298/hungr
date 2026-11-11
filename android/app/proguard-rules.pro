# Flutter Core Entry Points (Preserve only required JNI interfaces)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.common.** { *; }

# Allow R8 to aggressively obfuscate and optimize DEX bytecode
-repackageclasses 'com.hungr.app.obf'
-allowaccessmodification

# Firebase & Google Play Services
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep models and reflection-accessed classes
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

-dontwarn **


