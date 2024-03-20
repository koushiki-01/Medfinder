<%@page import="java.util.logging.Logger"%>
<%@page import="java.util.logging.Level"%>
<%@page import="javax.mail.MessagingException"%>
<%@page import="javax.mail.Transport"%>
<%@page import="javax.mail.internet.InternetAddress"%>
<%@page import="javax.mail.internet.MimeMessage"%>
<%@page import="javax.mail.Message"%>
<%@page import="javax.mail.PasswordAuthentication"%>
<%@page import="javax.mail.Session"%>
<%@page import="java.util.Properties"%>
<%@page import="oracle.jdbc.OracleResultSet"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStream"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%@page import="Webpack.hash"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    String email, oldpass, newpass, userType, table, query, databasePass;
    String vto, vsubject, vbody;
    OracleConnection oconn;
    OraclePreparedStatement ops;
    OracleResultSet ors = null;
    HttpSession sess;            
    String oconnUrl, oconnUsername, oconnPassword;
    String mailUsername, mailPassword;
%>
<%
    try {
        InputStream input = application.getResourceAsStream("/WEB-INF/db.properties");
        Properties props = new Properties();
        props.load(input);
        oconnUrl = "jdbc:oracle:thin:@" + props.getProperty("hostname") + ":"
            + props.getProperty("port") + ":" + props.getProperty("SID");
        oconnUsername = props.getProperty("username");
        oconnPassword = props.getProperty("password");
    } catch (IOException ex) {
        out.println("Error: " + ex.getMessage());
    }
    try (InputStream mailInput = application.getResourceAsStream("/WEB-INF/mail.properties")) {
        Properties mailProps = new Properties();
        mailProps.load(mailInput);
        mailUsername = mailProps.getProperty("username");
        mailPassword = mailProps.getProperty("password");
        } catch (IOException ex) {
            throw new ServletException(ex);
    }
    
    if(request.getParameter("submit")!=null)
    {
        if(request.getParameter("new-password").equals(request.getParameter("confirm-password")))
        {
            sess = request.getSession(false);
            if(sess!=null){
                email = sess.getAttribute("email").toString();
                userType = sess.getAttribute("userType").toString();                    
            }
            if(userType.equals("CUSTOMER"))
                table = "CUSTOMER";
            if(userType.equals("PHARMACY"))
                table = "PHARMACY";
            oldpass = request.getParameter("current-password");
            oldpass = hash.passwordHash(oldpass);
            newpass = request.getParameter("new-password");
            newpass = hash.passwordHash(newpass);
            DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
            oconn = (OracleConnection) DriverManager.getConnection(oconnUrl,oconnUsername,oconnPassword);
            query = "SELECT * FROM "+table+" WHERE EMAIL=?";
            ops = (OraclePreparedStatement) oconn.prepareStatement(query);
            ops.setString(1,email);
            ors = (OracleResultSet)ops.executeQuery();
            ors.next();
            databasePass = ors.getString("PASSWORD");
            if(oldpass.equals(databasePass)){
                query = "UPDATE "+table+" SET PASSWORD=? WHERE EMAIL=?";
                ops = (OraclePreparedStatement) oconn.prepareStatement(query);
                ops.setString(1,newpass);
                ops.setString(2,email);
                int x = ops.executeUpdate();
                if(x>0) {
                    // Only invalidate session if password was reset successfully.
                    sess.invalidate();
                    out.println("<h3 style='color:green'>Data inserted Successfully....</h3>");
%>
                <script>
                    // Password changed successfully.
                    location.href="http://localhost:8080/MinorWebApp/StatPages/login.html?response=change-password-success";
                </script>
<%
                    vto = email;
                    vsubject = "MedFinder Password Changed";
                    vbody = "Your password was recently changed.\n" +
                            "If this was you, you can safely ignore this email.\n" +
                            "If not, then please contact support immediately.\n" +
                            "\n" +
                            "You can now login using the new password.\n" +
                            "Login link: http://localhost:8080/MinorWebApp/StatPages/login.html";
                    final String username = mailUsername;
                    final String password = mailPassword;

                    Properties props = new Properties();
                    props.put("mail.smtp.auth","true");
                    props.put("mail.smtp.starttls.enable","true");
                    props.put("mail.smtp.host","smtp.gmail.com");
                    props.put("mail.smtp.port","587");

                    Session session1 = Session.getInstance(props, new javax.mail.Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication(){
                        return new PasswordAuthentication(username,password);
                    }});
                    try {
                        Message message = new MimeMessage(session1);
                        message.setFrom(new InternetAddress(username));
                        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(vto));
                        message.setSubject(vsubject);                       
                        message.setText(vbody);
                        Transport.send(message);
                        //response.sendRedirect("http://localhost:8080/WebApp1/PageServes/VerifyOTP.jsp");
                    } catch (MessagingException ex) {
                        out.println("<h2 style='color: red'>"+ex.getMessage()+"</h2>");
                    }                   
                }
                else
                    out.println("<h3 style='color:Red'>No Data Changes....</h3>");  
            }else{
%>
            <script>
                // Incorrect old password.
                location.href="http://localhost:8080/MinorWebApp/PageServes/changePassword.jsp?response=wrong-password";
            </script>
<%
            }
            ops.close();
            oconn.close();
        }
        else
        {
%>
            <h3 style="color: red">Password did not match, try again!</h3>
<%
        }
    }

%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
    <link rel="icon" href="../media/favion.ico" type="image/x-icon">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="../stylesheet/main-style.css">
        <title>Change Password</title>
        <script>
            window.onload = function() {
                document.forms['change-password'].addEventListener('submit', function(event) {
                    if(!validateForm()) {
                        event.preventDefault();
                    } else {
                        window.location.hash = '';
                    }
                });
            };
            function validateForm() {
                var currentPassword = document.forms['change-password']['current-password'].value;
                var newPassword = document.forms['change-password']['new-password'].value;
                var confirmPassword = document.forms['change-password']['confirm-password'].value;

                if(currentPassword === "" || newPassword === "" || confirmPassword === "") {
                    showError("All fields are required.");
                    return false;
                }
                else if(newPassword !== confirmPassword) {
                    showError("Passwords do not match.");
                    return false;
                }
                else if(newPassword === currentPassword) {
                    showError("New password cannot be the same as old password.");
                    return false;
                }
                    else if(newPassword.length < 8) {
                    showError("New password must be at least 8 characters long.");
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
            <a href="http://localhost:8080/MinorWebApp/SessLogOut">Log Out</a>
            </nav>
        </header>
        <main>
            <div class="form-container">
                <div class="form-box">
                    <form name="change-password" method="POST">
                    <!--<form name="change-password" method="POST" action="http://localhost:8080/MinorWebApp/ChangePassword">--> 
                        <h2>CHANGE PASSWORD</h2>
                        <br>
                        <div id="error-alert"></div>
                        <div id="success-alert"></div>
                        <br>
                        <div class="input-group">
                            <label for="current-password">Current Password:</label>
                            <input type="password" name="current-password" placeholder="********">
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="new-password">New Password:</label>
                            <input type="password" name="new-password" placeholder="********">
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="confirm-password">Confirm New Password:</label>
                            <input type="password" name="confirm-password" placeholder="********">
                        </div>                         
                        <br>    
                        <div class="input-group button-group">
                            <label></label>
                            <button type="submit" class="button-80" name="submit">Submit</button>
                        </div>                   
                        <br>
                        <div class="form-box-links">
                        Forgot password? <a href="http://localhost:8080/MinorWebApp/StatPages/ForgotPassword.html">Reset password</a><br>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </body>
    <script src="/MinorWebApp/scripts/showResponse.js"></script>
    <script>
        let params = (new URL(document.location)).searchParams;
        let response = params.get("response");

        if (response == "wrong-password") {
            showError("Incorrect old password.");
            params.delete('response');
            window.history.replaceState({}, document.title, url.toString());
        }
    </script>
    <footer>
        <a href="https://www.facebook.com" target="_blank"><img src="../media/facebook-icon.png" class="social-icon" alt="Facebook"></a>
        <a href="https://www.twitter.com" target="_blank"><img src="../media/twitter-icon.ico" class="social-icon" alt="Twitter"></a>
        <a href="https://www.pinterest.com" target="_blank"><img src="../media/pinterest-icon.png" class="social-icon" alt="Pintrest"></a>
    </footer>
</html>
