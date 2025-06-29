import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("kotlin-kapt") // Pertahankan ini untuk pemrosesan anotasi
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.rapi.go_ban"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    // This is correctly placed
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        kotlinOptions {
            jvmTarget = "11"
        }
    }
    defaultConfig {
        applicationId = "com.rapi.go_ban"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion.toInt()
        versionCode = 1
        versionName = "1.0.1"
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.gms:play-services-ads:24.1.0")
    implementation("androidx.room:room-runtime:2.7.0")
    kapt("androidx.room:room-compiler:2.7.0") // Gunakan kapt untuk Kotlin
    // Tambahkan dependensi Kotlin stdlib
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.0.0") // Atau "2.0.10" untuk menyamai plugin
}
