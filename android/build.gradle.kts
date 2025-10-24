import org.gradle.api.tasks.Delete
import org.gradle.api.tasks.compile.JavaCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Rediriger le dossier de build vers le dossier parent
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    project.evaluationDependsOn(":app")

    // ⚡ Force toutes les compilations Java à utiliser Java 17
    tasks.withType<JavaCompile> {
        sourceCompatibility = "17" // String obligatoire ici
        targetCompatibility = "17" // String obligatoire ici
        options.compilerArgs.add("-Xlint:-options") // supprime les warnings "obsolete"
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
