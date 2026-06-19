buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 1. Cấu hình phân tách thư mục build cho dự án gốc (Gốc ổ D)
val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // 2. GIẢI PHÁP ĐẶC TRỊ LỖI DIFFERENT ROOTS:
    // Nếu là các plugin của bên thứ ba nằm ở ổ C (như google_sign_in),
    // ta ép nó dùng thư mục build nội bộ của chính nó, không nhảy sang ổ D.
    if (project.projectDir.toString().contains("pub.dev") || !project.projectDir.toString().contains(rootProject.projectDir.parent)) {
        project.layout.buildDirectory.value(project.layout.projectDirectory.dir("build"))
    } else {
        // Nếu là code app của bạn ở ổ D, giữ nguyên cấu trúc Flutter cũ
        val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// 3. Khóa triệt để các tác vụ UnitTest chạy ngầm của thư viện
subprojects {
    tasks.configureEach {
        if (name.contains("UnitTest", ignoreCase = true) || name.contains("AndroidTest", ignoreCase = true)) {
            enabled = false
        }
    }
}