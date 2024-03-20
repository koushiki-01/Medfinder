<%@page import="java.sql.SQLException"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.io.IOException"%>
<%@page import="java.util.Properties"%>
<%@page import="java.io.InputStream"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="oracle.jdbc.OracleResultSetMetaData"%>
<%@page import="oracle.jdbc.OracleResultSet"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%! 
    OracleConnection oconn;
    OraclePreparedStatement ops;
    OracleResultSet ors; //Store the data in the webpage from oracle
    OracleResultSetMetaData orsm;
    String query, email, mqty, price, availability, mname;
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
    sess = request.getSession(false);
    if(sess!=null)
        email = sess.getAttribute("email").toString();
    if(request.getParameter("submit")!=null){
        try{
                mqty = request.getParameter("mqty");
                price = request.getParameter("price");
                availability = request.getParameter("availability");
                mname = request.getParameter("mname");
                DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                oconn = (OracleConnection) DriverManager.getConnection(oconnUrl,oconnUsername,oconnPassword);
                query = "UPDATE PHARM_MED_STOCK SET MQTY = ?, PRICE = ?, MAV = ? WHERE PID = (SELECT PID FROM PHARMACY WHERE EMAIL = ?) AND MID = (SELECT MID FROM MEDICINE WHERE MNAME = ?)";
                ops = (OraclePreparedStatement) oconn.prepareStatement(query);
                ops.setString(1,mqty);
                ops.setString(2,price);
                ops.setString(3,availability);
                ops.setString(4,email);
                ops.setString(5,mname);
                ors = (OracleResultSet)ops.executeQuery();
                int x = ops.executeUpdate();
                if(x>0){
%>
                        <script>
                            // Data inserted successfully.
                            location.href = "http://localhost:8080/MinorWebApp/StatPages/PharmacyHome.html?response=update-success";
                        </script>
<%
                }else{
%>
                        <script>
                            // Failed to update
                            location.href="http://localhost:8080/MinorWebApp/StatPages/PharmacyHome.html?response=update-failed";

                        </script>
<% 
                }
                ops.close();
                oconn.close();
            }catch (SQLException ex) {
                out.println("<h2 style='color:red'>Error is: "+ ex.toString() + "</h2>");
            }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link rel="icon" href="../media/favion.ico" type="image/x-icon">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Inventory</title>
    <link rel="stylesheet" href="../stylesheet/main-style.css">
    <script src="/MinorWebApp/scripts/showResponse.js"></script>
    <script>
        window.onload = function() {
            document.forms['update-inventory'].addEventListener('submit', function(event) {
                if(!validateForm()) {
                    event.preventDefault();
                } else {
                    window.location.hash = '';
                }
            });
        };

        function validateForm() {
            var mqty = document.forms['update-inventory']['mqty'].value;
            var price = document.forms['update-inventory']['price'].value;
            var availability = document.forms['update-inventory']['availability'].value;
            
            if(mqty === "" || price === "" || availability === "") {
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
        <a href="http://localhost:8080/MinorWebApp/StatPages/PharmacyHome.html">Home</a>
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
                <form name="update-inventory" method="POST">
                    <h2>UPDATE INVENTORY</h2>
                        <br>
                        <div id="error-alert"></div>
                        <div id="success-alert"></div>
                        <div class="input-group">
                            <label for="fname">Medicine Name:</label>
                                <select name="mname">
                                    <%
                                        DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                                        oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);
                                        query = "SELECT M.MNAME FROM MEDICINE M, PHARM_MED_STOCK PMS, PHARMACY P WHERE PMS.PID = (SELECT PID FROM PHARMACY WHERE EMAIL = ?) AND P.PID = PMS.PID AND PMS.MID=M.MID ORDER BY MNAME ASC";
                                        ops = (OraclePreparedStatement) oconn.prepareCall(query);
                                        ops.setString(1, email);
                                        ors = (OracleResultSet) ops.executeQuery();
                                        while(ors.next())
                                        {
                                    %>
                                    <option value="<%=ors.getString(1)%>"><%=ors.getString(1)%></option>
                                    <% 
                                        }
                                    %>
                                </select>
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="mqty">Medicine Quantity</label>
                            <input type="number" name="mqty" placeholder="Enter the number of items">
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="price">Price:</label>
                            <input type="number" name="price" placeholder="Enter the Price per item">
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="availability">Availability:</label>
                            <select id="availability" name="availability">
                                <option value="" selected disabled hidden>Select an Option</option>
                                <option value="YES">Yes</option>
                                <option value="NO">No</option>
                                <option value="FEW">Few</option>
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
