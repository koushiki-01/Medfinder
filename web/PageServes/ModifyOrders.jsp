<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
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
    String query, oid, cid, cname, btnval, table, pid, p_name, mid, mname, qty, odate, status, item_price, total, userType, email;
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
    if(sess!=null){
        email = sess.getAttribute("email").toString();
        userType = sess.getAttribute("userType").toString();
    }
    if(request.getParameter("submit")==null){
        btnval = request.getParameter("Modify");
        int i = btnval.indexOf(",");
        int j = btnval.indexOf(",",btnval.indexOf(",")+1);
        int k = btnval.indexOf(",",btnval.indexOf(",",btnval.indexOf(",")+1)+1);
        int l = btnval.lastIndexOf(",");
        table = btnval.substring(0,i);
        oid = btnval.substring(i+1,j);
        cid = btnval.substring(j+1,k);
        pid = btnval.substring(k+1,l);
        mid = btnval.substring(l+1);
    }
    try{
        DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
        oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);        
        query = "SELECT O.OID, C.CID, C.FNAME || ' ' || C.LNAME AS CUSTOMER_NAME, O.PID, P.PNAME, O.MID, M.MNAME, O.QTY, TO_CHAR(O.ODATE, 'dd-mm-yyyy') AS ORDER_DATE, O.STATUS, O.ITEM_PRICE, O.TOTAL FROM ORDERS O, CUSTOMER C, PHARMACY P, MEDICINE M WHERE O.CID=C.CID AND O.PID=P.PID AND O.MID=M.MID AND O.OID = ? AND O.CID = ? AND O.PID = ? AND O.MID = ? ORDER BY OID ASC";
        ops = (OraclePreparedStatement) oconn.prepareCall(query);
        ops.setString(1, oid);
        ops.setString(2, cid);
        ops.setString(3, pid);
        ops.setString(4, mid);
        ors = (OracleResultSet) ops.executeQuery();
        ors.next();
        cname = ors.getString("CUSTOMER_NAME");
        p_name = ors.getString("PNAME");
        mname = ors.getString("MNAME");
        qty = ors.getString("QTY");
        odate = ors.getString("ORDER_DATE");
        status = ors.getString("STATUS");
        item_price = ors.getString("ITEM_PRICE");
        total = ors.getString("TOTAL");
        if(odate==null)
            odate = "01-01-2023";
        SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy");
        Date dt = sdf.parse(odate);
        SimpleDateFormat sdf1 = new SimpleDateFormat("yyyy-MM-dd");
        odate = sdf1.format(dt);
        
        if(request.getParameter("submit")!=null){                
            if(userType.equals("ADMIN")){
                qty = request.getParameter("qty");
                odate = request.getParameter("odate");
                sdf = new SimpleDateFormat("yyyy-MM-dd");
                dt = sdf.parse(odate);
                sdf1 = new SimpleDateFormat("dd-MMM-yyyy");
                odate = sdf1.format(dt);
                item_price = request.getParameter("item_price");
                total = request.getParameter("total");
                
            }
                status = request.getParameter("status");
            int x=0;    
            if(userType.equals("PHARMACY")){
                query = "UPDATE ORDERS SET STATUS = ? WHERE OID=? AND CID=? AND PID=? AND MID=?";
                ops = (OraclePreparedStatement) oconn.prepareCall(query);
                ops.setString(1, status);
                ops.setString(2, oid);
                ops.setString(3, cid);
                ops.setString(4, pid);
                ops.setString(5, mid);
                x = ops.executeUpdate();
            }
            else if(userType.equals("ADMIN")){
                query = "UPDATE ORDERS SET QTY = ?, ODATE = ?, STATUS = ?, ITEM_PRICE = ?, TOTAL = ? WHERE OID=? AND CID=? AND PID=? AND MID=?";
                ops = (OraclePreparedStatement) oconn.prepareCall(query);
                ops.setString(1, qty);
                ops.setString(2, odate);
                ops.setString(3, status);
                ops.setString(4, item_price);
                ops.setString(5, total);
                ops.setString(6, oid);
                ops.setString(7, cid);
                ops.setString(8, pid);
                ops.setString(9, mid);     
                x = ops.executeUpdate();
            }                          
            if(x>0){
                if(userType.equals("ADMIN")){
    %>
                <script>
                    // Edit successful for admin
                    location.href="http://localhost:8080/MinorWebApp/PageServes/orders.jsp?response=edit-success";
                </script>
    <%
                }else{
    %>
                <script>
                    // Edit success pharmacy
                    location.href="http://localhost:8080/MinorWebApp/PageServes/CheckOrders.jsp?response=edit-success";
                </script>
    <%
                }
            }else{
                if(userType.equals("ADMIN")){
    %>
                <script>
                    // Edit fail admin
                    location.href="http://localhost:8080/MinorWebApp/PageServes/orders.jsp?response=edit-failed";
                </script>
    <%
                }else{
    %>
                <script>
                    // Edit fail pharmacy
                    location.href="http://localhost:8080/MinorWebApp/PageServes/CheckOrders.jsp?response=edit-failed";
                </script>
    <%
                }
                oconn.close();
                ops.close();
            }
        }else{
            
            //sess.setAttribute("btnval", btnval);
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
        <title>Modify Orders</title>
        <script>
            window.onload = function() {
                // Auto select the old value.
                let status = "<%=status%>";
                document.getElementById('status').value = status;
                
                document.forms['register'].addEventListener('submit', function(event) {
                    if(!validateForm()) {
                        event.preventDefault();
                    } else {
                        window.location.hash = '';
                    }
                });
            };

            function validateForm() {
                var qty = document.forms['register']['qty'].value;
                //var email = document.forms['register']['email'].value;
                var odate = document.forms['register']['odate'].value;
                var status = document.forms['register']['status'].value;
                var item_price = document.forms['register']['item_price'].value;
                var total = document.forms['register']['total'].value;

                if(qty === "" || odate === "" || status === "" || item_price === "" || total === "") {
                    showError("All fields are required.");
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
    </head>
    <body>
    <header>
        <img src="../media/logo.png" class="logo">
        <span class="heading">MedFinder</span>
        <nav class="navbar">
        <%
        if(userType.equals("ADMIN")) {
            out.println("<a href='http://localhost:8080/MinorWebApp/StatPages/admin-database.html'>Home</a>");
        }
        else {
            out.println("<a href='http://localhost:8080/MinorWebApp/StatPages/PharmacyHome.html'>Home</a>");
        }
        %>
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
                <form method="POST" name="register">
                    <h2>EDIT ORDERS</h2>
                    <br>
                    <div id="error-alert"></div>
                    <br>
                    <h3>Date: <%=odate%></h3>
                    <br>
                    <div class="input-group">
                        <label for="oid">Order ID:</label>
                        <input type="text" id="oid" name="oid" value="<%=oid%>" readonly/>
                    </div>
                    <br>                    
                    <%
                        if(userType.equals("ADMIN")){
                    %>
                        <div class="input-group">
                            <label for="cid">Customer ID:</label>
                            <input type="text" id="cid" name="cid" value="<%=cid%>" readonly/>
                        </div>
                        <br>
                    <%
                        }
                    %>
                    <div class="input-group">
                        <label for="cname">Customer Name:</label>
                        <input type="text" name="cname" value="<%=cname%>" readonly/>
                    </div>
                    <br>
                    <%
                        if(userType.equals("ADMIN")){
                    %>
                        <div class="input-group">
                            <label for="pid">Pharmacy ID:</label>
                            <input type="text" id="pid" name="pid" value="<%=pid%>" readonly/>
                        </div>
                        <br>
                    <%
                        }
                    %>   
                    <div class="input-group">
                        <label for="pname">Pharmacy Name:</label>
                        <input type="text" name="pname" value="<%=p_name%>" readonly/>
                    </div>
                    <br>
                    <%
                        if(userType.equals("ADMIN")){
                    %>
                        <div class="input-group">
                            <label for="mid">Medicine ID:</label>
                            <input type="text" id="mid" name="mid" value="<%=mid%>" readonly/>
                        </div>
                        <br>
                    <%
                        }
                    %>  
                    <div class="input-group">
                        <label for="mname">Medicine Name:</label>
                        <input type="text" name="mname" value="<%=mname%>" readonly/>
                    </div>
                    <br>
                    <%
                        if(userType.equals("ADMIN")){
                    %>
                        <div class="input-group">
                            <label for="qty">Quantity:</label>
                            <input type="number" name="qty" value="<%=qty%>">
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="odate">Order Date:</label>
                            <input type="date" name="odate" value="<%=odate%>">
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="status">Status:</label>
                            <select id="status" name="status">
                                <option value="" disabled hidden>Select an option</option>
                                <option value="CART">Cart</option>
                                <option value="ORDERED">Ordered</option>
                                <option value="DISPATCHED">Dispatched</option>
                                <option value="DELIVERED">Delivered</option>
                            </select>
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="item_price">Item Price:</label>
                            <input type="number" name="item_price" value="<%=item_price%>">
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="total">Total:</label>
                            <input type="number" name="total" value="<%=total%>">
                        </div>
                        <br> 
                    <%
                        }else{
                    %>     
                        <div class="input-group">
                            <label for="qty">Quantity:</label>
                            <input type="number" name="qty" value="<%=qty%>" readonly/>
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="odate">Order Date:</label>
                            <input type="date" name="odate" value="<%=odate%>" readonly/>
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="status">Status:</label>
                            <select id="status" name="status">
                                <option value="" disabled hidden>Select an option</option>
                                <option value="CART">Cart</option>
                                <option value="ORDERED">Ordered</option>
                                <option value="DISPATCHED">Dispatched</option>
                                <option value="DELIVERED">Delivered</option>
                            </select>
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="item_price">Item Price:</label>
                            <input type="number" name="item_price" value="<%=item_price%>" readonly/>
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="total">Total:</label>
                            <input type="number" name="total" value="<%=total%>" readonly/>
                        </div>
                        <br> 
                    <%
                        }
                    %> 
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
