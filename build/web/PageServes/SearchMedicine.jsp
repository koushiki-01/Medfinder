<%@page import="java.io.IOException"%>
<%@page import="java.util.Properties"%>
<%@page import="java.io.InputStream"%>
<%@page import="java.sql.DriverManager"%>
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
    String query, userType, email, cid, ident;
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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link rel="icon" href="../media/favion.ico" type="image/x-icon">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Medicine Search</title>
    <link rel="stylesheet" href="http://localhost:8080/MinorWebApp/stylesheet/main-style.css">
    <style>
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
            <%
                HttpSession sess = request.getSession(false);
                if(sess!=null){
                    userType = sess.getAttribute("userType").toString();
                    email = sess.getAttribute("email").toString();
                }
                DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);
                query = "SELECT CID FROM CUSTOMER WHERE EMAIL = ?";                                      
                ops = (OraclePreparedStatement) oconn.prepareCall(query);
                ops.setString(1, email);
                ors = (OracleResultSet) ops.executeQuery();
                ors.next();
                cid = ors.getString(1);
                ident = userType+","+cid;
            %>
            <div class="search-container">
                <h2>Search Medicine</h2>
                <br>
                <div id="error-alert"></div>
                <div id="success-alert"></div>
                <form action="SearchMedicineResult.jsp" method="post">
                    <select name="medicineName">
                      <option value="" selected disabled>Select a medicine</option>
                    <%  
                        query = "SELECT MNAME FROM MEDICINE ORDER BY MNAME ASC";
                        ops = (OraclePreparedStatement) oconn.prepareCall(query);
                        ors = (OracleResultSet) ops.executeQuery();
                        while(ors.next()==true)
                        {
                    %>
                    <option value="<%=ors.getString(1)%>"><%=ors.getString(1)%></option>
                    <% 
                        }
                    %>
                    </select>
                    <select id="city" name="city" required>
                        <option value="" selected disabled hidden>Select a City</option>
                        <option value="KOLKATA">Kolkata</option>
                        <option value="HOWRAH">Howrah</option>
                        <option value="BURDWAN">Burdwan</option>
                        <option value="DURGAPUR">Durgapur</option>
                    </select>
                    <br>
                    <%-- <input type="submit" value="Search"> --%>
                    <button id="search-submit" type="submit" value="Search">
                        <span class="material-symbols-outlined">search</span> Search
                    </button>
                    <br><br>
                    <div class="button-menu">
                        <button class="button-12" type="button" onclick="window.location.href='http://localhost:8080/MinorWebApp/PageServes/CustomerCart.jsp'"><span class="material-symbols-outlined">shopping_cart</span> Cart</button>
                        <button class="button-12" type="button" onclick="window.location.href='http://localhost:8080/MinorWebApp/PageServes/CustomerOrders.jsp'"><span class="material-symbols-outlined">orders</span> My orders</button>
                    </div>
                </form>
                <div class="profile-edit-container">
                    <form method="POST" action="http://localhost:8080/MinorWebApp/PageServes/ModifyCustomer.jsp">
                        <button type="submit" name="Modify" value="<%=ident%>" class="button-33"><span class="material-symbols-outlined">account_circle</span> Edit Profile</button>
                    </form>
                </div>
            </div>
        </main>
        <script src="/MinorWebApp/scripts/showResponse.js"></script>
        <script>
            let params = (new URL(document.location)).searchParams;
            let response = params.get("response");

            if (response == "feedback-success") {
                showSuccess("Feedback recieved successfully.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
            if (response == "order-placed") {
                showSuccess("Order placed successfully.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
            if (response == "added-cart") {
                showSuccess("Added to cart successfully.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
            if (response == "failed-cart") {
                showError("Failed to add to cart.<br>Please try again later.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
            if (response == "order-too-high") {
                showError("Not enough items in stock.<br>Please try again.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
            if (response == "edit-fail") {
                showError("Failed to update profile.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
            if (response === "edit-success") {
                showSuccess("Profile edited successfully.");
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
