import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load android/key.properties for release signing. The file is gitignored;
// see key.properties.example for the expected schema. Falls back to debug
// signing when the file is absent (e.g. CI debug builds, fresh clones).
val keystoreProperties = Properties().apply {
    val keystoreFile = rootProject.file("key.properties")
    if (keystoreFile.exists()) {
        load(FileInputStream(keystoreFile))
    }
}
val hasReleaseSigning = keystoreProperties.getProperty("storeFile") != null

android {
    namespace = "com.alamaby.bagistruk"
    // Pinned to Android 16 (API 36) — Play Store requires targetSdk 35+ from
    // Aug 2025 and is expected to require 36 from Aug 2026. Pinning explicitly
    // also avoids surprises when bumping the Flutter SDK.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications 18.x AAR requires core library
        // desugaring (:app:checkReleaseAarMetadata fails without it).
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.alamaby.bagistruk"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // When key.properties is absent we fall back to debug signing so
            // `flutter run --release` still works locally. Play Store uploads
            // MUST use the release keystore — see README "Release build".
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

fun readPubspecValue(key: String): String? {
    val pubspec = rootProject.projectDir.parentFile.resolve("pubspec.yaml")
    if (!pubspec.exists()) return null
    val keyRegex = Regex("""^\s*${Regex.escape(key)}\s*:\s*(.+?)\s*$""")
    return pubspec
        .readLines()
        .firstNotNullOfOrNull { line ->
            keyRegex.matchEntire(line)?.groupValues?.getOrNull(1)
        }
        ?.trim()
        ?.trim('"', '\'')
}

fun readAndroidAppLabel(): String? {
    val manifest = projectDir.resolve("src/main/AndroidManifest.xml")
    if (!manifest.exists()) return null
    val labelRegex = Regex("""android:label\s*=\s*"([^"]+)"""")
    return labelRegex.find(manifest.readText())?.groupValues?.getOrNull(1)
}

fun String.asApkFileSegment(): String =
    replace(Regex("""[^\w.+-]+"""), "-").trim('-').ifEmpty { "app" }

fun requirePubspecSemanticVersion(): String {
    val version = readPubspecValue("version")
        ?: error("Missing version in pubspec.yaml")
    val semanticVersionRegex = Regex(
        """^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?$""",
    )

    require(semanticVersionRegex.matches(version)) {
        "pubspec.yaml version must use semantic versioning, for example 1.2.3+4. Current value: $version"
    }

    return version
}

fun releaseApkName(originalName: String, appName: String, version: String): String {
    val abi = Regex("""^app-(.+)-release\.apk$""")
        .matchEntire(originalName)
        ?.groupValues
        ?.getOrNull(1)
    return if (abi == null) {
        "$appName-$version.apk"
    } else {
        "$appName-$version-$abi.apk"
    }
}

val renameReleaseApk = tasks.register<Copy>("renameReleaseApk") {
    group = "build"
    description = "Copies release APKs using the Android app name and semantic version from pubspec.yaml."
    dependsOn("assembleRelease")

    val flutterProjectDir = rootProject.projectDir.parentFile
    val appName = (readAndroidAppLabel() ?: readPubspecValue("name") ?: "app")
        .asApkFileSegment()
    val version = requirePubspecSemanticVersion()
        .asApkFileSegment()
    val releaseApkOutputDir = flutterProjectDir.resolve("build/app/outputs/apk/release")
    val flutterApkOutputDir = flutterProjectDir.resolve("build/app/outputs/flutter-apk")

    from(releaseApkOutputDir) {
        include("*.apk")
        rename { originalName -> releaseApkName(originalName, appName, version) }
    }
    into(flutterApkOutputDir)

    doLast {
        val namedApks = flutterApkOutputDir
            .listFiles { file -> file.extension == "apk" && file.name.startsWith("$appName-") }
            ?.joinToString { it.name }
            ?: "none"
        println("Named APKs created in build/app/outputs/flutter-apk: $namedApks")
    }
}
