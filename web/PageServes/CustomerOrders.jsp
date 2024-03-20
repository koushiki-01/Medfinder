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
    String email,cid;
    int rtotal, total=0;
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
    <title>My Orders</title>
    <link rel="stylesheet" href="../stylesheet/main-style.css">
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
                <h2>ORDERS</h2>
                <%
                    query = "SELECT O.OID,P.PNAME, P.ADDRESS, M.MNAME, O.QTY, TO_CHAR(ODATE, 'dd-mm-yyyy') AS ORDER_DATE, O.ITEM_PRICE, O.TOTAL, O.STATUS FROM ORDERS O, PHARMACY P, CUSTOMER C, MEDICINE M WHERE O.CID=C.CID AND O.MID=M.MID AND O.PID=P.PID AND C.CID = ? AND O.STATUS != 'CART' ORDER BY OID ASC";
                    ops = (OraclePreparedStatement) oconn.prepareCall(query);
                    ops.setString(1, cid);
                    ors = (OracleResultSet) ops.executeQuery();
                    orsm = (OracleResultSetMetaData) ors.getMetaData();  
                %>
                <table>
                    <thead>
                        <%
                            for(int i=1; i<=orsm.getColumnCount(); i++) 
                            {
                        %>
                            <th><%=orsm.getColumnName(i)%></th>
                        <%
                            }
                        %>
                    </thead>
                    <tbody>
                        <%  
                            while(ors.next())
                            { 
                        %>
                        <tr>
                            <%
                                int count = 0;
                                for(int i=1; i<=orsm.getColumnCount(); i++) 
                                {
                            %>
                                    <td><%=ors.getString(i)%></td>
                            <%                                  
                                }
                            %>
                        </tr>  
                        <% 
                            }
                        %>
                    </tbody>
                </table>
                <%-- TODO: Buttons to go back --%>
                <div class="button-menu">
                    <button class="button-12" type="button" onclick="window.location.href='http://localhost:8080/MinorWebApp/PageServes/SearchMedicine.jsp'"><span class="material-symbols-outlined">search</span> Search</button>
                    <button class="button-12" type="button" onclick="window.location.href='http://localhost:8080/MinorWebApp/PageServes/CustomerCart.jsp'"><span class="material-symbols-outlined">shopping_cart</span> Cart</button>
                </div>
            </div>
        </div>
    </main>
    <script>
        let params = (new URL(document.location)).searchParams;
        let response = params.get("response");

        if (response === "edit-success") {
            showSuccess("Order updated successfully.");
            params.delete('response');
            window.history.replaceState({}, document.title, url.toString());
        }
        if(response === "edit-failed") {
            showError("Failed to update order.<br>Try again later.");
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
