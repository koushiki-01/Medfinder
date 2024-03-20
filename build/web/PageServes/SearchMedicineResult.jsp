<%@page import="java.io.IOException"%>
<%@page import="java.util.Properties"%>
<%@page import="java.io.InputStream"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="oracle.jdbc.OracleResultSetMetaData"%>
<%@page import="oracle.jdbc.OracleResultSet"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link rel="icon" href="../media/favion.ico" type="image/x-icon">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Results</title>
    <link rel="stylesheet" href="../stylesheet/main-style.css">
    <script src="/MinorWebApp/scripts/showResponse.js"></script>
<script>
    window.onload = function() {
        var forms = document.getElementsByName('cart');
        for(var i = 0; i < forms.length; i++) {
            forms[i].addEventListener('submit', function(event) {
                if(!validateForm(event)) {
                    event.preventDefault();
                } else {
                    window.location.hash = '';
                }
            });
        }
    };

    function validateForm(event) {
        var form = event.target;
        var quantity = form.querySelector('.quantity').value;
        if(quantity.length === 0) {
            showError("Quantity cannot be empty.");
            return false;
        }
        if(isNaN(quantity)) {
            showError("Quantity must be a number.");
            return false;
        }
        return true;
    }

    function maxNumberInput(input, max) {
        if (input.value !== '') {
            if (input.value > max) {
                input.value = max;
            }
            if (input.value < 1) {
                input.value = 1;
            }
        }
    }
</script>
</head>
<body>
    <header>
        <img src="../media/logo.png" class="logo">
        <span class="heading">MedFinder</span>
        <nav class="navbar">
        <a href="http://localhost:8080/MinorWebApp/PageServes/SearchMedicine.jsp">Home</a>
        <a href="http://localhost:8080/MinorWebApp/StatPages/about.html">About Us</a>
        <a href="http://localhost:8080/MinorWebApp/PageServes/CustomerCart.jsp">Cart</a>
        <div class="navbar-dropdown">
            <a class="navbar-dropdown-button">Settings</a>
            <div class="navbar-dropdown-content">
                <a href="http://localhost:8080/MinorWebApp/SessLogOut">Log Out</a>
                <a href="http://localhost:8080/MinorWebApp/PageServes/changePassword.jsp">Change Password</a>
                <a href="http://localhost:8080/MinorWebApp/PageServes/FeedBack.jsp">Feedback</a>
            </div>
        </div>
        </nav>
    </header>
<%-- Java code needs to be after head to give time for the JS to load the error functions. --%>
<%! 
    OracleConnection oconn;
    OraclePreparedStatement ops, ops1;
    OracleResultSet ors, ors1; //Store the data in the webpage from oracle
    OracleResultSetMetaData orsm;
    String query, query2;
    java.util.Properties props = new java.util.Properties();
    String oconnUrl, oconnUsername, oconnPassword;
    String ident,email,cid;
%>
<%
    boolean hasResult = false;
    try {
        InputStream input = application.getResourceAsStream("/WEB-INF/db.properties");
        props.load(input);
        oconnUrl = "jdbc:oracle:thin:@" + props.getProperty("hostname") + ":"
            + props.getProperty("port") + ":" + props.getProperty("SID");
        oconnUsername = props.getProperty("username");
        oconnPassword = props.getProperty("password");
        DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
        oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);
        query = "SELECT P.PNAME, M.MNAME, P.ADDRESS, PMS.MQTY, PMS.PRICE, P.CITY, P.PHONE, P.PID, M.MID FROM PHARMACY P,MEDICINE M, PHARM_MED_STOCK PMS WHERE M.MID = (SELECT MID FROM MEDICINE WHERE MNAME = ?) AND P.PID=PMS.PID AND M.MID=PMS.MID AND P.CITY=?";
        ops = (OraclePreparedStatement) oconn.prepareCall(query);
        ops.setString(1, request.getParameter("medicineName"));
        ops.setString(2, request.getParameter("city"));
        ors = (OracleResultSet) ops.executeQuery();
        orsm = (OracleResultSetMetaData) ors.getMetaData();
        HttpSession sess = request.getSession(false);
        if(session!=null)
            email = sess.getAttribute("email").toString();
        ops1 = (OraclePreparedStatement) oconn.prepareStatement("SELECT CID FROM CUSTOMER WHERE EMAIL = ?");
        ops1.setString(1,email);
        ors1 = (OracleResultSet) ops1.executeQuery();
        ors1.next();
        cid = ors1.getString("CID");
    } catch (Exception ex) {
        out.println("Error: " + ex.getMessage());
    }
%>
    <main>
        <div class="result-container">
            <div class="result-box">
                <h2>Search Result</h2>
                <br>
                <div id="error-alert"></div>
                <table>
                    <thead>
                        <%
                            for(int i=1; i<=orsm.getColumnCount()-2; i++) //-2 given to exclude PID, MID from printing
                            {
                        %>
                        <th><%=orsm.getColumnName(i)%></th>
                        <%
                            }
                        %>
                        <th>QUANTITY</th>
                    </thead>
                    <tbody>
                        <%  
                            while(ors.next())
                            {
                                hasResult=true; 
                        %>
                        <tr>
                            <%
                                ident = "ORDERS,"+cid;
                                int count = 0;
                                for(int i=1; i<=orsm.getColumnCount(); i++) 
                                {   
                                    if(orsm.getColumnName(i).equals("PID")){
                                        ident+=","+ors.getString(i);++count;}
                                    if(orsm.getColumnName(i).equals("MID")){
                                        ident+=","+ors.getString(i);++count;}
                                    if(orsm.getColumnName(i).equals("MQTY"))
                                        ident+=","+ors.getString(i);
                                    if(orsm.getColumnName(i).equals("PRICE"))
                                        ident+=","+ors.getString(i);
                                    if(count!=0)
                                        continue;
                            %>
                                    <td><%=ors.getString(i)%></td>
                            <%                             
                                }
                            %>
                            <td>                         
                                    <form method="POST" name="cart" action="http://localhost:8080/MinorWebApp/AddToCart" onsubmit="return validateForm(event)">
                                    <input type="text" class="quantity" name="<%=ident%>" min="1" max="<%=ors.getInt("MQTY")%>" oninput="maxNumberInput(this,<%=ors.getInt("MQTY")%>)">
                                    <button type="submit" name="cart" value="<%=ident%>" class="button-62"><span class="material-symbols-outlined"> add_shopping_cart </span></button>
                                </form>
                            </td>
                        </tr>  
                        <% 
                            }
                        %>
                    </tbody>
                </table> 
                <div class="button-menu">
                    <button class="button-12" onclick="window.location.href='http://localhost:8080/MinorWebApp/PageServes/SearchMedicine.jsp'"><span class="material-symbols-outlined">search</span> Search</button>
                    <button class="button-12"onclick="window.location.href='http://localhost:8080/MinorWebApp/PageServes/CustomerCart.jsp'"><span class="material-symbols-outlined">shopping_cart</span> Cart</button>
                </div>
                <%
                    if(!hasResult) {
                %>
                <script>
                showError("No results found for <%=request.getParameter("medicineName")%>")
                </script>
                <%
                    }
                %>
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
