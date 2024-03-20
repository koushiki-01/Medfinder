<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    String otp,email;
    HttpSession sess;
%>
<%
    sess = request.getSession(false);
    if(sess!=null){
        otp = sess.getAttribute("otp").toString();
        email = sess.getAttribute("email").toString();
    } 
    if(request.getParameter("submit")!=null){
        if(request.getParameter("Totp").equals(otp))
        {
%>
            <script>
                // Correct OTP to place order .
                location.href="http://localhost:8080/MinorWebApp/PlaceOrder";
            </script>
<%
        }
        else{
%>
            <script>
                // Incorrect OTP.
                location.href="http://localhost:8080/MinorWebApp/PageServes/VerifyOTP.jsp?response=wrong-otp";
            </script>
<%
        }
    }  
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <link rel="icon" href="../media/favion.ico" type="image/x-icon">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="../stylesheet/main-style.css">
        <title>Verify OTP</title>
        <script>
            function maxInputNumber(element, maxLength) {
                if(element.value.length > maxLength) {
                    element.value = element.value.slice(0, maxLength);
                }
            }
        </script>    
    </head>
    <body>
        <header>
            <img src="../media/logo.png" class="logo">
            <span class="heading">MedFinder</span>
            <nav class="navbar">
            <a href="http://localhost:8080/MinorWebApp/StatPages/SearchMedicine.jsp">Home</a>
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
                        <h2>VERIFY OTP</h2>
                        <br>
                        <div id="error-alert"></div>
                        <div id="notice-alert"></div>
                        <div class="input-group">
                            <label for="Totp">Enter OTP:</label>
                            <input type="number" id="mname" name="Totp" onclick="maxInputNumber(this,4)">
                        </div>
                        <br>
                        <div class="input-group button-group">
                            <label></label>
                            <button type="submit" class="button-80" name="submit">Submit</button>
                        </div> 
                    </form>
                </div>
            </div>
        </main>
        <script src="/MinorWebApp/scripts/showResponse.js"></script>
        <script>
            let params = (new URL(document.location)).searchParams;
            let response = params.get("response");

            if (response == "verify-otp") {
                showNotice("Please verify the OTP sent to your email.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
            if (response == "wrong-otp") {
                showError("Wrong OTP.");
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
