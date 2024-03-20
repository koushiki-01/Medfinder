<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStream"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="oracle.jdbc.OracleResultSet"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    String email, ques, ans, userType, table, query;
    OracleConnection oconn;
    OraclePreparedStatement ops;
    OracleResultSet ors = null;
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

    email = request.getParameter("pemail");
    DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
    oconn = (OracleConnection) DriverManager.getConnection(oconnUrl,oconnUsername,oconnPassword);
    HttpSession sess = request.getSession(false);
    if(sess!=null)
    {
        userType = sess.getAttribute("userType").toString();
    }
    if(userType.equals("ADMIN"))
        table = "ADMIN";
    else if(userType.equals("CUSTOMER"))
        table = "CUSTOMER";
    else if(userType.equals("PHARMACY"))
        table = "PHARMACY";
    query = "SELECT * FROM "+table+" WHERE EMAIL=?";
    ops = (OraclePreparedStatement) oconn.prepareStatement(query);
    ops.setString(1,email);
    ors = (OracleResultSet) ops.executeQuery();
    if(ors.next())
    {
        ques = ors.getString("SQUES");
        ans = ors.getString("SANS");
    }
    else
    {
%>
    <script>
        // Do not try any malaligned URL. You can only use the link received in email
        location.href = "http://localhost:8080/MinorWebApp/StatPages/ForgotPassword.html?response=bad-link";
    </script>
<%
    }
    ops.close();
    oconn.close();
    if(request.getParameter("bVerify")!=null)
    {
        if(request.getParameter("tbAns").equalsIgnoreCase(ans))
        {
%>
        <script>
        // showError("Security Answer verified Successfully!!!");
            location.href="http://localhost:8080/MinorWebApp/PageServes/NewPassword.jsp?pemail=<%=email%>";
        </script>
<%
        }
        else
        {
%>
        <script>
            // Incorrect answer
            location.href="http://localhost:8080/MinorWebApp/PageServes/VerifyQuestion.jsp?pemail=<%=email%>&response=incorrect-answer";
        </script>
<%
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
    <link rel="icon" href="../media/favion.ico" type="image/x-icon">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Verify Question</title>
        <link rel="stylesheet" href="../stylesheet/main-style.css">
        <style>
            .form-box {
                width: 20%;
            }
        </style>
        <script>
            window.onload = function() {
                document.forms['verify-question-form'].addEventListener('submit', function(event) {
                    if(!validateForm()) {
                        event.preventDefault();
                    }
                });
            };

            function validateForm() {
                var sans = document.forms['verify-question-form']['tbAns'].value;

                if(sans === "") {
                    showError("Please enter a value.");
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
            <a href="http://localhost:8080/MinorWebApp/StatPages/login.html">Login</a>
            </nav>
        </header>
        <main>
            <div class="form-container">
                <div class="form-box" id="form-login-container">
                    <form method="POST" name="verify-question-form" action="http://localhost:8080/MinorWebApp/PageServes/VerifyQuestion.jsp?pemail=<%=email%>">
                        <h2>SECURITY VERIFICATION FORM</h2>
                        <br>
                        <div id="error-alert"></div>
                        <br>
                        <div class="input-group">
                            <label for="tbQues">Security Question:</label>
                            <input type="text" name="tbQues" id="tbQues" placeholder="Question" value="<%=ques%>" readonly>
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="tbAns">Answer:</label>
                            <input type="text" name="tbAns" id="tbAns" placeholder="Answer">
                        </div>
                        <br>
                        <div class="input-group button-group">
                            <button type="submit" name="bVerify" class="button-80">Verify</button>
                        </div>
                    </form>
                </div>
            </div>
        </main>
        <script src="/MinorWebApp/scripts/showResponse.js"></script>
        <script>
            let params = (new URL(document.location)).searchParams;
            let response = params.get("response");
    
            if (response == "incorrect-answer") {
                showError("Incorrect answer.");
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
