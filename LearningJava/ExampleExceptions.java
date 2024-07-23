import java.sql.SQLException;

public class ExampleExceptions {


    public static void main (String[] args) {


        try {

            int i = 10;
            int b = i /0;

        } catch (Exception e) {

            StackTraceElement[] Stringexcept = e.getStackTrace();
            System.out.println(Stringexcept);

        }



    }

    public static void logFile () throws Exception, SQLException {


        int i = 10/0;

        System.out.println("Ok");

    }


}
