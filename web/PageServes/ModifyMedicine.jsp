<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStream"%>
<%@page import="oracle.jdbc.OracleResultSetMetaData"%>
<%@page import="oracle.jdbc.OracleResultSet"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%! 
    OracleConnection oconn;
    OraclePreparedStatement ops;
    OracleResultSet ors; //Store the data in the webpage from oracle
    OracleResultSetMetaData orsm;
    String query, btnval, table, mid, mname, mcat;
    java.util.Properties props = new java.util.Properties();
    HttpSession sess;
    String oconnUrl, oconnUsername, oconnPassword;
%>
<%
    try{
        InputStream input = application.getResourceAsStream("/WEB-INF/db.properties");
        props.load(input);
        oconnUrl = "jdbc:oracle:thin:@" + props.getProperty("hostname") + ":"
            + props.getProperty("port") + ":" + props.getProperty("SID");
        oconnUsername = props.getProperty("username");
        oconnPassword = props.getProperty("password");
    } catch (IOException ex) {
        out.println("Error: " + ex.getMessage());
    }
    if(request.getParameter("submit")==null){
        btnval = request.getParameter("Modify");
        int i = btnval.indexOf(",");
        table = btnval.substring(0,i);
        mid = btnval.substring(i+1);
    }
    try{
        DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
        oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);        
        query = "SELECT * FROM MEDICINE WHERE MID = ?";
        ops = (OraclePreparedStatement) oconn.prepareCall(query);
        ops.setString(1, mid);
        ors = (OracleResultSet) ops.executeQuery();
        ors.next();
        mname = ors.getString("MNAME");
        mcat = ors.getString("MCAT");
        
        if(request.getParameter("submit")!=null){
            mname = request.getParameter("mname");
            mcat = request.getParameter("mcategory");
            query = "UPDATE MEDICINE SET MNAME = ?, MCAT = ? WHERE MID = ?";
            ops = (OraclePreparedStatement) oconn.prepareCall(query);
            ops.setString(1, mname);
            ops.setString(2, mcat);
            ops.setString(3, mid);
            int x = ops.executeUpdate();
            if(x>0){
    %>
                <script>
                    // Modified successfully
                    location.href="http://localhost:8080/MinorWebApp/PageServes/medicine.jsp?response=modify-success";
                </script>
    <%
            }
            else{
    %>
            <script>
                // Failed to modify
                location.href="http://localhost:8080/MinorWebApp/PageServes/medicine.jsp?response=modify-fail";
            </script>
    <%
            }
            oconn.close();
            ops.close();
        }
    }catch(SQLException ex){
        out.println("<h2 style='color:red'>Error is: "+ ex.toString() + "</h2>");
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
    <link rel="icon" href="../media/favion.ico" type="image/x-icon">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="../stylesheet/main-style.css">
        <title>Edit Medicine</title>
        <script src="/MinorWebApp/scripts/showResponse.js"></script>
        <script>
            window.onload = function() {
                // Auto select the old value.
                let mcat = "<%=mcat%>";
                document.getElementById('mcategory').value = mcat;
                
                document.forms['register'].addEventListener('submit', function(event) {
                    if(!validateForm()) {
                        event.preventDefault();
                    } else {
                        window.location.hash = '';
                    }
                });
            };
            
            function validateForm() {
                var mname = document.forms['register']['mname'].value;
                var mcat = document.forms['register']['mcat'].value;
        
                if(mname === "" || mcat === "") {
                    showError("All fields are required.");
                    return false;
                }
                return true;
            }
        </script>   
    </head>
    <body>
    <header>
        <img src="../media/logo.png" class="logo">
        <span class="heading">MedFinder</span>
        <nav class="navbar">
        <a href="http://localhost:8080/MinorWebApp/StatPages/admin-database.html">Home</a>
        <a href="http://localhost:8080/MinorWebApp/StatPages/about.html">About Us</a>
        <a href="http://localhost:8080/MinorWebApp/PageServes/FeedBack.jsp">Feedback</a>
        <div class="navbar-dropdown">
            <a class="navbar-dropdown-button">Settings</a>
            <div class="navbar-dropdown-content">
                <a href="http://localhost:8080/MinorWebApp/SessLogOut">Log Out</a>
                <a href="http://localhost:8080/MinorWebApp/PageServes/changePassword.jsp">Change Password</a>
            </div>
        </div>
        </nav>
    </header>
    <main>
        <div class="form-container">
            <div class="form-box">
                <form method="POST" name="register">
                    <h2>Edit Medicine Details</h2>
                    <br>
                    <div id="error-alert"></div>                      
                    <br>
                    <div class="input-group">
                        <label for="mid">Medicine ID:</label>
                        <input type="text" id="mid" name="mid" value="<%=mid%>" readonly/>
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="mname">Medicine Name:</label>
                        <input type="text" id="mname" name="mname" value="<%=mname%>">
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="mcategory">Medicine Category:</label>
                        <select id="mcategory" name="mcategory">
                            <option value="" disabled hidden>Select a Category</option>
                            <option value="TABLET">Tablet</option>
                            <option value="INJECTION">Injection</option>
                            <option value="SYRUP">Syrup</option>
                            <option value="CREAM">Cream</option>
                            <option value="SPRAY">Spray</option>
                            <option value="POWDER">Powder</option>
                        </select>
                    </div>
                    <br>    
                    <div class="input-group button-group">
                        <label></label>
                        <button type="submit" name="submit" class="button-80">Submit</button>
                        <button type="reset" class="button-80">Clear</button>
                </div>
                </form>
            </div>
        </div>
    </main>
<footer>
    <a href="https://www.facebook.com" target="_blank"><img src="../media/facebook-icon.png" class="social-icon" alt="Facebook"></a>
    <a href="https://www.twitter.com" target="_blank"><img src="../media/twitter-icon.ico" class="social-icon" alt="Twitter"></a>
    <a href="https://www.pinterest.com" target="_blank"><img src="../media/pinterest-icon.png" class="social-icon" alt="Pintrest"></a>
</footer>
</body>
</html>

