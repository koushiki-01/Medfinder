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
import oracle.jdbc.OracleResultSetMetaData;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet(name = "PlaceOrder", urlPatterns = {"/PlaceOrder"})
public class PlaceOrder extends HttpServlet {
    OracleConnection oconn;
    OraclePreparedStatement ops, ops1, ops2;
    OracleResultSet ors, ors1, ors2;
    OracleResultSetMetaData orsm1;
    String email, cid, pid, mid, status, oid, query, query1, query2, date, mqty, qty, item_price, odate, rtotal, total, pname, mname;
    HttpSession sess;
    
    //Oconn connection handling, change the classname in the try line: classname.class.getClassLoader()
    private String oconnUrl;
    private String oconnUsername;
    private String oconnPassword;

    @Override
    public void init() throws ServletException {
        super.init();

        try (InputStream input = PlaceOrder.class.getClassLoader().getResourceAsStream("db.properties")) {
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
            throws ServletException, IOException, SQLException, ParseException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet PlaceOrder</title>");            
            out.println("</head>");
            out.println("<body>");
            sess = request.getSession(false);
            if(sess!=null)
                email = sess.getAttribute("email").toString();
            try{
                DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);
                odate = CurrentDateTime.getDateTime();
                //CHANGING THE FORMAT OF DATE                
                SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy");
                Date dt = sdf.parse(odate);
                SimpleDateFormat sdf1 = new SimpleDateFormat("dd-MMM-yyyy");
                odate = sdf1.format(dt);
                out.println("<h3>ODATE: "+odate+"</h3>");
                query1 = "SELECT OID, CID, PID, MID, QTY, ITEM_PRICE, TOTAL FROM ORDERS WHERE CID = (SELECT CID FROM CUSTOMER WHERE EMAIL = ?) AND STATUS = 'CART'";
                ops1 = (OraclePreparedStatement) oconn.prepareStatement(query1);
                ops1.setString(1,email);
                ors1 = (OracleResultSet) ops1.executeQuery();
                query2 = "SELECT MQTY FROM PHARM_MED_STOCK WHERE PID = ? AND MID = ?";
                ors1 = (OracleResultSet) ops1.executeQuery();
                orsm1 = (OracleResultSetMetaData) ors1.getMetaData();
                while(ors1.next()){
                    boolean change = false;
                    for(int i=1; i<=orsm1.getColumnCount(); i++){
                        oid = ors1.getString("OID");
                        cid = ors1.getString("CID");
                        pid = ors1.getString("PID");
                        mid = ors1.getString("MID");
                        qty = ors1.getString("QTY");
                        item_price = ors1.getString("ITEM_PRICE");
                        rtotal = ors1.getString("TOTAL");
                        query = "SELECT PNAME FROM PHARMACY WHERE PID = ?";
                        ops = (OraclePreparedStatement) oconn.prepareStatement(query);
                        ops.setString(1,pid);
                        ors = (OracleResultSet) ops.executeQuery();
                        ors.next();
                        pname = ors.getString(1);
                        query = "SELECT MNAME FROM MEDICINE WHERE MID = ?";
                        ops = (OraclePreparedStatement) oconn.prepareStatement(query);
                        ops.setString(1,mid);
                        ors = (OracleResultSet) ops.executeQuery();
                        ors.next();
                        mname = ors.getString(1);                        
                        ops2 = (OraclePreparedStatement) oconn.prepareStatement(query2);
                        ops2.setString(1, pid);
                        ops2.setString(2, mid);
                        ors2 = (OracleResultSet) ops2.executeQuery();
                        ors2.next();               
                        mqty = ors2.getString("MQTY");
                        if(Integer.parseInt(mqty)<Integer.parseInt(qty)){
                            out.println("<script>");
                            out.println("alert('Not enough stock to place order for pharmacy: '"+pname+"' and medicine: '"+mname+"');");
                            out.println("location.href='http://localhost:8080/MinorWebApp/PlaceOrder';");
                            out.println("<script>");
                        }
                        if(!change){
                            mqty = ""+(Integer.parseInt(mqty)-Integer.parseInt(qty));
                            change = true;
                        }
                        query = "UPDATE PHARM_MED_STOCK SET MQTY = ? WHERE PID = ? AND MID = ?";
                        ops = (OraclePreparedStatement) oconn.prepareStatement(query);
                        ops.setString(1,mqty);
                        ops.setString(2,pid);
                        ops.setString(3,mid);
                        int x = ops.executeUpdate();
                        if(x<=0){
                            out.println("<script>");
                            out.println("alert('Update on Order did not take place!');");
                            out.println("location.href='http://localhost:8080/MinorWebApp/PlaceOrder';");
                            out.println("<script>");
                        }
                        query = "UPDATE ORDERS SET ODATE = ?, STATUS = 'ORDERED' WHERE OID = ? AND CID = ? AND PID = ? AND MID = ?";
                        ops = (OraclePreparedStatement) oconn.prepareStatement(query);
                        ops.setString(1,odate);
                        ops.setString(2,oid);
                        ops.setString(3,cid);
                        ops.setString(4,pid);
                        ops.setString(5,mid);
                        x = ops.executeUpdate();
                        if(x<=0){
                            out.println("<script>");
                            out.println("alert('Update on Order did not take place!');");
                            out.println("location.href='http://localhost:8080/MinorWebApp/PlaceOrder';");
                            out.println("<script>");
                        }
                    }
                }
                response.sendRedirect("http://localhost:8080/MinorWebApp/PageServes/SearchMedicine.jsp?response=order-placed");
            }catch (SQLException ex) {
                    Logger.getLogger(AddToCart.class.getName()).log(Level.SEVERE, null, ex);
                    out.println("<h2 style='color:red'>Error is: "+ ex.toString() + "</h2>");
            
            out.println("<h1>Servlet PlaceOrder at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
            }
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
        } catch (SQLException | ParseException ex) {
            Logger.getLogger(PlaceOrder.class.getName()).log(Level.SEVERE, null, ex);
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
            try {
                processRequest(request, response);
            } catch (ParseException ex) {
                Logger.getLogger(PlaceOrder.class.getName()).log(Level.SEVERE, null, ex);
            }
        } catch (SQLException ex) {
            Logger.getLogger(PlaceOrder.class.getName()).log(Level.SEVERE, null, ex);
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
    }// </editor-fold>
}


