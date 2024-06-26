import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class PostgreSQL {


    public static void main(String[] args) {
        String jdbcUrl = "jdbc:postgresql://gp_connection.ru:5432/core";
        String username = *****;
        String password = *****;

        try {
            Connection connection = DriverManager.getConnection(jdbcUrl, username, password);
            // Now you can use 'connection' to execute SQL queries.
            // Don't forget to close the connection when you're done.
            connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
