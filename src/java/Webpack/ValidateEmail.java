package Webpack;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import oracle.jdbc.OracleConnection;
import oracle.jdbc.OraclePreparedStatement;
import oracle.jdbc.OracleResultSet;

@WebServlet(name = "ValidateEmail", urlPatterns = {"/ValidateEmail"})
public class ValidateEmail extends HttpServlet {
    OracleConnection oconn;
    OraclePreparedStatement ops1, ops2, ops3;
    OracleResultSet ors1, ors2, ors3;
    String email, userType, table;
    String vto, vfrom, vsubject, vbody; //Variables required to compose the email 
    
    // Oconn connection handling, change the classname in the try line: classname.class.getClassLoader()
    private String oconnUrl;
    private String oconnUsername;
    private String oconnPassword;
    private String mailUsername;
    private String mailPassword;

    @Override
    public void init() throws ServletException {
        super.init();
        // Loads src/java/db.properties
        try (InputStream input = ValidateEmail.class.getClassLoader().getResourceAsStream("db.properties")) {
            Properties props = new Properties();
            props.load(input);
            oconnUrl = "jdbc:oracle:thin:@" + props.getProperty("hostname") + ":"
                  + props.getProperty("port") + ":" + props.getProperty("SID");
            oconnUsername = props.getProperty("username");
            oconnPassword = props.getProperty("password");
        } catch (IOException ex) {
            throw new ServletException(ex);
        }
        // Loads src/java/mail.properties
        try (InputStream mailInput = ValidateEmail.class.getClassLoader().getResourceAsStream("mail.properties")) {
        Properties mailProps = new Properties();
        mailProps.load(mailInput);
        mailUsername = mailProps.getProperty("username");
        mailPassword = mailProps.getProperty("password");
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
            out.println("<title>Servlet ValidateEmail</title>");            
            out.println("</head>");
            out.println("<body>");
            email = request.getParameter("email");
            email = email.toLowerCase();
            try {
                DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                oconn = (OracleConnection) DriverManager.getConnection(oconnUrl,oconnUsername,oconnPassword);
                ops1 = (OraclePreparedStatement) oconn.prepareStatement("SELECT * FROM ADMIN WHERE EMAIL = ?");
                ops1.setString(1,email);
                ors1 = (OracleResultSet) ops1.executeQuery();
                ops2 = (OraclePreparedStatement) oconn.prepareStatement("SELECT * FROM CUSTOMER WHERE EMAIL = ?");
                ops2.setString(1,email);
                ors2 = (OracleResultSet) ops2.executeQuery();
                ops3 = (OraclePreparedStatement) oconn.prepareStatement("SELECT * FROM PHARMACY WHERE EMAIL = ?");
                ops3.setString(1,email);
                ors3 = (OracleResultSet) ops3.executeQuery();
                boolean ors1val = ors1.next();
                boolean ors2val = ors2.next();
                boolean ors3val = ors3.next();
                if(ors1val){
                    userType = "ADMIN";
                    HttpSession sess = request.getSession(true);
                    sess.setAttribute("userType",userType);
                    out.println("<h2>Inside ADMIN</h2>");
                }if(ors2val){
                    userType = "CUSTOMER";
                    HttpSession sess = request.getSession(true);
                    sess.setAttribute("userType",userType);
                    out.println("<h2>Inside CUSTOMER</h2>");
                }
                if(ors3val){
                    userType = "PHARMACY";
                    HttpSession sess = request.getSession(true);
                    sess.setAttribute("userType",userType);
                    out.println("<h2>Inside PHARMACY</h2>");
                }
                if(ors1val || ors2val || ors3val)
                {
                    vto = email;                    
                    vsubject = "MedFinder - Forgot Password";
                    vbody = "Please click the link below or copy paste it in your browser to reset your password:\n";
                    final String username = mailUsername;
                    final String password = mailPassword;
                    Properties props = new Properties();
                    props.put("mail.smtp.auth","true");
                    props.put("mail.smtp.starttls.enable","true");
                    props.put("mail.smtp.host","smtp.gmail.com");
                    props.put("mail.smtp.port","587");
                    
                    Session session = Session.getInstance(props, new javax.mail.Authenticator(){ 
                        protected PasswordAuthentication getPasswordAuthentication(){ 
                            return new PasswordAuthentication(username,password);
                        }
                    });
                    try{
                        Message message = new MimeMessage(session);
                        message.setFrom(new InternetAddress(username));
                        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(vto));
                        message.setSubject(vsubject);
                        vbody += " http://localhost:8080/MinorWebApp/PageServes/VerifyQuestion.jsp?pemail="+email;
                        message.setText(vbody);
                        Transport.send(message);
                        response.sendRedirect("http://localhost:8080/MinorWebApp/StatPages/ForgotClose.html");
                    }
                    catch(MessagingException ex)
                    {
                        out.println("<h2 style='color:red'>"+ex.getMessage()+"</h2>");
                    }
                }else{
                    response.sendRedirect("http://localhost:8080/MinorWebApp/StatPages/WrongEmail.html");
                }
                ops1.close();
                ops2.close();
                oconn.close();
            } catch (SQLException ex) {
                Logger.getLogger(ValidateEmail.class.getName()).log(Level.SEVERE, null, ex);
                out.println("<h2 style='color:red'>"+ex.getMessage()+"</h2>");
            }
            out.println("<h1>Servlet ValidateEmail at " + request.getContextPath() + "</h1>");
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
