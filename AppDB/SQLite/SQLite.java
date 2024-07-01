package SQLite;

import java.io.FileNotFoundException;
import java.io.UnsupportedEncodingException;
import java.sql.*;
import java.io.PrintWriter;
import java.util.ArrayList;


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



    public static void queryToCSV(String query, Connection conn) throws SQLException, FileNotFoundException, UnsupportedEncodingException {

        Statement stmt = conn.createStatement();
        ResultSet result = stmt.executeQuery(query);
        ResultSetMetaData metaData = result.getMetaData();

        int columnsNumber = metaData.getColumnCount();
        PrintWriter writer = new PrintWriter("C:\\Users\\santalovdv\\Desktop\\Лист Microsoft Excel.csv");

        for (int i = 1; i <= columnsNumber; i++) {
            writer.print(metaData.getColumnName(i)); // Записываем наименования колонок
            if (i < columnsNumber) {
                writer.print(",");
            }
        }
        writer.println();

        while (result.next()) {
            for (int i = 1; i <= columnsNumber; i++) {
                writer.print(result.getString(i));
                if (i < columnsNumber) {
                    writer.print(",");
                }
            }
            writer.println();
        }
        writer.close();
    }

    public static ArrayList allNamesTables (Connection conn) throws SQLException {

        DatabaseMetaData metaData = conn.getMetaData();

        ResultSet tables = metaData.getTables(null, null, "%", new String[]{"TABLE"});

        ArrayList<String> AllTablesName = new ArrayList<>();
        AllTablesName.add("Выберете таблицу из списка");

        while (tables.next()) {
            String tableName = tables.getString("TABLE_NAME");
            AllTablesName.add(tableName);
        }

        return AllTablesName;
    }


    public static ArrayList allColumnsNameTable (Connection conn, String tableName) throws SQLException {

        DatabaseMetaData metaData = conn.getMetaData();

        // Укажите таблицу, для которой вы хотите получить столбцы

        // Получите метаданные для столбцов таблицы
        ResultSet columns = metaData.getColumns(null, null, tableName, null);

        // Выведите наименования столбцов
        while (columns.next()) {
            String columnName = columns.getString("COLUMN_NAME");
            System.out.println("Column Name: " + columnName);
        }


    }







    public static void main(String[] args) throws SQLException, FileNotFoundException, UnsupportedEncodingException {

          System.out.println(allNamesTables(connect(conn)));

//        queryToCSV("SELECT * FROM Customer", connect(conn));

    }
}