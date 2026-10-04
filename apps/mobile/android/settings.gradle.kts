pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localProperties = file("local.properties")
        if (!localProperties.exists()) {
            error("local.properties is missing. Run `flutter pub get` from apps/mobile first.")
        }
        localProperties.inputStream().use { properties.load(it) }
        properties.getProperty("flutter.sdk")
            ?: error("flutter.sdk is missing from local.properties")
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

rootProject.name = "via_mobile"
include(":app")
