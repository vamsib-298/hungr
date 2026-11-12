# Flutter Core Entry Points & JNI Interfaces
-keep class io.flutter.app.FlutterApplication { *; }
-keep class io.flutter.embedding.android.FlutterActivity { *; }
-keep class io.flutter.embedding.android.FlutterFragmentActivity { *; }
-keep class io.flutter.embedding.engine.FlutterJNI {
    native <methods>;
}

# Flutter Plugin Registrant (Generated at build time)
-keep class io.flutter.plugins.GeneratedPluginRegistrant {
    public static void registerWith(io.flutter.embedding.engine.FlutterEngine);
}
-keep class * implements io.flutter.plugin.common.PluginRegistry$PluginRegistrantCallback { *; }

# Allow R8 to aggressively obfuscate and optimize DEX bytecode
-repackageclasses 'com.hungr.app.obf'
-allowaccessmodification
-overloadaggressively

# Firebase & Google Play Services
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# Suppress harmless warnings from third-party SDKs
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-dontwarn androidx.**
-dontwarn **
