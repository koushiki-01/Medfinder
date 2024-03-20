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
    <title>Pharmacy Medicine Stock</title>
    <link rel="stylesheet" href="../stylesheet/main-style.css">
    <%! 
        //DECLARATION
        OracleConnection oconn;
        OraclePreparedStatement ops;
        OracleResultSet ors; //Store the data in the webpage from oracle
        OracleResultSetMetaData orsm;
        int reccounter=0; //record counter
        String query, email,ident;        
        java.util.Properties props = new java.util.Properties();
        HttpSession sess;
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
        sess = request.getSession(false);
        if(sess!=null)
            email = sess.getAttribute("email").toString();
    %>
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
        <div class="table-box-container">
            <div class="table-box">
                <h2>Pharmacy Medicine Stock Table</h2>
                <br>
                <div id="success-alert"></div>
                <%
                    DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                    oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);
                    query = "SELECT PMS.PID, P.PNAME, PMS.MID, M.MNAME, PMS.MQTY, PMS.PRICE, PMS.MAV FROM PHARM_MED_STOCK PMS, PHARMACY P, MEDICINE M WHERE PMS.PID=P.PID AND PMS.MID=M.MID AND P.EMAIL = ? ORDER BY PID ASC, MID ASC";
                    ops = (OraclePreparedStatement) oconn.prepareCall(query);
                    ops.setString(1, email);
                    ors = (OracleResultSet) ops.executeQuery();
                    orsm = (OracleResultSetMetaData) ors.getMetaData();
                %>
                <table id="stock">
                    <thead>
                        <%
                            for(int i=1; i<=orsm.getColumnCount(); i++)
                            {
                                reccounter++;
                        %>
                                <th><%=orsm.getColumnName(i)%></th>
                        <%
                            }
                        %>
                        <th>ACTIONS</th>            
                    </thead>
                    <tbody>
                        <%  
                            while(ors.next()==true)
                            {
                        %>
                        <tr>
                            <%
                                ident = "PHARM_MED_STOCK";
                                for(int i=1; i<=orsm.getColumnCount(); i++)
                                {
                            %>
                                    <td><%=ors.getString(i)%></td>
                            <% 
                                    if(orsm.getColumnName(i).equals("PID"))
                                        ident+=","+ors.getString(i);
                                    if(orsm.getColumnName(i).equals("MID"))
                                        ident+=","+ors.getString(i);
                                }
                            %>
                            <td>
                                <form method="POST" action="http://localhost:8080/MinorWebApp/DeleteAll">
                                    <button type="submit" name="Delete" value="<%=ident%>" class="delete-button-small"><span class="material-symbols-outlined">delete_forever</span>DELETE</button>
                                </form>
                            </td>
                        </tr>    
                        <% 
                            }
                        %>
                    </tbody>
                    <tfoot>
                        <tr>
                            <th colspan="<%=reccounter+1%>" style="text-align: center">MedFinder</th>
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

        if (response == "delete-success") {
            showSuccess("Entry deleted successfully.");
            params.delete('response');
            window.history.replaceState({}, document.title, url.toString());
        }
    </script>
    <script>
        function cleanNull() {
            // Get the table
            var table = document.getElementById('stock');
            // i is row
            for (var i = 1; i < table.rows.length; i++) {
                // Current row
                var row = table.rows[i];

                // Replace 'null' values for MQTY and PRICE
                if (row.cells[4].innerHTML === 'null') {
                    row.cells[4].innerHTML = '0';
                }
                if (row.cells[5].innerHTML === 'null') {
                    row.cells[5].innerHTML = '0';
                }
                // Replace 'null' values for MAV
                if (row.cells[6].innerHTML === 'null') {
                    row.cells[6].innerHTML = 'Unknown';
                }
            }
        }
        window.onload = function() {
            cleanNull();
        }
    </script>
<footer>
    <a href="https://www.facebook.com" target="_blank"><img src="../media/facebook-icon.png" class="social-icon" alt="Facebook"></a>
    <a href="https://www.twitter.com" target="_blank"><img src="../media/twitter-icon.ico" class="social-icon" alt="Twitter"></a>
    <a href="https://www.pinterest.com" target="_blank"><img src="../media/pinterest-icon.png" class="social-icon" alt="Pintrest"></a>
</footer>
</body>
</html>
