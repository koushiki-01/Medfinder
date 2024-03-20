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
    String query, email, userType, btnval, table, pid, pemail, password, pname, address, gstn, phone, status, pincode, sques, sans, city;
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
    if(userType.equals("PHARMACY"))
        pid = sess.getAttribute("pid").toString();
    if(userType.equals("PHARMACY"))
        btnval = userType+","+pid;
    else
        btnval = request.getParameter("Modify");

    if(btnval != null){
        int i = btnval.indexOf(",");
        table = btnval.substring(0,i);
        pid = btnval.substring(i+1);
    }
    try{
        DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
        oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);        
        query = "SELECT * FROM PHARMACY WHERE PID = ?";
        ops = (OraclePreparedStatement) oconn.prepareCall(query);
        ops.setString(1, pid);
        ors = (OracleResultSet) ops.executeQuery();
        ors.next();
        pemail = ors.getString("EMAIL");
        pname = ors.getString("PNAME");
        gstn = ors.getString("GSTN");
        address = ors.getString("ADDRESS");
        phone = ors.getString("PHONE");
        status = ors.getString("STATUS");
        pincode = ors.getString("PINCODE");
        sques = ors.getString("SQUES");
        sans = ors.getString("SANS");
        city = ors.getString("CITY");
        password = ors.getString("PASSWORD");

        if(request.getParameter("submit")!=null){
            pname = request.getParameter("pname");
            address = request.getParameter("address");
            gstn = request.getParameter("gstn");
            phone = request.getParameter("phone");
            status = request.getParameter("status");
            pincode = request.getParameter("pincode");
            sques = request.getParameter("sques");
            sans = request.getParameter("sans");
            city = request.getParameter("city");
            query = "UPDATE PHARMACY SET PNAME = ?, GSTN = ?, STATUS = ?, ADDRESS = ?, PHONE = ?, PINCODE = ?, SQUES = ?, SANS = ?, CITY = ? WHERE PID=?";
            ops = (OraclePreparedStatement) oconn.prepareCall(query);
            ops.setString(1, pname);
            ops.setString(2, gstn);
            ops.setString(3, status);
            ops.setString(4, address);
            ops.setString(5, phone);
            ops.setString(6, pincode);
            ops.setString(7, sques);
            ops.setString(8, sans);
            ops.setString(9, city);                        
            ops.setString(10, pid);          
            int x = ops.executeUpdate();
if(x>0){
                if(userType.equals("ADMIN")){
    %>
                <script>
                    // Edit success ADMIN
                    location.href="http://localhost:8080/MinorWebApp/PageServes/pharmacy.jsp?response=edit-success";
                </script>
    <%
                }else{
    %>
                <script>
                    // Edit success PHARMACY
                    location.href="http://localhost:8080/MinorWebApp/StatPages/PharmacyHome.html?response=edit-success";
                </script>
    <%
                }
            }else{
                if(userType.equals("ADMIN")){
    %>
                <script>
                    // Edit failed ADMIN
                    location.href="http://localhost:8080/MinorWebApp/PageServes/pharmacy.jsp?response=edit-fail";
                </script>
    <%
                }else{
    %>
                <script>
                    // Edit failed PHARMACY
                    location.href="http://localhost:8080/MinorWebApp/StatPages/PharmacyHome.html?response=edit-fail";
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
        <title>Edit Pharmacy</title>
        <script src="/MinorWebApp/scripts/showResponse.js"></script>
        <script>
            window.onload = function() {
                // Auto select old values
                let city = "<%=city%>";
                document.getElementById('city').value = city;
                let sques = "<%=sques%>";
                document.getElementById('sques').value = sques;
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
                var pname = document.forms['register']['pname'].value;
                //var email = document.forms['register']['email'].value;
                var phone = document.forms['register']['phone'].value;
                var address = document.forms['register']['address'].value;
                var pincode = document.forms['register']['pincode'].value;
                var gstn = document.forms['register']['gstn'].value;

                if(pname === "" || phone === "" || address === "" || pincode === "" || gstn === "") {
                    showError("All fields are required.");
                    return false;
                }
                if(phone.length !== 10 || isNaN(phone)) {
                    showError("Please enter a valid phone number.");
                    return false;
                }
                if(pincode.length !== 6 || isNaN(pincode)) {
                    showError("Please enter a valid pincode.");
                    return false;
                }
                if(password.length < 8) {
                    showError("Password must be at least 8 characters.");
                    return false;
                }
                if(gstn.length !== 15) {
                    showError("Invalid GST number. GSTN should be 15 characters only!");
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
        <script src="/MinorWebApp/scripts/deleteModal.js"></script>
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
                    <h2>EDIT PHARMACY</h2>
                    <br>
                    <div id="error-alert"></div>
                    <div id="success-alert"></div>
                    <%
                        if(userType.equals("ADMIN")){
                    %>
                        <br>
                        <div class="input-group">
                            <label for="pid">Pharmacy ID:</label>
                            <input type="text" id="pid" name="pid" value="<%=pid%>" readonly/>
                        </div>
                    <%
                        }
                    %>
                    <br>
                    <div class="input-group">
                        <label for="email">Email:</label>
                        <input type="email" name="email" value="<%=pemail%>" readonly/>
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="pname">Pharmacy Name:</label>
                        <input type="text" name="pname" value="<%=pname%>">
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="gstn">GSTN:</label>
                        <input type="text" name="gstn" value="<%=gstn%>">
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="phone">Phone:</label>
                        <input type="text" name="phone" value="<%=phone%>">
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="status">Status:</label>
                        <select id="status" name="status">
                            <option value="OPERATIONAL">Operational</option>
                            <option value="CLOSED">Closed</option>
                            <option value="SUSPENDED">Suspended</option>
                        </select>
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="address">Address:</label>
                        <input type="text" name="address" value="<%=address%>">
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="city">City:</label>
                        <select id="city" name="city">
                            <option value="" disabled hidden>Select a City</option>
                            <option value="KOLKATA">Kolkata</option>
                            <option value="HOWRAH">Howrah</option>
                            <option value="BURDWAN">Burdwan</option>
                            <option value="DURGAPUR">Durgapur</option>
                        </select>
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="pincode">Pincode:</label>
                        <input type="number" name="pincode" value="<%=pincode%>" oninput="maxInputNumber(this,6)">
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="sques">Security Question:</label>
                        <select id="sques" name="sques">
                            <option value="" disabled hidden>Select a Security Question</option>
                            <option value="CHILDHOOD NICKNAME?">Childhood nickname?</option>
                            <option value="WHAT IS YOUR MOTHER'S MAIDEN NAME?">What is your mother's maiden name?</option>
                            <option value="WHAT SCHOOL DID YOU GO TO?">What school did you go to?</option>
                        </select>
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="sans">Security Answer:</label>
                        <input type="text" name="sans" value="<%=sans%>">
                    </div>                          
                    <br>    
                    <div class="input-group button-group">
                        <label></label>
                        <button type="submit" name="submit" class="button-80">Submit</button>
                        <button type="reset" class="button-80">Clear</button>
                   </div>                   
                </form>
                <div class="delete-button-container">
                    <button type="button" id="delete" class="delete-button" onclick="openDeleteModal()">Delete Pharmacy</button>
                </div>
                <div id="deleteModal" class="delete-modal">
                    <div class="delete-modal-content">
                        <h2>Warning!</h2>
                        <br>
                        <p>Are you sure you want to delete this pharmacy?</p>
                        <br>
                        <div class="delete-modal-button">
                            <button type="button" onclick="closeDeleteModal()">No</button>
                            <form method="POST" action="http://localhost:8080/MinorWebApp/DeleteAll">
                                <button type="submit" name="Delete" value="<%=btnval%>">Yes</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
    <script>
        let params = (new URL(document.location)).searchParams;
        let response = params.get("response");

        if (response == "edit-success") {
            showSuccess("Profile edited successfully.");
            params.delete('response');
            window.history.replaceState({}, document.title, url.toString());
        }
        if (response == "delete-error") {
            showError("Data cannot be deleted because it has records in the child table.");
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

