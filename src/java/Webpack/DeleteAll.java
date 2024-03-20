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


@WebServlet(name = "DeleteAll", urlPatterns = {"/DeleteAll"})
public class DeleteAll extends HttpServlet {

    String btnval,table,query,userType;
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

        try (InputStream input = DeleteAll.class.getClassLoader().getResourceAsStream("db.properties")) {
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
            throws ServletException, IOException, SQLException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet DeleteAll</title>");            
            out.println("</head>");
            out.println("<body>");
            HttpSession sess = request.getSession(false);
            if(sess!=null)
                userType = sess.getAttribute("userType").toString();
            btnval = request.getParameter("Delete");
            int i = btnval.indexOf(",");
            table = btnval.substring(0,i);
            if(table.equals("CUSTOMER")){
                String cid = btnval.substring(i+1);
                query = "DELETE FROM "+table+" WHERE CID = '"+cid+"'";
            }else if(table.equals("PHARMACY")){
                String pid = btnval.substring(i+1);
                query = "DELETE FROM "+table+" WHERE PID = '"+pid+"'";
            }else if(table.equals("MEDICINE")){
                String mid = btnval.substring(i+1);
                out.println("<h3>MID: " + mid + "</h3>");
                query = "DELETE FROM "+table+" WHERE MID = '"+mid+"'";
            }else if(table.equals("PHARM_MED_STOCK")){
                int j = btnval.lastIndexOf(",");
                String pid = btnval.substring(i+1,j);
                String mid = btnval.substring(j+1);
                query = "DELETE FROM "+table+" WHERE PID = '"+pid+"' AND MID ='"+mid+"'";
            }else if(table.equals("ORDERS")){
                int j = btnval.indexOf(",",btnval.indexOf(",")+1);
                int k = btnval.indexOf(",",btnval.indexOf(",",btnval.indexOf(",")+1)+1);
                int l = btnval.lastIndexOf(",");
                String oid = btnval.substring(i+1,j);
                String cid = btnval.substring(j+1,k);
                String pid = btnval.substring(k+1,l);
                String mid = btnval.substring(l+1);
                query = "DELETE FROM "+table+" WHERE OID= '"+oid+"' AND CID= '"+cid+"' AND PID = '"+pid+"' AND MID = '"+mid+"'";
            }
            try{
                DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);
                ops = (OraclePreparedStatement) oconn.prepareStatement(query);
                int x = ops.executeUpdate();
                if(x>0){
                    out.println("<script>");
                    // Account deleted successful
                    if(table.equals("CUSTOMER") && userType.equals("ADMIN")){
                        out.println("location.href='http://localhost:8080/MinorWebApp/PageServes/customer.jsp?response=delete-success';");
                    }else if(table.equals("CUSTOMER") && userType.equals("CUSTOMER")){
                        out.println("location.href='http://localhost:8080/MinorWebApp/StatPages/login.html?response=customer-deleted';");
                    }else if(table.equals("PHARMACY") && userType.equals("ADMIN")){
                        out.println("location.href='http://localhost:8080/MinorWebApp/PageServes/pharmacy.jsp?response=delete-success';");
                    }else if(table.equals("PHARMACY") && userType.equals("PHARMACY")){
                        out.println("location.href='http://localhost:8080/MinorWebApp/StatPages/login.html?response=pharmacy-deleted';");
                    }else if(table.equals("MEDICINE")){
                        out.println("location.href='http://localhost:8080/MinorWebApp/PageServes/medicine.jsp?response=delete-success';");
                    }else if(table.equals("PHARM_MED_STOCK") && userType.equals("ADMIN")){
                        out.println("location.href='http://localhost:8080/MinorWebApp/PageServes/medPharmStock.jsp?response=delete-success';");
                    }else if(table.equals("PHARM_MED_STOCK") && userType.equals("PHARMACY")){
                        out.println("location.href='http://localhost:8080/MinorWebApp/PageServes/PharmacyStock.jsp?response=delete-success';");
                    }else if(table.equals("ORDERS") && userType.equals("ADMIN")){
                        out.println("location.href='http://localhost:8080/MinorWebApp/PageServes/orders.jsp?response=delete-success';");
                    }else if(table.equals("ORDERS") && userType.equals("CUSTOMER")){
                        out.println("location.href='http://localhost:8080/MinorWebApp/PageServes/CustomerCart.jsp?response=delete-success';");
                    }
                    out.println("</script>");
                }else{
                        out.println("<script>");
                        out.println("alert('No changes to the database');");
                        out.println("</script>");
                }
                oconn.close();
                ops.close();
            }catch (SQLException ex) {
                Logger.getLogger(DeleteAll.class.getName()).log(Level.SEVERE, null, ex);
                out.println("<script>");
                // Data cannot be deleted because it has records in the child table.
                if(table.equals("CUSTOMER") && userType.equals("ADMIN")){
                    out.println("location.href='http://localhost:8080/MinorWebApp/PageServes/customer.jsp?response=delete-error';");
                }else if(table.equals("CUSTOMER") && userType.equals("CUSTOMER")){
                    out.println("location.href='http://localhost:8080/MinorWebApp/PageServes/ModifyCustomer.jsp?response=delete-error';");
                }else if(table.equals("PHARMACY") && userType.equals("ADMIN")){
                    out.println("location.href='http://localhost:8080/MinorWebApp/PageServes/pharmacy.jsp?response=delete-error';");
                }else if(table.equals("PHARMACY") && userType.equals("PHARMACY")){
                    out.println("location.href='http://localhost:8080/MinorWebApp/PageServes/ModifyPharmacy.jsp?response=delete-error';");
                }
                //out.println("location.href='http://localhost:8080/MinorWebApp/StatPages/admin-database.html?response=delete-error';");
                out.println("</script>");
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
        try {
            processRequest(request, response);
        } catch (SQLException ex) {
            Logger.getLogger(DeleteAll.class.getName()).log(Level.SEVERE, null, ex);
        }
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
        try {
            processRequest(request, response);
        } catch (SQLException ex) {
            Logger.getLogger(DeleteAll.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }

}
