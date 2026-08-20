import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val releaseKeyConfigured = keystorePropertiesFile.exists()
if (releaseKeyConfigured) {
    FileInputStream(keystorePropertiesFile).use(keystoreProperties::load)
}
val releaseBuildRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}
if (releaseBuildRequested && !releaseKeyConfigured) {
    throw GradleException(
        "Assinatura de release não configurada. Copie " +
            "android/key.properties.example para android/key.properties.",
    )
}

android {
    namespace = "br.com.minha_medicacao"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "br.com.minha_medicacao"
        // Fixo em Android 7.0 (API 24), o menor nivel suportado pelo Flutter
        // atual e pelos plugins usados. Deixar o padrao do Flutter faria uma
        // atualizacao da ferramenta elevar o minimo em silencio, derrubando
        // aparelhos antigos que hoje rodam o aplicativo.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        if (releaseKeyConfigured) {
            create("release") {
                val storePath = keystoreProperties.getProperty("storeFile")
                    ?: throw GradleException("storeFile ausente em android/key.properties")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                    ?: throw GradleException("keyAlias ausente em android/key.properties")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                    ?: throw GradleException("keyPassword ausente em android/key.properties")
                storeFile = rootProject.file(storePath)
                storePassword = keystoreProperties.getProperty("storePassword")
                    ?: throw GradleException("storePassword ausente em android/key.properties")
            }
        }
    }

    buildTypes {
        release {
            if (releaseKeyConfigured) {
                signingConfig = signingConfigs.getByName("release")
            }
            // Minificacao permanece desligada de proposito: o pacote e
            // dominado pelas bibliotecas nativas do Flutter e do SQLite, e
            // medimos ganho de apenas 18 KB em 64 MB. Nao compensa o risco de
            // o R8 remover algo alcancado por reflexao nos plugins de
            // notificacao e de banco.
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
