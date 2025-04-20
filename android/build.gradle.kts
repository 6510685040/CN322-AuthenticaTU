allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val sharedBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()

subprojects {
    val subprojectBuildDir = sharedBuildDir.dir(project.name)
    project.layout.buildDirectory.set(subprojectBuildDir)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
