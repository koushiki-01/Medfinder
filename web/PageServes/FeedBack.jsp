<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStream"%>
<%@page import="javax.mail.MessagingException"%>
<%@page import="javax.mail.Transport"%>
<%@page import="java.util.Random"%>
<%@page import="javax.mail.internet.InternetAddress"%>
<%@page import="javax.mail.internet.MimeMessage"%>
<%@page import="javax.mail.Message"%>
<%@page import="javax.mail.PasswordAuthentication"%>
<%@page import="javax.mail.Session"%>
<%@page import="java.util.Properties"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    String to1, to2, from1, from2, subject1, subject2, body1, body2, link;
    String email, userType;
    String mailUsername, mailPassword;
    HttpSession sess; 
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
    if(request.getParameter("submit")!=null)
    {
        sess = request.getSession(false);
        if(sess!=null){
            email = sess.getAttribute("email").toString();
            userType = sess.getAttribute("userType").toString();                    
        }
        to1 = mailUsername;
        subject1 = "Feedback from " + userType;
        body1 = "Feedback: \n\n>" + request.getParameter("feedback") +
        "\n\nGiven by: " + email;
        to2 = email;
        subject2 = "MedFinder - Feedback";
        body2 = "Thank you for taking the time to share your valuable feedback with us.\n\n" +
        "Feedback: \n\n> " + request.getParameter("feedback");
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
        Session session2 = Session.getInstance(props, new javax.mail.Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication(){
                    return new PasswordAuthentication(username,password);
                }});

        try {
            Message message1 = new MimeMessage(session1);
            message1.setFrom(new InternetAddress(username));
            message1.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to1));
            message1.setSubject(subject1);
            message1.setText(body1);
            Transport.send(message1);
            Message message2 = new MimeMessage(session2);
            message2.setFrom(new InternetAddress(username));
            message2.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to2));
            message2.setSubject(subject2);
            message2.setText(body2);
            Transport.send(message2);
            if(userType.equals("CUSTOMER"))
                link = "http://localhost:8080/MinorWebApp/PageServes/SearchMedicine.jsp?response=feedback-success";
            else if(userType.equals("PHARMACY"))
                link = "http://localhost:8080/MinorWebApp/StatPages/PharmacyHome.html?response=feedback-success";
%>
                <script>
                    location.href="<%=link%>";
                </script>
<% 
            
        } catch (MessagingException ex) {
            out.println("<h2 style='color: red'>"+ex.getMessage()+"</h2>");
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
        <title>Feedback</title>
        <style>
            textarea {
                width: 100%;
                height: 100px;
                padding: 5px;
            }
        </style>
    </head>
    <body>
        <header>
            <img src="../media/logo.png" class="logo">   
            <span class="heading">MedFinder</span>
            <nav class="navbar">
                <a href="http://localhost:8080/MinorWebApp/StatPages/PharmacyHome.html">Home</a>
                <a href="http://localhost:8080/MinorWebApp/StatPages/about.html">About Us</a>
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
                    <form method="POST" name="feedback">
                        <h2>FEEDBACK</h2>
                        <br>
                        <p>Please let us know how we can do better.</p>
                        <br>
                        <textarea name="feedback" placeholder="Feedback..." required></textarea>
                        <br>
                        <br>
                        <div class="input-group button-group">
                            <label></label>
                            <button type="submit" name="submit" class="button-80">Submit Feedback</button>
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