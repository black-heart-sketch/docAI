-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-dontwarn javax.annotation.concurrent.**

# Keep Google Error Prone annotations
-keep class com.google.errorprone.annotations.** { *; }

# Keep javax annotations
-keep class javax.annotation.** { *; }
-keep class javax.annotation.concurrent.** { *; }

# Keep Google Crypto Tink classes
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**
