<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStream"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%@page import="Webpack.hash"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    String email, pass, userType, table, query;
    OracleConnection oconn;
    OraclePreparedStatement ops;
    HttpSession sess, sess1;
    java.util.Properties props = new java.util.Properties();
    String oconnUrl, oconnUsername, oconnPassword;
%>
<%
    try {
        InputStream input = application.getResourceAsStream("/WEB-INF/db.properties");
        props.load(input);
        oconnUrl = "jdbc:oracle:thin:@" + props.getProperty("hostname") + ":"
            + props.getProperty("port") + ":" + props.getProperty("SID");
        oconnUsername = props.getProperty("username");
        oconnPassword = props.getProperty("password");
    } catch (IOException ex) {
        out.println("Error: " + ex.getMessage());
    }
    
    if(request.getParameter("bConfirm")!=null)
    {
        if(request.getParameter("tpass").equals(request.getParameter("cpass")))
        {
            sess = request.getSession(false);
            pass = request.getParameter("tpass");
            pass = hash.passwordHash(pass);
            email = sess1.getAttribute("email").toString();
            DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
            oconn = (OracleConnection) DriverManager.getConnection(oconnUrl,oconnUsername,oconnPassword);
            if(sess!=null)
                userType = sess.getAttribute("userType").toString();
            if(userType.equals("CUSTOMER"))
                table = "CUSTOMER";
            if(userType.equals("ADMIN"))
                table = "ADMIN";
            if(userType.equals("PHARMACY"))
                table = "PHARMACY";
            query = "UPDATE "+table+" SET PASSWORD=? WHERE EMAIL=?";
            ops = (OraclePreparedStatement) oconn.prepareStatement(query);
            ops.setString(1,pass);
            ops.setString(2,email);
            int x = ops.executeUpdate();
            if(x>0) {
%>
                <script>
                    // Password reset successful
                    location.href="http://localhost:8080/MinorWebApp/StatPages/login.html?response=reset-password-success";
                </script>
<%
            } 
            else
                out.println("<h3 style='color:Red'>No Data Changes....</h3>");
            ops.close();
            oconn.close();
            sess.invalidate();

        }
        else
        {
%>
    // Passwords do not match.
    <script>
        location.href="http://localhost:8080/MinorWebApp/PageServes/NewPassword.jsp?response=password-mismatch";
    </script>
<%
        }
    }
    else
    {
        email = request.getParameter("pemail");
        sess1 = request.getSession(true);
        sess1.setAttribute("email", email);                  
    }   
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
    <link rel="icon" href="../media/favion.ico" type="image/x-icon">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="../stylesheet/main-style.css">
        <title>Reset Password</title>
        <script>
            window.onload = function() {
                document.forms['reset-password'].addEventListener('submit', function(event) {
                    if(!validateForm()) {
                        event.preventDefault();
                    } else {
                        window.location.hash = '';
                    }
                });
            };
            
            function validateForm() {
                var password = document.forms['reset-password']['tpass'].value;
                var newPassword = document.forms['reset-password']['npass'].value;
        
                if(password === "" || newPassword === "") {
                    showError("All fields are required.");
                    return false;
                }
                if(password.length < 8) {
                    showError("Password must be at least 8 characters.");
                    return false;
                }
                if(password !== newPassword) {
                    showError("Passwords do not match.");
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
        <a href="http://localhost:8080/MinorWebApp/StatPages/index.html">Home</a>
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
            <div class="form-box" style="width: 38%;">
                <form method="POST" name="reset-password">
                    <h2>NEW PASSWORD</h2>
                    <br>
                    <div id="error-alert"></div>
                    <br>
                    <div class="input-group">
                        <label for="tpass">New Password:</label>
                        <input type="password" name="tpass" placeholder="********">
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="cpass">Confirm Password:</label>
                        <input type="password" name="cpass" placeholder="********">
                    </div>
                    <br><br>
                    <div class="input-group button-group">
                        <label></label>
                        <button type="submit" class="button-80" name="bConfirm">Reset Password</button>
                    </div> 
                    <br>
                    <div class="form-box-links">
                    Remember your password? <a href="login.html">Log in</a><br>
                    New? <a href="register.html">Sign up</a>
                    </div>
                </form>
            </div>
        </div>
        </main>
        <script src="/MinorWebApp/scripts/showResponse.js"></script>
        <script>
            let params = (new URL(document.location)).searchParams;
            let response = params.get("response");
    
            if (response == "password-mismatch") {
                showError("Passwords do not match.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
        </script>
        <footer>
            <a href="https://www.facebook.com" target="_blank"><img src="../media/facebook-icon.png" class="social-icon" alt="Facebook"></a>
            <a href="https://www.twitter.com" target="_blank"><img src="../media/twitter-icon.ico" class="social-icon" alt="Twitter"></a>
            <a href="https://www.pinterest.com" target="_blank"><img src="../media/pinterest-icon.png" class="social-icon" alt="Pintrest"></a>
        </footer>
    </body>
</html>
