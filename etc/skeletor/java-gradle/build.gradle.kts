import javax.inject.Inject

plugins {
    java
    application
}

repositories {
    jcenter()
    mavenCentral()
}

dependencies {
    // testImplementation("junit:junit:4.12")
    testImplementation("org.junit.jupiter:junit-jupiter-api:5.5.2")
    testRuntimeOnly("org.junit.jupiter:junit-jupiter-engine:5.5.2")
}

tasks.withType<JavaCompile>().configureEach {
    options.compilerArgs.add("-Xlint:unchecked")
    options.compilerArgs.add("-Xlint:deprecation")
}
val test: Test by tasks
test.useJUnitPlatform()

sourceSets {
    listOf(main, test).map {
        it {
            java.setSrcDirs(listOf("$projectDir/src/$name"))
            resources.setSrcDirs(listOf("$projectDir/etc/$name", "$projectDir/etc/all"))
        }
    }
}

application { mainClassName = "__PROJECT-NAME__.__MAIN-CLASS__" }
