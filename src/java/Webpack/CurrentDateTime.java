package Webpack;

import java.text.SimpleDateFormat;
import java.util.Date;

public class CurrentDateTime {
    public static String getDateTime(){
        SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy");
        Date date = new Date();
        //System.out.println(sdf.format(date));
        return sdf.format(date)+"";
    }
    public static void main(String args[]){
        getDateTime();
    }
}
