# Employee Payroll & HR Management System

A local MCA learning project built with Java 17, Maven, Jakarta Servlet/JSP, JDBC, MySQL 8 and Tomcat 10.1. It uses fictional demo records. It is not a production payroll or statutory compliance system.

## What is implemented

- BCrypt login, session rotation, 30-minute idle timeout, CSRF tokens on write forms, output escaping and server-side role checks.
- No public registration page is provided. The first administrator is created locally with `AdminSetup`; lost admin passwords can be changed with `AdminPasswordReset`.
- Database-backed dashboard counts.
- Create/list employees and departments; record/list attendance; submit/review leave requests; add/list effective salary structures; generate/list monthly payroll; view/print saved payslips; basic employee, attendance and payroll summaries.
- Unique database constraints prevent duplicate employee code, employee/date attendance, and employee/month payroll.
- Payroll uses `BigDecimal`: gross = basic + HRA + allowances + bonus; net = gross − explicit deductions. Components cannot be negative and deductions cannot exceed gross. This does not calculate Indian income tax, PF, ESI or other statutory rules.
- JUnit tests cover calculation totals, zero components, rounding, negative input, zero-net boundaries and negative-net rejection.

This first version keeps request handling in one readable servlet instead of the separate DAO/service package layout in the PRD. It does not yet include editing/deactivating employee or department records, employee self-service, search/filter controls across all lists, salary-structure editing/end dates, or the requested audit-log workflow. Do not treat those areas as implemented.

## 1. Check Java and Maven

Open the VS Code terminal (Terminal → New Terminal) and run:

```powershell
java -version
mvn -version
```

Use Java 17. The commands above were available in the development workspace during project creation.

## 2. Install MySQL 8

Install MySQL Community Server 8 and optionally MySQL Workbench from the official MySQL downloads page. Start the MySQL service. In Workbench, connect to your local server. Alternatively, open MySQL Command Line Client.

## 3. Create schema and fictional sample rows

From the project folder, run these in PowerShell. `cmd /c` runs the input redirection in Windows Command Prompt, where `<` is supported:

```powershell
cmd /c "mysql -u root -p < database\schema.sql"
cmd /c "mysql -u root -p < database\sample_data.sql"
```

Enter your local MySQL administrator password when prompted. Run schema first. The sample script adds departments, two fictional employees and example salary structures; it does not create a login account.

Create an application database user in MySQL Workbench or the MySQL command line. Choose your own password and grant access only to this local demo database:

```sql
CREATE USER 'payroll_app'@'localhost' IDENTIFIED BY 'choose-your-own-local-password';
GRANT SELECT, INSERT, UPDATE, DELETE ON payroll_hr_demo.* TO 'payroll_app'@'localhost';
```

If the user already exists, do not run the `CREATE USER` line again.

## 4. Configure database environment

Set these in the same PowerShell terminal before building/deploying or launching the setup utility. Change the password to the one you chose above:

```powershell
$env:DB_URL = 'jdbc:mysql://localhost:3306/payroll_hr_demo?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata'
$env:DB_USERNAME = 'payroll_app'
$env:DB_PASSWORD = 'your-local-password'
```

Environment variables set this way apply to that terminal and processes started from it. Set them again in any new terminal. For Tomcat, start Tomcat from a terminal that has these variables set. Never commit real credentials.

## 5. Create the first administrator

Build the classes first (step 6), then, from the project folder and same configured terminal, run:

```powershell
mvn --% -Dmaven.repo.local=.maven-cache dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
$appClasspath = "target/classes;$(Get-Content target/classpath.txt -Raw)"
java -cp $appClasspath com.employee.servlet.AdminSetup
```

Run this in Windows Terminal or the VS Code terminal (not the Output panel). The utility prompts for a username and password without displaying the password, requires 12 or more characters, confirms it, and stores only a BCrypt hash. It inserts an ADMIN account. Do not run it again with an existing username.

If you forget an administrator password, use `com.employee.servlet.AdminPasswordReset` with the same Java classpath command shown above. It prompts for the existing administrator username and a new password, then updates only that active ADMIN account.

## 6. Test and build the WAR

```powershell
mvn --% -Dmaven.repo.local=.maven-cache clean test package
```

`BUILD SUCCESS` means Java compilation, the unit tests and WAR packaging succeeded. `BUILD FAILURE` means inspect the first Maven error; resolve dependency download or compilation problems before deploying. The generated file is `target/employee-payroll-hr.war`.

The `.maven-cache` option keeps downloaded dependencies in this project. It avoids Maven trying to write to a restricted `C:\.m2` folder on some Windows installations. The `--%` is PowerShell's stop-parsing marker for passing Maven's `-D` option safely.

## 7. Install and start Tomcat 10.1

Download and extract Apache Tomcat 10.1. In a new PowerShell terminal, set the three database environment variables from step 4, then deploy and start:

```powershell
$tomcat = 'C:\path\to\apache-tomcat-10.1'
$env:JAVA_HOME = 'C:\path\to\jdk-17'
$env:CATALINA_HOME = $tomcat
$env:CATALINA_BASE = $tomcat
Copy-Item target/employee-payroll-hr.war "$tomcat\webapps\employee-payroll-hr.war"
& "$tomcat\bin\startup.bat"
```

Replace the example Tomcat path with the folder where you extracted it. The WAR filename sets the context path, so open `http://localhost:8080/employee-payroll-hr/`. Sign in with the administrator username/password created in step 5.

To stop Tomcat, run its `bin\shutdown.bat`. Check `logs\catalina*.log` if deployment fails.

## Troubleshooting

- **`java` or `mvn` not recognized:** install the JDK/Maven and add their `bin` folders to Windows `PATH`; open a new terminal and rerun the version command.
- **Connection refused:** start the MySQL service and confirm the host/port in `DB_URL`.
- **Access denied:** confirm the database username/password and that the MySQL account host is `localhost`.
- **Login says credentials are invalid but they are correct:** check Tomcat's `logs\localhost*.log`. If it reports `No suitable driver found`, rebuild and redeploy the WAR so the MySQL JDBC driver loads from the web application.
- **Missing tables:** run `database/schema.sql`, then `database/sample_data.sql`.
- **HTTP 404:** confirm Tomcat started and use the context path matching the WAR filename.
- **HTTP 500 or database page error:** inspect Tomcat logs, then verify environment variables were present in the terminal that started Tomcat.
- **Port already in use:** stop the other service using port 8080 or configure a different Tomcat connector port.
- If you need to keep the service on 8080, edit Tomcat's `conf/server.xml`, change the HTTP Connector `port="8080"` to an unused port such as `8081`, restart Tomcat, and use that port in the URL.
- **Java or Servlet mismatch:** use Java 17 and Tomcat 10.1; Tomcat 9 uses the older `javax.servlet` APIs and is incompatible.
- **WAR deployment failure:** inspect Tomcat logs, verify the WAR was copied completely, and rebuild with `mvn clean test package`.

## Verification status and limits

Build and unit-test status should be based on the Maven command run in this workspace. MySQL and Tomcat integration, administrator creation, and browser behavior require local services and have not been verified just by compiling. The app is for local education; it has no statutory payroll rules, production security review, complete requested feature set, or hardened deployment configuration.

## Docker and a shareable hosted link

This is a Java Servlet application. Static hosting services such as Netlify serve static files and do not run this WAR/Tomcat backend. The included Dockerfile packages the app with Tomcat 10.1 and uses the host-provided `PORT`. In the container the app is installed at `/`, so its sign-in page is `/login`.

### Run the full demo locally with Docker Desktop

1. Copy `.env.example` to `.env` and set two different local passwords for `DB_PASSWORD` and `MYSQL_ROOT_PASSWORD`.
2. From the project folder, run:

   ```powershell
   docker compose up --build
   ```

3. Open `http://localhost:8080/login`. The compose file creates a separate MySQL container, loads the schema and fictional demo records on first start, and keeps database data in a Docker volume.
4. Stop the containers with `Ctrl+C`, then run `docker compose down` if needed. Avoid `docker compose down -v` unless you intend to erase the Docker database volume.

### Publish a free demo link with Render and Aiven MySQL

This option uses Render's free Docker web service and Aiven's free MySQL service. Aiven currently offers a $0 MySQL tier with 1 GB storage, 1 GB RAM, no credit card, and no time limit. It can power off unused services, which can be powered back on. Render gives the app a public `onrender.com` URL, but its free web service sleeps after 15 minutes without a request and can take about a minute to wake; it can restart and has 750 free instance hours per month. These limits make the setup suitable for a demo, not a production payroll service. See [Aiven's free MySQL limits](https://aiven.io/docs/products/mysql/concepts/mysql-free-tier) and [Render's free service limits](https://render.com/docs/free).

1. Push this project to a GitHub repository. It can be private; a public website does not require public source code.
2. In Aiven, create a **free MySQL** service. Copy its host, port, database name, username, and password from the service overview. The account does not need a payment card for the free tier.
3. Connect with a MySQL client using the Aiven connection values and TLS. Run `database/schema.sql`, followed by `database/sample_data.sql`, once. The schema creates `payroll_hr_demo`; do not reinitialize an existing database.
4. In Render, create a **Web Service** from the GitHub repository and choose the **Free** instance plan. Render detects the included Dockerfile. Add these environment variables in the service settings, replacing the placeholders with the Aiven values:

   ```text
   DB_URL=jdbc:mysql://<Aiven-host>:<Aiven-port>/payroll_hr_demo?sslmode=require&serverTimezone=Asia/Kolkata
   DB_USERNAME=<Aiven-username>
   DB_PASSWORD=<Aiven-password>
   ```

   Keep credentials in Render's environment settings; never commit them to GitHub. The Docker startup script uses Render's `PORT` setting.
5. Create the first admin with `AdminSetup` on your computer, after temporarily setting the same three `DB_*` environment variables to the Aiven connection values. Then open the Render service's `onrender.com` URL followed by `/login`.

For GitHub, use GitHub Desktop or initialize and push the local project with Git. GitHub's [official guide for adding a local project](https://docs.github.com/en/repositories/creating-and-managing-repositories/adding-locally-hosted-code-to-github) covers both approaches.

**Demo-only:** use fictional data and a new demo password. This app has not had a production security review and must not contain real employee records, payroll data, or real credentials.
