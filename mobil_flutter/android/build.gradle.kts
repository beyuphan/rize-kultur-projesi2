// Dosya Yolu: android/build.gradle.kts

// ===== EKSİK OLAN VE EKLENEN BLOK =====
plugins {
    id("com.android.application") version "8.7.3" apply false  // Sürümü düzelttik
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
   
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}