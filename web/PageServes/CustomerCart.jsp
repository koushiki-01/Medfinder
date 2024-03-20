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
    OraclePreparedStatement ops, ops1;
    OracleResultSet ors, ors1; //Store the data in the webpage from oracle
    OracleResultSetMetaData orsm;
    String query, query2;
    java.util.Properties props = new java.util.Properties();
    String oconnUrl, oconnUsername, oconnPassword;
    String ident,email,cid;
    int rtotal, discount = 20, reccounter=0;
    double total;
%>
<%
    try {
        InputStream input = application.getResourceAsStream("/WEB-INF/db.properties");
        props.load(input);
        oconnUrl = "jdbc:oracle:thin:@" + props.getProperty("hostname") + ":"
            + props.getProperty("port") + ":" + props.getProperty("SID");
        oconnUsername = props.getProperty("username");
        oconnPassword = props.getProperty("password");
        DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
        oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);
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
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link rel="icon" href="../media/favion.ico" type="image/x-icon">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cart</title>
    <link rel="stylesheet" href="../stylesheet/main-style.css">
    <script src="/MinorWebApp/scripts/showResponse.js"></script>
    <style>
        .bill-container {
            display: flex;
            justify-content: flex-start;
            padding-right: 40px;
        }
        .bill {
            width: auto;
            padding: -3px 4px;
            font-size: 18px;
        }
        .bill tr, .bill td, .bill th {
            padding: 0;
            margin: 0;
        }
        .bill td:nth-child(1) {
            width: 150px;
            font-weight: 300px;
            font-family: 'Playfair Display', serif;
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
    <div class="result-container">
        <div class="result-box">
            <h2>CART</h2>
            <br>
            <div id="error-alert"></div>
            <div id="success-alert"></div>
            <%
                query = "SELECT O.OID,P.PNAME, P.ADDRESS, M.MNAME, O.QTY, O.ITEM_PRICE, O.TOTAL, O.CID, O.PID, O.MID FROM ORDERS O, PHARMACY P, CUSTOMER C, MEDICINE M WHERE O.CID=C.CID AND O.MID=M.MID AND O.PID=P.PID AND C.CID = ? AND O.STATUS = 'CART' ORDER BY OID ASC";
                ops = (OraclePreparedStatement) oconn.prepareCall(query);
                ops.setString(1, cid);
                ors = (OracleResultSet) ops.executeQuery();
                orsm = (OracleResultSetMetaData) ors.getMetaData();  
            %>
            <table>
                <thead>
                    <%
                        for(int i=1; i<=orsm.getColumnCount()-3; i++) 
                        {
                    %>
                        <th><%=orsm.getColumnName(i)%></th>
                    <%
                        }
                    %>
                    <th>ACTION</th>
                </thead>
                <tbody>
                    <%  total = 0.0; reccounter = 0;
                        while(ors.next())
                        { 
                    %>
                    <tr>
                        <%
                            //This variable counts the number of records in the table
                            reccounter++;
                            ident = "ORDERS";
                            int count = 0;
                            for(int i=1; i<=orsm.getColumnCount(); i++) 
                            {
                                if(orsm.getColumnName(i).equals("OID")){
                                    ident+=","+ors.getString(i);}
                                if(orsm.getColumnName(i).equals("TOTAL"))
                                    total += Integer.parseInt(ors.getString(i));
                                if(orsm.getColumnName(i).equals("CID")){
                                    ident+=","+ors.getString(i);++count;}
                                if(orsm.getColumnName(i).equals("PID")){
                                    ident+=","+ors.getString(i);++count;}
                                if(orsm.getColumnName(i).equals("MID")){
                                    ident+=","+ors.getString(i);++count;}                                
                                if(count!=0)
                                    continue; 
                        %>
                                <td><%=ors.getString(i)%></td>
                        <%                                  
                            }
                        %>
                        <td>
                            <form method="POST" action="http://localhost:8080/MinorWebApp/DeleteAll">
                                <!--<h3><%=ident%></h3>-->
                                <button type="submit" name="Delete" value="<%=ident%>" class="delete-button-small"><span class="material-symbols-outlined">delete_forever</span>DELETE</button>
                            </form>
                        </td>
                    </tr>  
                    <% 
                        }
                    %>
                </tbody>
            </table>
            <div class="bill-container">
                <div class="bill">
                    <table>
                    <tr>
                        <td>Total:</td>
                        <td><%=total%></td>
                    </tr>
                    <tr>
                        <td>Discount:</td>
                        <td><%=discount%>%</td>
                    </tr>
                    <tr>
                        <td>Final total:</td>
                        <td><%=(total - ((total*discount)/100))%></td>
                    </tr>
                    </table>
                </div>
            </div>
            <br><br>
            <div class="button-menu">
                <button class="button-12" onclick="window.location.href='http://localhost:8080/MinorWebApp/PageServes/SearchMedicine.jsp'"><span class="material-symbols-outlined">search</span> Search</button>
                <button class="button-12" id="place-order" onclick="window.location.href='http://localhost:8080/MinorWebApp/PageServes/PaymentPortal.jsp'"><span class="material-symbols-outlined">shopping_cart_checkout</span> Checkout</button>
            </div>
            </div>
        </div>
    </main>
    <script>
        window.onload = function() {
        document.getElementById('place-order').onclick = function(event) {
            var reccounter = <%=reccounter%>;
            if(reccounter === 0) {
            event.preventDefault();
            showError("Cannot place order. Cart is empty.");
            } else {
            window.location.href = 'http://localhost:8080/MinorWebApp/PageServes/PaymentPortal.jsp';
            }
        }
    }
    </script>
    <script>
        let params = (new URL(document.location)).searchParams;
        let response = params.get("response");

        if (response == "delete-success") {
            showSuccess("Entry deleted successfully.");
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
