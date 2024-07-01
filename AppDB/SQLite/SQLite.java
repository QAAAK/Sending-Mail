package SQLite;

import java.sql.*;

/**
 *
 * @author santalovdv
 */
public class SQLite {
    /**
     * Connect to a sample database
     */

    static Connection conn = null;

    public static Connection connect(Connection conn) {


        try {
            String url = "jdbc:sqlite:C:\\Users\\santalovdv\\Desktop\\Java\\sample-database-sqlite-1\\Chinook.db";

            conn = DriverManager.getConnection(url);

            System.out.println("Connection to SQLite has been established.");

            return conn;

        } catch (SQLException e) {

            System.out.println(e.getMessage());

            return conn;

        }
    }



    public static void queryToDB (String query, Connection conn) throws SQLException {


        Statement stmt = conn.createStatement();

        ResultSet result = stmt.executeQuery(query);


        while (result.next()) {
            System.out.print(result.getString(1));
            System.out.println(" " + result.getString(2));
        }




    }

    public static void main(String[] args) throws SQLException {



        queryToDB("SELECT * FROM Album", connect(conn));

    }
}