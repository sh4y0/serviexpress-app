# FLUTTER CORE
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

# FIREBASE (NOTIFICACIONES, ANALYTICS, CRASHLYTICS)
-keep class com.google.firebase.** { *; }
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.crashlytics.** { *; }
-keep class com.google.firebase.analytics.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# JUST AUDIO
-keep class com.ryanheise.just_audio.** { *; }

# RECORD
-keep class com.llf.record.** { *; }

# FACEBOOK SDK
-keep class com.facebook.** { *; }
-dontwarn com.facebook.**

# GSON / JSON
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keepattributes Signature
-keepattributes *Annotation*

# REFLEXIÓN
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keepattributes RuntimeVisibleAnnotations
-keepattributes AnnotationDefault