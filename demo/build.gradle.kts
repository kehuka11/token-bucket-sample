plugins {
	java
	id("org.springframework.boot") version "3.5.5"
	id("io.spring.dependency-management") version "1.1.7"
}

group = "token.bucket"
version = "0.0.1-SNAPSHOT"
description = "token bucket sample"

java {
	toolchain {
		languageVersion = JavaLanguageVersion.of(21)
	}
}

configurations {
	compileOnly {
		extendsFrom(configurations.annotationProcessor.get())
	}
}

repositories {
	mavenCentral()
}

dependencies {
	implementation("org.springframework.boot:spring-boot-starter-data-redis")
	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("org.mybatis.spring.boot:mybatis-spring-boot-starter:3.0.5")
	
	// Spring Boot AOP
	implementation("org.springframework.boot:spring-boot-starter-aop")
	
	// Spring Boot Actuator
	implementation("org.springframework.boot:spring-boot-starter-actuator")
	
	// Spring Boot Data JPA
	implementation("org.springframework.boot:spring-boot-starter-data-jpa")
	
	// H2 Database (in-memory)
	runtimeOnly("com.h2database:h2")
	
	// Bucket4j dependencies
	implementation("com.bucket4j:bucket4j_jdk17-core:8.15.0")
	implementation("com.bucket4j:bucket4j_jdk17-redis-common:8.15.0")
	implementation("com.bucket4j:bucket4j_jdk17-lettuce:8.15.0")
	
	compileOnly("org.projectlombok:lombok")
	annotationProcessor("org.projectlombok:lombok")
	testImplementation("org.springframework.boot:spring-boot-starter-test")
	testImplementation("org.mybatis.spring.boot:mybatis-spring-boot-starter-test:3.0.5")
	testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

tasks.withType<Test> {
	useJUnitPlatform()
}
