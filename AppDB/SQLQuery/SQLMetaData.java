package SQLQuery;


import java.sql.*;
import java.util.ArrayList;

public class SQLMetaData {

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

        ArrayList<String> AllColumnsName = new ArrayList<>();
        AllColumnsName.add("Выберете поле из таблицы");


        // Получите метаданные для столбцов таблицы
        ResultSet columns = metaData.getColumns(null, null, tableName, null);

        // Выведите наименования столбцов
        while (columns.next()) {
            String columnName = columns.getString("COLUMN_NAME");
            AllColumnsName.add(columnName);
        }

        return AllColumnsName;
    }


    public static ArrayList allColumnsNameTableOrder (Connection conn, String tableName) throws SQLException {

        DatabaseMetaData metaData = conn.getMetaData();

        // Укажите таблицу, для которой вы хотите получить столбцы

        ArrayList<String> AllColumnsName = new ArrayList<>();
        AllColumnsName.add("Выберете поле таблицы для сортировки");


        // Получите метаданные для столбцов таблицы
        ResultSet columns = metaData.getColumns(null, null, tableName, null);

        // Выведите наименования столбцов
        while (columns.next()) {
            String columnName = columns.getString("COLUMN_NAME");
            AllColumnsName.add(columnName);
        }





        return AllColumnsName;
    }






}
