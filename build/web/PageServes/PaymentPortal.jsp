<%@page import="javax.mail.MessagingException"%>
<%@page import="javax.mail.Transport"%>
<%@page import="javax.mail.internet.InternetAddress"%>
<%@page import="javax.mail.internet.MimeMessage"%>
<%@page import="javax.mail.Message"%>
<%@page import="javax.mail.PasswordAuthentication"%>
<%@page import="javax.mail.Session"%>
<%@page import="java.util.Random"%>
<%@page import="java.io.IOException"%>
<%@page import="java.util.Properties"%>
<%@page import="java.io.InputStream"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
String to, from, subject, body;
HttpSession sess; 
String mailUsername, mailPassword;
String email;
%>
<%  
try (InputStream mailInput = application.getResourceAsStream("/WEB-INF/mail.properties")) {
    Properties mailProps = new Properties();
    mailProps.load(mailInput);
    mailUsername = mailProps.getProperty("username");
    mailPassword = mailProps.getProperty("password");
    } catch (IOException ex) {
        throw new ServletException(ex);
}
if(request.getParameter("submit")!=null){
    sess = request.getSession(false);
    if(sess!=null)
        email = sess.getAttribute("email").toString();
    //OTP generation code starts
    Random random = new Random();
    int x=0;
    while(x<1000)
        x=random.nextInt(9999);
    body = "Your OTP is: " + x +"\nPlease do not share this OTP with anyone.";
    //OTP generation code ends
    sess.setAttribute("otp",x);
    to = email;
    subject = "MedFinder - Please confirm your order";
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
    try{
        Message message = new MimeMessage(session1);
        message.setFrom(new InternetAddress(username));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject(subject);
        message.setText(body);
        Transport.send(message);
    }catch (MessagingException ex) {
        out.println("<h2 style='color: red'>"+ex.getMessage()+"</h2>");
    }   
%>
    <script>
        // OTP sent to email.
        location.href="http://localhost:8080/MinorWebApp/PageServes/VerifyOTP.jsp?response=verify-otp";
    </script>
<%
}
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
    <link rel="icon" href="../media/favion.ico" type="image/x-icon">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="../stylesheet/main-style.css">
        <title>Payment Portal</title>
        <script src="/MinorWebApp/scripts/showResponse.js"></script>
        <script>
            window.onload = function() {
                document.forms['payment-portal'].addEventListener('submit', function(event) {
                    if(!validateForm()) {
                        event.preventDefault();
                    } else {
                        window.location.hash = '';
                        // On successful form validation, the default submit event
                        // passes through and the button is disabled to prevent
                        // multiple payments.
                        document.getElementById('submit-button').disabled = true;
                    }
                });
            };
    
            function validateForm() {
                var nameOnCard = document.forms['payment-portal']['nameOnCard'].value;
                var cardNumber = document.forms['payment-portal']['cardNumber'].value;
                var expiry = document.forms['payment-portal']['expiry'].value;
                var cvv = document.forms['payment-portal']['cvv'].value;
                var billingAddress = document.forms['payment-portal']['billingAddress'].value;

                if(nameOnCard === "" || cardNumber === "" || expiry === "" || cvv === "" || billingAddress === "") {
                    showError("All field are required.");
                    return false;
                }
                // Checks if expiry date is in the future
                var expiryDate = new Date(expiry);
                var currentDate = new Date();
                if (expiryDate < currentDate) {
                    showError("The expiration date has passed.");
                    return false;
                }
                if (cvv.length !== 3 || isNaN(cvv)) {
                    showError("The CVV should be a three-digit number.");
                    return false;
                }
                if(cardNumber.length < 16 || isNaN(cardNumber)) {
                    showError("Invalid card number.");
                    return false;
                }
                return true;
            }

            function maxInputNumber(element, maxLength) {
                if(element.value.length > maxLength) {
                    element.value = element.value.slice(0, maxLength);
                }
            }
       </script>
       <style>
            textarea {
                padding: 3px;
                width: 60%;
                height: 40px;
                background-color: rgba(255, 255, 255, 0.217);
                border: transparent;
                border-radius: 0px;
                padding: 5px 8px;
            }
       </style>
    </head>
    <body>
        <header>
            <img src="../media/logo.png" class="logo">
            <span class="heading">MedFinder</span>
            <nav class="navbar">
            <a href="http://localhost:8080/MinorWebApp/PageServes/SearchMedicine.jsp">Home</a>
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
                    <form method="POST" name="payment-portal">
                        <h2>Payment Portal</h2>
                        <br>
                        <div id="error-alert"></div>
                        <br>
                        <div class="input-group">
                            <label for="nameOnCard">Name on Card</label>
                            <input type="text" name="nameOnCard" placeholder="John Doe">
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="cardNumber">Card Number</label>
                            <input type="text" name="cardNumber" placeholder="1234 5678 9123 4567" oninput="maxInputNumber(this,16)">
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="expiry">Expiry Date</label>
                            <input type="month" name="expiry" placeholder="2026-07">
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="cvv">CVV</label>
                            <input type="password" name="cvv" oninput="maxInputNumber(this,3)" placeholder="123">
                        </div>  
                        <br>
                        <div class="input-group">
                            <label for="billingAddress">Billing Address</label>
                            <textarea name="billingAddress" placeholder="123, Gold Street"></textarea>
                        </div>                       
                        <!--<br>    
                        <div class="input-group">
                            <label for="billingAddress">Billing Address</label>
                            <textarea name="billingAddress" placeholder="123, Gold Street"></textarea>
                        </div>-->    
                        <br>
                        <div class="input-group button-group">
                            <button type="submit" name="submit" class="button-80">Submit Payment</button>
                            <button type="button" onclick="window.location.href='http://localhost:8080/MinorWebApp/PageServes/SearchMedicine.jsp'" class="button-12">Go back</button>
                        </div>
                        <br>
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