
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
import oracle.jdbc.OracleConnection;
import oracle.jdbc.OraclePreparedStatement;
import oracle.jdbc.OracleResultSet;


@WebServlet(name = "RegisterPharmacy", urlPatterns = {"/RegisterPharmacy"})
public class RegisterPharmacy extends HttpServlet {
    String pid, pname, gstn, email, phone, address, pincode, password, status = "OPERATIONAL", sques, sans, pidNum, city;
    //The below query gives us the last PID in the database, if #rows = NULL, retuns 0
    String query = "SELECT NVL((SELECT * FROM (SELECT PID FROM PHARMACY ORDER BY PID DESC) WHERE ROWNUM <=1),'0') AS PID FROM DUAL";
    OracleConnection oconn;
    OraclePreparedStatement ops;
    OracleResultSet ors;
    
    // Oconn connection handling, change the classname in the try line: classname.class.getClassLoader()
    private String oconnUrl;
    private String oconnUsername;
    private String oconnPassword;

    @Override
    public void init() throws ServletException {
        super.init();

        try (InputStream input = RegisterPharmacy.class.getClassLoader().getResourceAsStream("db.properties")) {
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
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet RegisterPharmacy</title>");            
            out.println("</head>");
            out.println("<body>");
            pname = request.getParameter("pname");
            gstn = request.getParameter("gstn");
            email = request.getParameter("email");
            phone = request.getParameter("phone");
            address = request.getParameter("address");
            pincode = request.getParameter("pincode");
            password = request.getParameter("password");
            sques = request.getParameter("sques");
            sans = request.getParameter("sans");
            city = request.getParameter("city");
            try {
                DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);
                //Instantiating the OraclePreparedStatement
                ops = (OraclePreparedStatement) oconn.prepareCall(query);
                //Extecuting the query to get the last PID
                ors = (OracleResultSet) ops.executeQuery();
                //To check if there is a row available
                ors.next();
                //Getting the last PID in the database
                String lastPID = ors.getString("PID");   
                if(lastPID.equals("0"))
                {
                    pid = "P1000";
                }           
                else
                {
                    //Getting the PID number
                    int lastPIDNum = Integer.parseInt(lastPID.substring(1));
                    pidNum = ""+(lastPIDNum+1);
                    //Setting the new PID
                    pid = "P"+pidNum;
                }
                pname = pname.trim();
                address = address.trim();
                email = email.trim();
                sans = sans.trim();
                password = password.trim();
                pname = pname.toUpperCase();
                address = address.toUpperCase();
                email = email.toLowerCase();
                sans = sans.toUpperCase();
                password = hash.passwordHash(password);
                ops = (OraclePreparedStatement) oconn.prepareCall("INSERT INTO PHARMACY(PID,PNAME,PASSWORD,ADDRESS,GSTN,EMAIL,PHONE,STATUS,PINCODE,SQUES,SANS,CITY) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)");
                ops.setString(1,pid);
                ops.setString(2,pname);
                ops.setString(3,password);
                ops.setString(4,address);
                ops.setString(5,gstn);
                ops.setString(6,email);
                ops.setString(7,phone);
                ops.setString(8,status);
                ops.setString(9,pincode);
                ops.setString(10,sques);
                ops.setString(11,sans);
                ops.setString(12,city);
                int x = ops.executeUpdate();
                if(x>0){
                    out.println("<script>");
                    // Account created successfully.
                    out.println("location.href='http://localhost:8080/MinorWebApp/StatPages/login.html?response=account-created';");
                    out.println("</script>");
                }
                else{
                    out.println("<script>");
                    // Failed to created account
                    out.println("location.href='http://localhost:8080/MinorWebApp/StatPages/login.html?response=account-failed';");
                    out.println("</script>");
                }
                oconn.close();
                ops.close();
            } catch (SQLException ex) {
                Logger.getLogger(RegisterPharmacy.class.getName()).log(Level.SEVERE, null, ex);
                out.println("<h2 style='color:red'>Error is: "+ ex.toString() + "</h2>");
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
