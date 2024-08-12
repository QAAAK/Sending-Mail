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
            connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
