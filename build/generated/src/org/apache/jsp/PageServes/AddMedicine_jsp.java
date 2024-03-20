package org.apache.jsp.PageServes;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;
import java.sql.SQLException;
import java.sql.DriverManager;
import java.io.IOException;
import java.util.Properties;
import java.io.InputStream;
import oracle.jdbc.OracleResultSet;
import oracle.jdbc.OraclePreparedStatement;
import oracle.jdbc.OracleConnection;

public final class AddMedicine_jsp extends org.apache.jasper.runtime.HttpJspBase
    implements org.apache.jasper.runtime.JspSourceDependent {


    String mname, query, mid, email, pid, pname;
    OracleConnection oconn;
    OraclePreparedStatement ops;
    OracleResultSet ors = null;           
    HttpSession sess;
    String oconnUrl, oconnUsername, oconnPassword;

  private static final JspFactory _jspxFactory = JspFactory.getDefaultFactory();

  private static java.util.List<String> _jspx_dependants;

  private org.glassfish.jsp.api.ResourceInjector _jspx_resourceInjector;

  public java.util.List<String> getDependants() {
    return _jspx_dependants;
  }

  public void _jspService(HttpServletRequest request, HttpServletResponse response)
        throws java.io.IOException, ServletException {

    PageContext pageContext = null;
    HttpSession session = null;
    ServletContext application = null;
    ServletConfig config = null;
    JspWriter out = null;
    Object page = this;
    JspWriter _jspx_out = null;
    PageContext _jspx_page_context = null;

    try {
      response.setContentType("text/html;charset=UTF-8");
      pageContext = _jspxFactory.getPageContext(this, request, response,
      			null, true, 8192, true);
      _jspx_page_context = pageContext;
      application = pageContext.getServletContext();
      config = pageContext.getServletConfig();
      session = pageContext.getSession();
      out = pageContext.getOut();
      _jspx_out = out;
      _jspx_resourceInjector = (org.glassfish.jsp.api.ResourceInjector) application.getAttribute("com.sun.appserv.jsp.resource.injector");

      out.write("\r\n");
      out.write("\r\n");
      out.write("\r\n");
      out.write("\r\n");
      out.write("\r\n");
      out.write("\r\n");
      out.write("\r\n");
      out.write("\r\n");
      out.write("\r\n");
      out.write('\r');
      out.write('\n');

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
    
      out.write("\r\n");
      out.write("                <script>\r\n");
      out.write("                    //  Medicine already exists in stock.\r\n");
      out.write("                    location.href=\"http://localhost:8080/MinorWebApp/PageServes/AddMedicine.jsp?response=exists\";\r\n");
      out.write("                </script>\r\n");
      out.write("    ");

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
            
      out.write("\r\n");
      out.write("                        <script>\r\n");
      out.write("                            // Data inserted successfully.\r\n");
      out.write("                            location.href=\"http://localhost:8080/MinorWebApp/PageServes/AddMedicine.jsp?response=success\";\r\n");
      out.write("                        </script>\r\n");
      out.write("            ");

                    }   
                    else{
            
      out.write("\r\n");
      out.write("                        <script>\r\n");
      out.write("                            // Data insertion failed.\r\n");
      out.write("                            location.href=\"http://localhost:8080/MinorWebApp/PageServes/AddMedicine?response=failed\";\r\n");
      out.write("\r\n");
      out.write("                        </script>\r\n");
      out.write("            ");

                    }
                }    
                else{
            
      out.write("\r\n");
      out.write("                    <script>\r\n");
      out.write("                        // Medicine does not exist in DB.\r\n");
      out.write("                        location.href=\"http://localhost:8080/MinorWebApp/PageServes/AddNewMedicine.jsp?response=new-medicine\";\r\n");
      out.write("                        //Change the link here or make a system so it automatically creates a new medicine in the database\r\n");
      out.write("                    </script>\r\n");
      out.write("            ");
            
                }
            }
            ops.close();
            oconn.close();
        }catch (SQLException ex) {
            out.println("<h2 style='color:red'>Error is: "+ ex.toString() + "</h2>");
        }
    }

      out.write("\r\n");
      out.write("<!DOCTYPE html>\r\n");
      out.write("<html>\r\n");
      out.write("    <head>\r\n");
      out.write("        <meta charset=\"UTF-8\">\r\n");
      out.write("    <link rel=\"icon\" href=\"../media/favion.ico\" type=\"image/x-icon\">\r\n");
      out.write("        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\r\n");
      out.write("        <link rel=\"stylesheet\" href=\"../stylesheet/main-style.css\">\r\n");
      out.write("        <title>Add Medicine</title>\r\n");
      out.write("        <script>\r\n");
      out.write("            window.onload = function() {\r\n");
      out.write("                document.forms['add-medicine'].addEventListener('submit', function(event) {\r\n");
      out.write("                    if(!validateForm()) {\r\n");
      out.write("                        event.preventDefault();\r\n");
      out.write("                    } else {\r\n");
      out.write("                        window.location.hash = '';\r\n");
      out.write("                    }\r\n");
      out.write("                });\r\n");
      out.write("            };\r\n");
      out.write("\r\n");
      out.write("            function validateForm() {\r\n");
      out.write("                var mname = document.forms['add-medicine']['mname'].value;\r\n");
      out.write("                \r\n");
      out.write("                if(mname === \"\") {\r\n");
      out.write("                    showError(\"Please enter a valid name.\");\r\n");
      out.write("                    return false;\r\n");
      out.write("                }\r\n");
      out.write("                return true;\r\n");
      out.write("            }\r\n");
      out.write("       </script>\r\n");
      out.write("    </head>\r\n");
      out.write("    <body>\r\n");
      out.write("        <header>\r\n");
      out.write("            <img src=\"../media/logo.png\" class=\"logo\">   \r\n");
      out.write("            <span class=\"heading\">MedFinder</span>\r\n");
      out.write("            <nav class=\"navbar\">\r\n");
      out.write("                <a href=\"http://localhost:8080/MinorWebApp/StatPages/PharmacyHome.html\">Home</a>\r\n");
      out.write("                <a href=\"http://localhost:8080/MinorWebApp/StatPages/about.html\">About Us</a>\r\n");
      out.write("                <a href=\"http://localhost:8080/MinorWebApp/PageServes/FeedBack.jsp\">Feedback</a>\r\n");
      out.write("                <div class=\"navbar-dropdown\">\r\n");
      out.write("                    <a class=\"navbar-dropdown-button\">Settings</a>\r\n");
      out.write("                    <div class=\"navbar-dropdown-content\">\r\n");
      out.write("                        <a href=\"http://localhost:8080/MinorWebApp/SessLogOut\">Log Out</a>\r\n");
      out.write("                        <a href=\"http://localhost:8080/MinorWebApp/PageServes/changePassword.jsp\">Change Password</a>\r\n");
      out.write("                    </div>\r\n");
      out.write("                </div>\r\n");
      out.write("            </nav>\r\n");
      out.write("        </header>\r\n");
      out.write("        <main>\r\n");
      out.write("            <div class=\"form-container\">\r\n");
      out.write("                <div class=\"form-box\">\r\n");
      out.write("                    <form method=\"POST\" name=\"add-medicine\">\r\n");
      out.write("                        <h2>ADD MEDICINE</h2>\r\n");
      out.write("                        <br>\r\n");
      out.write("                        <div id=\"error-alert\"></div>\r\n");
      out.write("                        <div id=\"success-alert\"></div>\r\n");
      out.write("                        <br>\r\n");
      out.write("                        <div class=\"input-group\">\r\n");
      out.write("                            <label for=\"mname\">Medicine Name:</label>\r\n");
      out.write("                            <input type=\"text\" name=\"mname\" placeholder=\"Enter a new Medicine\">\r\n");
      out.write("                        </div>\r\n");
      out.write("                        <br>\r\n");
      out.write("                        <div class=\"input-group button-group\">\r\n");
      out.write("                            <label></label>\r\n");
      out.write("                            <button type=\"submit\" name=\"submit\" class=\"button-80\">Submit</button>\r\n");
      out.write("                    </div>              \r\n");
      out.write("                    </form>\r\n");
      out.write("                </div>\r\n");
      out.write("            </div>\r\n");
      out.write("        </main>\r\n");
      out.write("        <script src=\"/MinorWebApp/scripts/showResponse.js\"></script>\r\n");
      out.write("        <script>\r\n");
      out.write("            let params = (new URL(document.location)).searchParams;\r\n");
      out.write("            let response = params.get(\"response\");\r\n");
      out.write("\r\n");
      out.write("            if (response == \"success\") {\r\n");
      out.write("                showSuccess(\"Medicine inserted successful.<br>Please update it's stock <a href='http://localhost:8080/MinorWebApp/PageServes/UpdateInventory.jsp'>here</a>.\");\r\n");
      out.write("                params.delete('response');\r\n");
      out.write("                window.history.replaceState({}, document.title, url.toString());\r\n");
      out.write("            }\r\n");
      out.write("            if(response == \"failed\") {\r\n");
      out.write("                showError(\"Failed to add medicine to inventory.<br>Try again later.\");\r\n");
      out.write("                params.delete('response');\r\n");
      out.write("                window.history.replaceState({}, document.title, url.toString());\r\n");
      out.write("            }\r\n");
      out.write("            if(response == \"exists\") {\r\n");
      out.write("                showError(\"Medicine already exists in your inventory.<br>Please update it's stock <a href='http://localhost:8080/MinorWebApp/PageServes/UpdateInventory.jsp'>here</a>.\");\r\n");
      out.write("                params.delete('response');\r\n");
      out.write("                window.history.replaceState({}, document.title, url.toString());\r\n");
      out.write("            }\r\n");
      out.write("            if(response == \"new-added\") {\r\n");
      out.write("                showSuccess(\"Medicine added to database successful.<br>Please add it to your inventory here.</a>\");\r\n");
      out.write("                params.delete('response');\r\n");
      out.write("                window.history.replaceState({}, document.title, url.toString());\r\n");
      out.write("            }\r\n");
      out.write("        </script>\r\n");
      out.write("        <footer>\r\n");
      out.write("            <a href=\"https://www.facebook.com\" target=\"_blank\"><img src=\"../media/facebook-icon.png\" class=\"social-icon\" alt=\"Facebook\"></a>\r\n");
      out.write("            <a href=\"https://www.twitter.com\" target=\"_blank\"><img src=\"../media/twitter-icon.ico\" class=\"social-icon\" alt=\"Twitter\"></a>\r\n");
      out.write("            <a href=\"https://www.pinterest.com\" target=\"_blank\"><img src=\"../media/pinterest-icon.png\" class=\"social-icon\" alt=\"Pintrest\"></a>\r\n");
      out.write("        </footer>\r\n");
      out.write("    </body>\r\n");
      out.write("</html>\r\n");
      out.write("\r\n");
    } catch (Throwable t) {
      if (!(t instanceof SkipPageException)){
        out = _jspx_out;
        if (out != null && out.getBufferSize() != 0)
          out.clearBuffer();
        if (_jspx_page_context != null) _jspx_page_context.handlePageException(t);
        else throw new ServletException(t);
      }
    } finally {
      _jspxFactory.releasePageContext(_jspx_page_context);
    }
  }
}
