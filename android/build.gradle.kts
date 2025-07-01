buildscript {
    val kotlinVersion = "1.9.0" // Define the Kotlin version explicitly
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:7.3.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = File("../build")
subprojects {
    project.buildDir = File(rootProject.buildDir, project.name)
}
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            configure<com.android.build.gradle.BaseExtension> {
                compileSdkVersion(34) // Updated to 34 to match dependency requirements
                buildToolsVersion = "34.0.0"
            }
        }
    }
}