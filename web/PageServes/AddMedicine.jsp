<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.io.IOException"%>
<%@page import="java.util.Properties"%>
<%@page import="java.io.InputStream"%>
<%@page import="oracle.jdbc.OracleResultSet"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    String mname, query, mid, email, pid, pname;
    OracleConnection oconn;
    OraclePreparedStatement ops;
    OracleResultSet ors = null;           
    HttpSession sess;
    String oconnUrl, oconnUsername, oconnPassword;
%>
<%
    try {
        InputStream input = application.getResourceAsStream("/WEB-INF/db.properties");
        Properties props = new Properties();
        props.load(input);
        oconnUrl = "jdbc:oracle:thin:@" + props.getProperty("hostname") + ":"
            + props.getProperty("port") + ":" + props.getProperty("SID");
        oconnUsername = props.getProperty("username");
        oconnPassword = props.getProperty("password");
    } catch (IOException ex) {
        out.println("Error: " + ex.getMessage());
    }
    if(request.getParameter("submit")!=null){
        sess = request.getSession(false);
        if(sess!=null)
            email = sess.getAttribute("email").toString();
        mname = request.getParameter("mname");
        sess.setAttribute("mname",mname);
        mname = mname.trim();
        mname = mname.toUpperCase();
        try{
            DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
            oconn = (OracleConnection) DriverManager.getConnection(oconnUrl,oconnUsername,oconnPassword);
            query = "SELECT * FROM PHARM_MED_STOCK WHERE MID = (SELECT MID FROM MEDICINE WHERE MNAME = ?) AND PID = (SELECT PID FROM PHARMACY WHERE EMAIL = ?)";
            ops = (OraclePreparedStatement) oconn.prepareStatement(query);
            ops.setString(1,mname);
            ops.setString(2,email);
            ors = (OracleResultSet)ops.executeQuery();
            if(ors.next())
            {
    %>
                <script>
                    //  Medicine already exists in stock.
                    location.href="http://localhost:8080/MinorWebApp/PageServes/AddMedicine.jsp?response=exists";
                </script>
    <%
            }else{
                query = "SELECT * FROM MEDICINE WHERE MNAME = ?";
                ops = (OraclePreparedStatement) oconn.prepareStatement(query);
                ops.setString(1,mname);
                ors = (OracleResultSet)ops.executeQuery();
                if(ors.next())
                {
                    mid = ors.getString("MID");
                    query = "SELECT * FROM PHARMACY WHERE EMAIL = ?";
                    ops = (OraclePreparedStatement) oconn.prepareStatement(query);
                    ops.setString(1,email);
                    ors = (OracleResultSet) ops.executeQuery();
                    ors.next();
                    pid = ors.getString("PID");
                    query = "INSERT INTO PHARM_MED_STOCK (PID, MID) VALUES (?,?)";
                    ops = (OraclePreparedStatement) oconn.prepareCall(query);
                    ops.setString(1,pid);
                    ops.setString(2,mid);
                    int x = ops.executeUpdate();
                    if(x>0){
            %>
                        <script>
                            // Data inserted successfully.
                            location.href="http://localhost:8080/MinorWebApp/PageServes/AddMedicine.jsp?response=success";
                        </script>
            <%
                    }   
                    else{
            %>
                        <script>
                            // Data insertion failed.
                            location.href="http://localhost:8080/MinorWebApp/PageServes/AddMedicine?response=failed";

                        </script>
            <%
                    }
                }    
                else{
            %>
                    <script>
                        // Medicine does not exist in DB.
                        location.href="http://localhost:8080/MinorWebApp/PageServes/AddNewMedicine.jsp?response=new-medicine";
                        //Change the link here or make a system so it automatically creates a new medicine in the database
                    </script>
            <%            
                }
            }
            ops.close();
            oconn.close();
        }catch (SQLException ex) {
            out.println("<h2 style='color:red'>Error is: "+ ex.toString() + "</h2>");
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
    <link rel="icon" href="../media/favion.ico" type="image/x-icon">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="../stylesheet/main-style.css">
        <title>Add Medicine</title>
        <script>
            window.onload = function() {
                document.forms['add-medicine'].addEventListener('submit', function(event) {
                    if(!validateForm()) {
                        event.preventDefault();
                    } else {
                        window.location.hash = '';
                    }
                });
            };

            function validateForm() {
                var mname = document.forms['add-medicine']['mname'].value;
                
                if(mname === "") {
                    showError("Please enter a valid name.");
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
                    <form method="POST" name="add-medicine">
                        <h2>ADD MEDICINE</h2>
                        <br>
                        <div id="error-alert"></div>
                        <div id="success-alert"></div>
                        <br>
                        <div class="input-group">
                            <label for="mname">Medicine Name:</label>
                            <input type="text" name="mname" placeholder="Enter a new Medicine">
                        </div>
                        <br>
                        <div class="input-group button-group">
                            <label></label>
                            <button type="submit" name="submit" class="button-80">Submit</button>
                    </div>              
                    </form>
                </div>
            </div>
        </main>
        <script src="/MinorWebApp/scripts/showResponse.js"></script>
        <script>
            let params = (new URL(document.location)).searchParams;
            let response = params.get("response");

            if (response == "success") {
                showSuccess("Medicine inserted successful.<br>Please update it's stock <a href='http://localhost:8080/MinorWebApp/PageServes/UpdateInventory.jsp'>here</a>.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
            if(response == "failed") {
                showError("Failed to add medicine to inventory.<br>Try again later.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
            if(response == "exists") {
                showError("Medicine already exists in your inventory.<br>Please update it's stock <a href='http://localhost:8080/MinorWebApp/PageServes/UpdateInventory.jsp'>here</a>.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
            if(response == "new-added") {
                showSuccess("Medicine added to database successful.<br>Please add it to your inventory here.</a>");
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

