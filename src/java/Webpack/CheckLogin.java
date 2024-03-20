package Webpack;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import oracle.jdbc.OracleConnection;
import oracle.jdbc.OraclePreparedStatement;
import oracle.jdbc.OracleResultSet;

@WebServlet(name = "CheckLogin", urlPatterns = {"/CheckLogin"})
public class CheckLogin extends HttpServlet {
    OracleConnection oconn;
    OraclePreparedStatement ops1, ops2, ops3;
    OracleResultSet ors1=null, ors2=null, ors3=null;
    String email, password, userType;
    
    // Oconn connection handling, change the classname in the try line: classname.class.getClassLoader()
    private String oconnUrl;
    private String oconnUsername;
    private String oconnPassword;
    
    @Override
    public void init() throws ServletException {
        super.init();

        try (InputStream input = CheckLogin.class.getClassLoader().getResourceAsStream("db.properties")) {
            Properties props = new Properties();
            props.load(input);
            oconnUrl = "jdbc:oracle:thin:@" + props.getProperty("hostname") + ":"
                  + props.getProperty("port") + ":" + props.getProperty("SID");
            oconnUsername = props.getProperty("username");
            oconnPassword = props.getProperty("password");
        } catch (IOException ex) {
            throw new ServletException(ex);
        }
    }
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet CheckLogin</title>");            
            out.println("</head>");
            out.println("<body>");
            email = request.getParameter("email");
            password = request.getParameter("password");
            password = hash.passwordHash(password);
            email = email.toLowerCase();
            try {
                DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                oconn = (OracleConnection) DriverManager.getConnection(oconnUrl,oconnUsername,oconnPassword);
                ops1 = (OraclePreparedStatement) oconn.prepareStatement("SELECT * FROM ADMIN WHERE EMAIL = ? AND PASSWORD = ?");
                ops1.setString(1,email);
                ops1.setString(2,password);
                ors1 = (OracleResultSet) ops1.executeQuery();
                ops2 = (OraclePreparedStatement) oconn.prepareStatement("SELECT * FROM CUSTOMER WHERE EMAIL = ? AND PASSWORD = ?");
                ops2.setString(1,email);
                ops2.setString(2,password);
                ors2 = (OracleResultSet) ops2.executeQuery();
                ops3 = (OraclePreparedStatement) oconn.prepareStatement("SELECT * FROM PHARMACY WHERE EMAIL = ? AND PASSWORD = ?");
                ops3.setString(1,email);
                ops3.setString(2,password);
                ors3 = (OracleResultSet) ops3.executeQuery();
                if(ors1.next()){
                    userType = "ADMIN";
                    HttpSession sess = request.getSession(true);
                    sess.setAttribute("userType",userType);
                    sess.setAttribute("email",email);
                    response.sendRedirect("http://localhost:8080/MinorWebApp/StatPages/admin-database.html");
                }else if(ors2.next()){
                    userType = "CUSTOMER";
                    HttpSession sess = request.getSession(true);
                    sess.setAttribute("userType",userType);
                    sess.setAttribute("email",email);
                    response.sendRedirect("http://localhost:8080/MinorWebApp/PageServes/SearchMedicine.jsp");
                }else if(ors3.next()){
                    userType = "PHARMACY";
                    String pid = ors3.getString(1);
                    HttpSession sess = request.getSession(true);
                    sess.setAttribute("userType",userType);
                    sess.setAttribute("email",email);
                    sess.setAttribute("pid", pid);
                    response.sendRedirect("http://localhost:8080/MinorWebApp/StatPages/PharmacyHome.html");
                }else{
                    // response.sendRedirect("http://localhost:8080/MinorWebApp/StatPages/WrongPass.html");
                    response.sendRedirect("http://localhost:8080/MinorWebApp/StatPages/login.html?response=incorrect-password");
                }
                ops1.close();
                ops2.close();
                oconn.close();
            } catch (SQLException ex) {
                Logger.getLogger(CheckLogin.class.getName()).log(Level.SEVERE, null, ex);
                out.println("<h2 style='color: red'>"+ex.getMessage()+"</h2>");
                
            }
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
