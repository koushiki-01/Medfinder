<%@page import="java.sql.DriverManager"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStream"%>
<%@page import="oracle.jdbc.OracleResultSetMetaData"%>
<%@page import="oracle.jdbc.OracleResultSet"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%! 
    //DECLARATION
    OracleConnection oconn;
    OraclePreparedStatement ops;
    OracleResultSet ors; //Store the data in the webpage from oracle
    OracleResultSetMetaData orsm;
    int reccounter=0; //record counter
    String query, email, ident;
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
    HttpSession sess = request.getSession(false);
    if(sess!=null)
        email = sess.getAttribute("email").toString();
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <link rel="icon" href="../media/favion.ico" type="image/x-icon">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Check Orders</title>
        <link rel="stylesheet" href="../stylesheet/main-style.css">
    </head>
    <body>
        <header>
            <img src="../media/logo.png" class="logo">
            <span class="heading">MedFinder</span>
            <nav class="navbar">
            <a href="http://localhost:8080/MinorWebApp/StatPages/PharmacyHome.html">Home</a>
            <a href="http://localhost:8080/MinorWebApp/about.html">About Us</a>
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
            <div class="table-box-container">
                <div class="table-box">
                    <h2>Pharmacy Orders</h2>
                    <br>
                    <div id="error-alert"></div>
                    <div id="success-alert"></div>
                    <%
                        DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                        oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);
                        query = "SELECT O.OID, C.FNAME || ' ' || C.LNAME AS CUSTOMER_NAME, P.PNAME, M.MNAME, TO_CHAR(ODATE, 'dd-mm-yyyy') AS ORDER_DATE, O.QTY, C.ADDRESS || ', ' || C.CITY AS ADDRESS, O.STATUS, O.CID, O.PID, O.MID FROM ORDERS O, PHARMACY P, CUSTOMER C, MEDICINE M WHERE O.CID=C.CID AND O.PID=P.PID AND O.MID = M.MID AND P.EMAIL = ? AND O.STATUS != 'CART' ORDER BY OID ASC";
                        ops = (OraclePreparedStatement) oconn.prepareCall(query);    
                        ops.setString(1, email);
                        ors = (OracleResultSet) ops.executeQuery();
                        orsm = (OracleResultSetMetaData) ors.getMetaData();
                    %>
                    <table>
                        <thead>
                            <%
                                for(int i=1; i<=orsm.getColumnCount()-3; i++)
                                {
                                    reccounter++;
                            %>
                                    <th><%=orsm.getColumnName(i)%></th>
                            <%
                                }
                            %>   
                            <th>Edit</th>
                        </thead>
                        <tbody>
                            <%  
                                while(ors.next()==true)
                                {
                            %>
                            <tr>
                                <%
                                    ident = "ORDERS";
                                    int count=0;
                                    for(int i=1; i<=orsm.getColumnCount(); i++)
                                    {
                                        if(orsm.getColumnName(i).equals("OID"))
                                        ident+=","+ors.getString(i);
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
                                        <form method="POST" action="http://localhost:8080/MinorWebApp/PageServes/ModifyOrders.jsp">
                                            <!--<h3><%=ident%></h3>-->
                                            <button type="submit" name="Modify" value="<%=ident%>" class="button-12"><span class="material-symbols-outlined">edit</span> Edit Status</button>
                                        </form>
                                </td>
                            </tr>    
                            <% 
                                }
                            %>                            
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="<%=reccounter+1%>" style="text-align: center;">MedFinder</th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>
        </main>
        <script src="/MinorWebApp/scripts/showResponse.js"></script>
        <script>
            let params = (new URL(document.location)).searchParams;
            let response = params.get("response");

            if (response === "edit-success") {
                showSuccess("Profile edited successfully.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
        </script>
    </body>
    <footer>
        <a href="https://www.facebook.com" target="_blank"><img src="../media/facebook-icon.png" class="social-icon" alt="Facebook"></a>
        <a href="https://www.twitter.com" target="_blank"><img src="../media/twitter-icon.ico" class="social-icon" alt="Twitter"></a>
        <a href="https://www.pinterest.com" target="_blank"><img src="../media/pinterest-icon.png" class="social-icon" alt="Pintrest"></a>
    </footer>
</html>
