# Reglas generales para Flutter
-keep class io.flutter.plugins.** { *; }

# Reglas para Firebase (buena práctica)
-keep class com.google.firebase.** { *; }

# --- REGLAS CRÍTICAS PARA TU PROBLEMA ---

# Regla para el paquete 'record'
-keep class com.llf.record.** { *; }

# Regla para el paquete 'just_audio' (muy recomendable)
-keep class com.ryanheise.just_audio.** { *; }

# Regla para el SDK de Facebook (si usas funciones avanzadas)
-keep class com.facebook.** { *; }