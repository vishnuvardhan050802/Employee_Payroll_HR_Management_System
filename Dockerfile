# Build and test the WAR with Java 17 and Maven.
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY pom.xml .
COPY src ./src
RUN mvn --batch-mode clean package

# Run the WAR in a Java 17 Tomcat 10.1 container.
FROM tomcat:10.1.61-jdk17-temurin
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /workspace/target/employee-payroll-hr.war /usr/local/tomcat/webapps/ROOT.war
COPY deploy/start-tomcat.sh /usr/local/bin/start-tomcat.sh
RUN chmod +x /usr/local/bin/start-tomcat.sh
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/start-tomcat.sh"]
