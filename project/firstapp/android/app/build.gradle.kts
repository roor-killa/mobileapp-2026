plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.firstapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.firstapp"
        
        // On force la version 21 pour Stripe
        minSdkVersion(24) 
        
        // On utilise les parenthèses pour corriger l'erreur "Function invocation expected"
        targetSdkVersion(flutter.targetSdkVersion)
        
        // Correction des erreurs "Unresolved reference"
        // On accède aux propriétés via le projet
        val flutterVersionCode = project.findProperty("flutterVersionCode") as? String
        val flutterVersionName = project.findProperty("flutterVersionName") as? String

        versionCode = flutterVersionCode?.toInt() ?: 1
        versionName = flutterVersionName ?: "1.0"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Ces deux lignes permettent à Android de trouver "Theme.AppCompat"
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.9.0")
}