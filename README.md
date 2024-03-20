# MinorWebApp
A Java web application.

### Requirements
Or more specifically the software this project was built on.
1. JDK 8
2. NetBeans 8.2
3. Oracle 10G

### Run the project
1. Clone the project: `git clone https://github.com/koushiki-01/Medfinder.git`
2. Under `/WEB/WEB-INF` create two files:
   
    i. `db.properties`
    ```
    hostname=hostname
    port=1521
    SID=orcl
    username=sql_username
    password=sql_password
    ```
    ii. `mail.properties`
    ```
    username=email@domain.com
    password=yourAppPassword
    ```
4. Copy the two files to `src/java` as well.
5. Open folder as a project in NetBeans.
6. Run from `StatPages/login.html`.
