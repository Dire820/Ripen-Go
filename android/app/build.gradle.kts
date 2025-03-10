import java.util.Properties // ✅ Fix: Import the required class

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin must be after Android & Kotlin
}

android {
    namespace = "com.example.ripen_go"

    // ✅ Fix: Read Flutter versions safely
    val localProperties = Properties().apply {
        load(rootProject.file("local.properties").inputStream()) // ✅ Fix: Corrected loading method
    }

    val compileSdkVersion = localProperties["flutter.compileSdkVersion"]?.toString()?.toInt() ?: 33
    val targetSdkVersion = localProperties["flutter.targetSdkVersion"]?.toString()?.toInt() ?: 33
    val minSdkVersion = localProperties["flutter.minSdkVersion"]?.toString()?.toInt() ?: 23
    val appVersionCode = localProperties["flutter.versionCode"]?.toString()?.toInt() ?: 1
    val appVersionName = localProperties["flutter.versionName"]?.toString() ?: "1.0"

    compileSdk = 35
    ndkVersion = "29.0.13113456"


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.ripen_go"
        minSdk = minSdkVersion // ✅ Fix: Use a new variable name
        targetSdk = targetSdkVersion
        versionCode = appVersionCode // ✅ Fix: Prevent reassignment error
        versionName = appVersionName // ✅ Fix: Prevent reassignment error
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // Use a proper signing config for production
        }
    }
}

flutter {
    source = "../.."
}
