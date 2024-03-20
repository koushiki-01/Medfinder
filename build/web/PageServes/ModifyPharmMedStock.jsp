<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStream"%>
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
    String query, btnval, table, pid, pname, mid, mname, mqty, price, mav;
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
    if(request.getParameter("submit")==null){
        btnval = request.getParameter("Modify");
        int i = btnval.indexOf(",");
        int j = btnval.lastIndexOf(",");
        table = btnval.substring(0,i);
        pid = btnval.substring(i+1,j);
        mid = btnval.substring(j+1); 
    }
    try{
        DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
        oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);        
        query = "SELECT PMS.PID, P.PNAME, PMS.MID, M.MNAME, PMS.MQTY, PMS.PRICE, PMS.MAV FROM PHARM_MED_STOCK PMS, PHARMACY P, MEDICINE M WHERE PMS.PID=P.PID AND PMS.MID=M.MID AND PMS.PID = ? AND PMS.MID = ?";
        ops = (OraclePreparedStatement) oconn.prepareCall(query);
        ops.setString(1, pid);
        ops.setString(2, mid);
        ors = (OracleResultSet) ops.executeQuery();
        ors.next();
        pname = ors.getString("PNAME");
        mname = ors.getString("MNAME");
        mqty = ors.getString("MQTY");
        price = ors.getString("PRICE");
        mav = ors.getString("MAV");
        
        if(request.getParameter("submit")!=null){
            mqty = request.getParameter("mqty");
            price = request.getParameter("price");
            mav = request.getParameter("availability");
            query = "UPDATE PHARM_MED_STOCK SET MQTY = ?, PRICE = ?, MAV = ? WHERE PID =? AND MID = ?";
            ops = (OraclePreparedStatement) oconn.prepareCall(query);
            ops.setString(1, mqty);
            ops.setString(2, price);
            ops.setString(3, mav);
            ops.setString(4, pid);
            ops.setString(5, mid);
            int x = ops.executeUpdate();
            if(x>0){
    %>
                <script>
                    // Edit success
                    location.href="http://localhost:8080/MinorWebApp/PageServes/medPharmStock.jsp?response=edit-success";
                </script>
    <%
            }
            else{
    %>
            <script>
                // Edit failed
                location.href="http://localhost:8080/MinorWebApp/PageServes/medPharmStock.jsp?response=edit-failed";
            </script>
    <%
            }
            oconn.close();
            ops.close();
        }
    }catch(SQLException ex){
        out.println("<h2 style='color:red'>Error is: "+ ex.toString() + "</h2>");
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
    <link rel="icon" href="../media/favion.ico" type="image/x-icon">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="../stylesheet/main-style.css">
        <title>Edit Pharmacy Stock</title>
        <script src="/MinorWebApp/scripts/showResponse.js"></script>
        <script>
            window.onload = function() {
                // Auto select the old value.
                let mav = "<%=mav%>";
                document.getElementById('availability').value = mav;
                
                document.forms['register'].addEventListener('submit', function(event) {
                    if(!validateForm()) {
                        event.preventDefault();
                    } else {
                        window.location.hash = '';
                    }
                });
            };
            
            function validateForm() {
                var mqty = document.forms['register']['mqty'].value;
                var price = document.forms['register']['price'].value;
                var mav = document.forms['register']['mav'].value;
        
                if(mqty === "" || mcat === "") {
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
        <a href="http://localhost:8080/MinorWebApp/StatPages/admin-database.html">Home</a>
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
                    <form method="POST" name="register">
                        <h2>Edit Pharmacy Stock Details</h2>
                        <br>
                        <div id="error-alert"></div>                      
                        <br>
                        <div class="input-group">
                            <label for="pid">Pharmacy ID:</label>
                            <input type="text" id="pid" name="pid" value="<%=pid%>" readonly/>
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="pname">Pharmacy Name:</label>
                            <input type="text" id="pname" name="pname" value="<%=pname%>" readonly/>
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="mid">Medicine ID:</label>
                            <input type="text" id="mid" name="mid" value="<%=mid%>" readonly/>
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="mname">Medicine Name:</label>
                            <input type="text" id="mname" name="mname" value="<%=mname%>" readonly/>
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="mqty">Medicine Quantity:</label>
                            <input type="number" name="mqty" value="<%=mqty%>">
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="price">Price/item:</label>
                            <input type="number" name="price" value="<%=price%>">
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="availability">Availability:</label>
                            <select id="availability" name="availability">
                                <option value="" disabled hidden>Select an Option</option>
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